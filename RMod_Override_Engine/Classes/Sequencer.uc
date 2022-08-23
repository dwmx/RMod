//=============================================================================
// Sequencer.
//=============================================================================
class Sequencer expands SequencerBase;

const SEQ_VAR_COUNT = 26;

enum EIAction
{
	IA_Continue,	// Continue interpretation
	IA_Halt,		// Halt and wait for trigger
	IA_Stop,		// Stop
	IA_Sleep		// Sleep for a specified duration
};

// EDITABLE INSTANCE VARIABLES ////////////////////////////////////////////////

var() bool		bAutoStart;
var() string	CodeString;
var() int		CommunityLocus;

// INSTANCE VARIABLES /////////////////////////////////////////////////////////

var float				SVar[26];
var string				XCode;
var int					XCodeSize;
var int					XCodePtr;
var float				TokNumber;
var string				TokString;
var int					TokLabel;
var int					TokVariable;
var int					TokWord;
var ESeqToken			CurrentToken;
var float				DStack[32];			// Data stack
var byte				DStackType[32];		// 0..25:var, 26..51:gvar,
											// 255:float
var int					CStack[8];			// Control stack
var int					DSPtr, CSPtr;
var float				LOp, ROp;
var EIAction			NextInterpAction;
var float				SleepDuration;		// Duration to wait after IA_Sleep

var SequencerAdministrator SeqAdmin;

// FUNCTIONS //////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// BeginPlay.
//-----------------------------------------------------------------------------
event BeginPlay()
{
	local SequencerAdministrator sAdmin;

	super.BeginPlay();
	foreach AllActors(class'SequencerAdministrator', sAdmin)
		return;

	sAdmin = spawn(class'SequencerAdministrator');
	sAdmin.Inception();
}

//-----------------------------------------------------------------------------
// InitCodeString.
//-----------------------------------------------------------------------------
function InitCodeString(string cStr)
{
	local int i, c;

	for(i = 0; i < 26; i++)
		SVar[i] = 0.0;

	i = 0;
	XCodeSize = Len(cStr);
	while(i < XCodeSize-2)
		if(Mid(cStr, i++, 1) == "_")
		{
			c = Asc(Mid(cStr, i++));
			if(c > 96 && c < 123)
				SVar[c-97] = i;
		}
	XCode = cStr;
	XCodePtr = 0;
	DSPtr = 32;
	CSPtr = 8;
}

//-----------------------------------------------------------------------------
// NextToken.
//-----------------------------------------------------------------------------
function ESeqToken NextToken()
{
	local int c, c2;
	local ESeqToken t;

	while(XCodePtr < XCodeSize)
	{
		c = Asc(Mid(XCode, XCodePtr++, 1));
		if(c < 33)
			continue;
		t = SeqAdmin.AscToToken[c-32];
		if(t == TK_Variable)
		{
			TokVariable = c-97;
			return TK_Variable;
		}
		if(t == TK_GlobalVariable)
		{
			if(XCodePtr < XCodeSize)
			{
				c2 = Asc(Mid(XCode, XCodePtr++, 1));
				t = SeqAdmin.AscToToken[c2-32];
				if(t == TK_Variable)
				{
					TokVariable = c2-97;
					return TK_GlobalVariable;
				}
				else return TK_None;
			}
			else return TK_End;
		}
		if(t == TK_Number)
		{
			TokNumber = ParseNumber(c);
			return TK_Number;
		}
		if(t == TK_Word)
		{
			if(XCodePtr >= XCodeSize)
				return TK_End;
			TokWord = c*100 + Asc(Mid(XCode, XCodePtr++))-32;
			return TK_Word;
		}
		if(t == TK_String)
		{ // Strings -> numbers
			TokNumber = XCodePtr;
			c2 = -1;
			while(XCodePtr < XCodeSize)
			{
				c = Asc(Mid(XCode, XCodePtr++));
				if(c == 34 && c2 != 92)
					break;
				c2 = c;
			}
			return TK_Number;
		}

		c2 = Asc(Mid(XCode, XCodePtr++));
		if(t == TK_Add)
		{
			if(c2 == 43) // ++
				return TK_Inc;
			if(c2 == 35) // +#
				return TK_AddStore;
		}
		if(t == TK_Sub)
		{
			if(c2 == 45) // --
				return TK_Dec;
			if(c2 == 35) // +#
				return TK_SubStore;
			if(SeqAdmin.AscToToken[c2-32] == TK_Number)
			{
				XCodePtr--;
				TokNumber = ParseNumber(c);
				return TK_Number;
			}
		}
		if(t == TK_Mul && c2 == 35) // *#
			return TK_MulStore;
		if(t == TK_Div && c2 == 35) // /#
			return TK_DivStore;
		XCodePtr--;

		if(t != TK_None)
			return t;
	}
	return TK_End;
}

