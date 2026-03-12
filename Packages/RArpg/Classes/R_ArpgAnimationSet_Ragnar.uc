//==============================================================================
//	R_ArpgAnimationSet_Ragnar
//	Base class for Ragnar SkelModel animations
//==============================================================================
class R_ArpgAnimationSet_Ragnar extends R_ArpgAnimationSet;

defaultproperties
{
    Idle=neutral_idle
    Forward=MOV_ALL_run1_AA0N
    Backward=MOV_ALL_runback1_AA0S
    Forward45Right=MOV_ALL_rstrafe1_AA0S
    Forward45Left=MOV_ALL_lstrafe1_AA0S
    Backward45Right=MOV_ALL_lstrafe1_AA0S
    Backward45Left=MOV_ALL_rstrafe1_AA0S
    StrafeRight=MOV_ALL_rstrafe1_AN0N
    StrafeLeft=MOV_ALL_lstrafe1_AN0N
}