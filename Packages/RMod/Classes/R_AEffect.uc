//==============================================================================
//  R_AEffect
//  Lightweight actor meant to be spawned, replicated, and then play effects
//  on local machines only.
//==============================================================================
class R_AEffect extends Actor abstract;

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=true
    DrawType=DT_None
    bGameRelevant=true
}