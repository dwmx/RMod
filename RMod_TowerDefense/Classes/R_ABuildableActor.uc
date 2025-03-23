//==============================================================================
// R_ABuildableActor
// Abstract Actor class which is the base for all actors that can be built by
// the R_RunePlayer_TD player class via the R_BuilderBrush Actor
//==============================================================================
class R_ABuildableActor extends Actor abstract;

// Static utilities
var Class<R_AUtilities> UtilitiesClass;

defaultproperties
{
    DrawType=DT_SkeletalMesh
    UtilitiesClass=Class'RMod.R_AUtilities'
}