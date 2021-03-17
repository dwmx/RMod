//=============================================================================
// SequencerBase.
//=============================================================================
class SequencerBase expands Actor
	abstract;

#exec Texture Import File=Textures\Sequencer.pcx Name=S_Sequencer Mips=Off Flags=2

enum ESeqToken
{
	TK_Variable, TK_GlobalVariable, TK_Number, TK_String, TK_Word, TK_Add,
	TK_Sub, TK_Mul, TK_Div, TK_Mod, TK_Eq, TK_Lt, TK_Gt, TK_And, TK_Or,
	TK_Not, TK_Inc, TK_Dec, TK_Store, TK_AddStore, TK_SubStore, TK_MulStore,
	TK_DivStore, TK_ModStore, TK_Call, TK_Return, TK_If, TK_Else, TK_EndIf,
	TK_Loop, TK_EndLoop, TK_Do, TK_Until, TK_Repeat, TK_EndRepeat,
	TK_BreakIf, TK_BreakIfNot, TK_ContinueIf, TK_End, TK_SpecialWord,
	TK_None
};

// EDITABLE INSTANCE VARIABLES ////////////////////////////////////////////////

// INSTANCE VARIABLES /////////////////////////////////////////////////////////

// FUNCTIONS //////////////////////////////////////////////////////////////////

// STATES /////////////////////////////////////////////////////////////////////

defaultproperties
{
     Texture=Texture'Engine.S_Sequencer'
}