//-----------------------------------------------------------------------------
// ParseNumber.
//-----------------------------------------------------------------------------
function float ParseNumber(int c)
{
	local float v, v2, d;
	local bool neg;

	v = 0;
	neg = false;
	if(c == 46)
		XCodePtr--;
	else
	{
		if(c == 45)
			neg = true;
		v = FClamp(c-48, 0, 9);
		while(XCodePtr < XCodeSize)
		{
			c = Asc(Mid(XCode, XCodePtr));
			if(SeqAdmin.AscToToken[c-32] != TK_Number || c == 46)
				break;
			v = v*10 + c-48;
			XCodePtr++;
		}
	}
	if(c == 46)
	{
		v2 = 0;
		d = 1;
		XCodePtr++;
		while(XCodePtr < XCodeSize)
		{
			c = Asc(Mid(XCode, XCodePtr));
			if(SeqAdmin.AscToToken[c-32] != TK_Number || c == 46)
				break;
			v2 = v2*10 + c-48;
			d *= 10;
			XCodePtr++;
		}
		v += v2/d;
	}
	if(neg)
		return -v;
	return v;
}

//-----------------------------------------------------------------------------
// ParseString.
//-----------------------------------------------------------------------------
function string ParseString(int sPtr)
{
	local int c;
	local string tStr;
	local bool escapeSequence;

	escapeSequence = false;
	while(sPtr >= 0 && sPtr < XCodeSize)
	{
		c = Asc(Mid(XCode, sPtr++));
		if(escapeSequence)
		{
			switch(c)
			{
			case  97: c =  7; break; // a: Audible alert
			case  98: c =  8; break; // b: Backspace
			case 116: c =  9; break; // t: Horizontal tab
			case 110: c = 10; break; // n: Newline
			case 118: c = 11; break; // v: Verticle tab
			case 102: c = 12; break; // f: Formfeed
			case 114: c = 13; break; // r: Carraige return
			case 120: // x:
				break;
			}
			escapeSequence = false;
		}
		else
		{
			if(c == 92)
			{
				escapeSequence = true;
				continue;
			}
			if(c == 34)
				break;
		}
		tStr = tStr $ Chr(c);
	}
	return tStr;
}

