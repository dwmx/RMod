//==============================================================================
// R_ABuildableActor
// Abstract Actor class which is the base for all actors that can be built by
// the R_RunePlayer_TD player class via the R_BuilderBrush Actor
//==============================================================================
class R_ABuildableActor extends Actor abstract;

defaultproperties
{
    DrawType=DT_SkeletalMesh
}