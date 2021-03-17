//=============================================================================
// SequencerAdministrator.
//=============================================================================
class SequencerAdministrator expands SequencerBase;

// INSTANCE VARIABLES /////////////////////////////////////////////////////////

var float		GVar[26];
var ESeqToken	AscToToken[96];
var Sequencer	SeqCommunity[20];

// FUNCTIONS //////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Inception.
//-----------------------------------------------------------------------------
function Inception()
{
	log("SequencerAdministrator Inception");
	LinkCommunity();
	BuildTokenTable();
}

//-----------------------------------------------------------------------------
// LinkCommunity.
//-----------------------------------------------------------------------------
function LinkCommunity()
{
	local Sequencer s;

	foreach AllActors(class'Sequencer', s)
	{
		s.SeqAdmin = self;
		if(s.CommunityLocus != -1)
			SeqCommunity[s.CommunityLocus] = s;
	}
}

//-----------------------------------------------------------------------------
// BuildTokenTable.
//-----------------------------------------------------------------------------
function BuildTokenTable()
{
	local int i;

	for(i = 0; i < 96; i++)  AscToToken[i] = TK_None;
	for(i = 16; i < 26; i++) AscToToken[i] = TK_Number;
	for(i = 33; i < 59; i++) AscToToken[i] = TK_Word;
	for(i = 65; i < 91; i++) AscToToken[i] = TK_Variable;
	AscToToken[1]	= TK_Not;			AscToToken[2]	= TK_String;
	AscToToken[3]	= TK_Store;			AscToToken[4]	= TK_SpecialWord;
	AscToToken[5]	= TK_Mod;			AscToToken[6]	= TK_And;
	AscToToken[7]	= TK_GlobalVariable;
	AscToToken[8]	= TK_Loop;			AscToToken[9]	= TK_EndLoop;
	AscToToken[10]	= TK_Mul;			AscToToken[11]	= TK_Add;
	AscToToken[12]	= TK_BreakIfNot;	AscToToken[13]	= TK_Sub;
	AscToToken[14]	= TK_Number;		AscToToken[15]	= TK_Div;
	AscToToken[26]	= TK_Else;			AscToToken[27]	= TK_Return;
	AscToToken[28]	= TK_Lt;			AscToToken[29]	= TK_Eq;
	AscToToken[30]	= TK_Gt;			AscToToken[31]	= TK_If;
	AscToToken[32]	= TK_Call;			AscToToken[59]	= TK_Repeat;
	AscToToken[60]	= TK_EndIf;			AscToToken[61]	= TK_EndRepeat;
	AscToToken[62]	= TK_BreakIf;		AscToToken[63]	= TK_End;
	AscToToken[91]	= TK_Do;			AscToToken[92]	= TK_Or;
	AscToToken[93]	= TK_Until;			AscToToken[94]	= TK_ContinueIf;
}

defaultproperties
{
}