//-----------------------------------------------------------------------------
// MainParse.
//-----------------------------------------------------------------------------
function MainParse()
{
	local float n;
	local int i, v;
	local ESeqToken t;

	NextInterpAction = IA_Continue;
	do
	{
		switch(NextToken())
		{
		case TK_Number: PushNum(TokNumber); break;
		case TK_Variable: PushVar(TokVariable); break;
		case TK_GlobalVariable: PushGlobalVar(TokVariable); break;
		case TK_Call: PushAddr(XCodePtr); XCodePtr = PopNum(); break;
		case TK_Return: XCodePtr = PopAddr(); break;
		case TK_Word: ExecuteWord(); break;
		case TK_Mul: PrepBOperator(); DStack[DSPtr] *= ROp; break;
		case TK_Div: PrepBOperator(); DStack[DSPtr] /= ROp; break;
		case TK_Mod: PrepBOperator(); DStack[DSPtr] = DStack[DSPtr] % ROp; break;
		case TK_Add: PrepBOperator(); DStack[DSPtr] += ROp; break;
		case TK_Sub: PrepBOperator(); DStack[DSPtr] -= ROp; break;
		case TK_MulStore:
			v = PrepSpecStore();
			if(v < SEQ_VAR_COUNT)
				SVar[v] *= LOp;
			else
				SeqAdmin.GVar[v-SEQ_VAR_COUNT] *= LOp;
			break;
		case TK_DivStore:
			v = PrepSpecStore();
			if(v < SEQ_VAR_COUNT)
				SVar[v] /= LOp;
			else
				SeqAdmin.GVar[v-SEQ_VAR_COUNT] /= LOp;
			break;
		case TK_ModStore:
			v = PrepSpecStore();
			if(v < SEQ_VAR_COUNT)
				SVar[v] = SVar[v] % Lop;
			else
				SeqAdmin.GVar[v-SEQ_VAR_COUNT] = SeqAdmin.GVar[v-SEQ_VAR_COUNT] % LOp;
			break;
		case TK_AddStore:
			v = PrepSpecStore();
			if(v < SEQ_VAR_COUNT)
				SVar[v] += LOp;
			else
				SeqAdmin.GVar[v-SEQ_VAR_COUNT] += LOp;
			break;
		case TK_SubStore:
			v = PrepSpecStore();
			if(v < SEQ_VAR_COUNT)
				SVar[v] -= LOp;
			else
				SeqAdmin.GVar[v-SEQ_VAR_COUNT] -= LOp;
			break;
		case TK_Eq:
			PrepBOperator(); DStack[DSPtr] = float(DStack[DSPtr] == ROp); break;
		case TK_Lt:
			PrepBOperator(); DStack[DSPtr] = float(DStack[DSPtr] < ROp); break;
		case TK_Gt:
			PrepBOperator(); DStack[DSPtr] = float(DStack[DSPtr] > ROp); break;
		case TK_And:
			PrepBOperator();
			DStack[DSPtr] = float(bool(DStack[DSPtr]) && bool(ROp)); break;
		case TK_Or:
			PrepBOperator();
			DStack[DSPtr] = float(bool(DStack[DSPtr]) || bool(ROp)); break;
		case TK_Not:
			PrepSingleDS(); DStack[DSPtr] = float(!bool(DStack[DSPtr])); break;
		case TK_Inc: v = PopVar(); SVar[v] += 1.0; break;
		case TK_Dec: v = PopVar(); SVar[v] -= 1.0; break;
		case TK_Store:
			v = PopVar();
			if(v < SEQ_VAR_COUNT)
				SVar[v] = PopNum();
			else
				SeqAdmin.GVar[v-SEQ_VAR_COUNT] = PopNum();
			break;
		case TK_If:
			if(!bool(PopNum()))
			{
				i = 0;
				do
				{
					t = NextToken();
					if(t == TK_If)
						i++;
					else if(t == TK_EndIf)
					{
						if(i == 0)
							break;
						else
							i--;
					}
					else if(t == TK_Else && i == 0)
						break;
				} until(t == TK_End);
			}
			break;
		case TK_Else:
			i = 0;
			do
			{
				t = NextToken();
				if(t == TK_If)
					i++;
				else if(t == TK_EndIf)
					if(i == 0)
						break;
					else
						i--;
			} until(t == TK_End);
			break;
		case TK_Endif:
		case TK_Loop:
		case TK_Do:
		case TK_Repeat:
			break;
		case TK_EndLoop:
			JumpBack(40, 41);
			break;
		case TK_Until:
			if(bool(PopNum()) == false)
				JumpBack(123, 125);
			break;
		case TK_EndRepeat:
			PrepSingleDS();
			DStack[DSPtr] -= 1;
			if(DStack[DSPtr] != 0)
				JumpBack(91, 93);
			else
				PopNum();
			break;
		case TK_End:
			NextInterpAction = IA_Stop;
			break;
		}
	} until(NextInterpAction != IA_Continue);
}

//-----------------------------------------------------------------------------
// JumpBack.
//-----------------------------------------------------------------------------
function JumpBack(int cSearch, int cMatch)
{
	local int i, c, c2, failPtr;

	i = 1;
	failPtr = XCodePtr;
	XCodePtr--;
	while(XCodePtr-- > 0)
	{
		c = Asc(Mid(XCode, XCodePtr));
		if(c == cSearch)
		{
			i--;
			if(i == 0)
			{
				XCodePtr++;
				return;
			}
		}
		else if(c == cMatch)
			i++;
		else if(c == 34)
		{
			c2 = -1;
			//while(XCodePtr-- > 0)
			//{
			//	c = Asc(Mid(XCode, XCodePtr));
			//	if(c == 34 && c2 != 92)
			//		break;
			//	c2 = c;
			//}
		}
	}
	log("SEQ,ScanBack: no match");
	XCodePtr = failPtr;
}

//-----------------------------------------------------------------------------
// JumpAhead.
//-----------------------------------------------------------------------------
function JumpAhead(int cSearch, int cMatch)
{
}

function PrepBOperator()
{
	ROp = PopNum();
	if(DSPtr == 32)
		ParseError();
	DStackType[DSPtr] = 255; // A result is never a variable
}

function int PrepSpecStore()
{
	local int v;

	v = PopVar();
	LOp = PopNum();
	return v;
}

function PrepSingleDS()
{
	if(DSPtr == 32)
		ParseError();
	DStackType[DSPtr] = 255;
}

//-----------------------------------------------------------------------------
// Stack Functions.
//-----------------------------------------------------------------------------
function PushNum(float n)
{
	if(DSPtr == 0)
		ParseError();
	DStackType[--DSPtr] = 255;
	DStack[DSPtr] = n;
}

function float PopNum()
{
	if(DSPtr == 32)
		ParseError();
	return DStack[DSPtr++];
}

function PushVar(int v)
{
	if(DSPtr == 0)
		ParseError();
	DStackType[--DSPtr] = v;
	DStack[DSPtr] = SVar[v];
}

function int PopVar()
{
	if(DSPtr == 32)
		ParseError();
	if(DStackType[DSPtr] == 255) ParseError();
	return DStackType[DSPtr++];
}

