//==============================================================================
// R_AMobAppearance_Dwarf
//==============================================================================
class R_AMobAppearance_Dwarf extends R_AMobAppearance abstract;

defaultproperties
{
    Skeletal=SkelModel'creatures.Dwarf'
    SkelMeshIndex=0
    A_Idle
    A_MoveForward=runA
    A_Dying(0)=deathf
    A_Dying(1)=deathl
    A_Dying(2)=deathr
    A_Dying(3)=deathf
    A_Dying(4)=deatha
}