function PushGlobalVar(int v)
{
 	if(DSPtr == 0)
 		ParseError();
	DStackType[--DSPtr] = v + SEQ_VAR_COUNT;
	DStack[DSPtr] = SeqAdmin.GVar[v];
}

function PushAddr(int a)
{
	if(CSPtr == 0)
		ParseError();
	CStack[--CSPtr] = a;
}

function int PopAddr()
{
	if(CSPtr == 8)
		ParseError();
	return CStack[CSPtr++];
}

//-----------------------------------------------------------------------------
// ParseError.
//-----------------------------------------------------------------------------
function ParseError()
{
	log("Sequence interpret error");
	NextInterpAction = IA_Stop;
}

//-----------------------------------------------------------------------------
// ExecuteWord.
//-----------------------------------------------------------------------------
function ExecuteWord()
{
	local int i;
	local float f, f2;

	switch(TokWord)
	{
	case 6885: // Du : Dup ( n1 ... n1 n1 )
		if(DSPtr == 32 || DSPtr == 0)
			ParseError();
		DSPtr--;
		DStackType[DSPtr] = DStackType[DSPtr+1];
		DStack[DSPtr] = DStack[DSPtr+1];
		break;
	case 8387: // Sw : Swap ( n1 n2 ... n2 n1 )
		if(DSPtr > 30)
			ParseError();
		f = DStack[DSPtr+1];
		i = DStackType[DSPtr+1];
		DStack[DSPtr+1] = DStack[DSPtr];
		DStackType[DSPtr+1] = DStackType[DSPtr];
		DStack[DSPtr] = f;
		DStackType[DSPtr] = i;
		break;
	case 6882: // Dr : Drop ( n ... )
		PopNum();
		break;
	case 6566: // Ab : Abs ( n1 ... n2 )
		PrepSingleDS();
		DStack[DSPtr] = Abs(DStack[DSPtr]);
		break;
	case 7778: // Mn : Min ( n1 n2 ... n3 )
		PushNum(FMin(PopNum(), PopNum()));
		break;
	case 7788: // Mx : Max ( n1 n2 ... n3 )
		PushNum(FMax(PopNum(), PopNum()));
		break;
	case 8373: // Si : Sin ( n1 ... n2 )
		PrepSingleDS();
		DStack[DSPtr] = Sin(DStack[DSPtr]);
		break;
	case 6779: // Co : Cos ( n1 ... n2 )
		PrepSingleDS();
		DStack[DSPtr] = Cos(DStack[DSPtr]);
		break;
	case 8465: // Ta : Tan ( n1 ... n2 )
		PrepSingleDS();
		DStack[DSPtr] = Tan(DStack[DSPtr]);
		break;
	case 7871: // Ng : Neg ( n1 ... n2 )
		PrepSingleDS();
		DStack[DSPtr] = -DStack[DSPtr];
		break;
	case 6986: // Ev : Event ( s ... )
		WordEvent();
		break;
	case 8376: // Sl : Sleep ( n ... )
		SleepDuration = PopNum();
		NextInterpAction = IA_Sleep;
		break;
	case 8384: // St : Stop ( ... )
		NextInterpAction = IA_Stop;
		break;
	case 8073: // Pi : Pi ( ... n )
		PushNum(Pi);
		break;
	case 8265: // Ra : Rand ( ... n )
		PushNum(FRand());
		break;
	case 8282: // Rr : RandRange ( n1 n2 ... n3 )
		f2 = PopNum();
		f = PopNum();
		PushNum(f + (f2-f)*FRand());
		break;
	case 8078: // Pn : PrintNum ( n ... )
		slog(PopNum());
		break;
	case 8083: // Ps : PrintString ( s ... )
		slog(ParseString(PopNum()));
		break;
	default:
		log("Bad TokWord case");
	}
}

function WordEvent()
{
	local name evName;

	evName = name(ParseString(PopNum()));
	if(evName != '')
		foreach AllActors(class 'Actor', Target, evName)
			Target.Trigger(self, none);
}

// STATES /////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// CheckAutoStart.
//-----------------------------------------------------------------------------
auto state CheckAutoStart
{
begin:
	if(bAutoStart)
	{
		InitCodeString(CodeString);
		GotoState('Interpret');
	}
	else
		GotoState('');
}

//-----------------------------------------------------------------------------
// Interpret.
//-----------------------------------------------------------------------------
state Interpret
{

begin:
	MainParse();
	switch(NextInterpAction)
	{
	case IA_Sleep:
		Sleep(SleepDuration);
		goto 'begin';
	case IA_Stop:
		GotoState('');
	}
	goto 'begin';
}

defaultproperties
{
}
