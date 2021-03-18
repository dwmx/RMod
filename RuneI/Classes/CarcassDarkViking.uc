//=============================================================================
// CarcassDarkViking.
//=============================================================================
class CarcassDarkViking extends RuneCarcass;

function PlayStabRemove()
{
	PlayAnim('ReactToPullout', 1.0, 0.1);
}

defaultproperties
{
     AnimSequence=DTH_ALL_death1_AN0N
     PrePivot=(Z=40.000000)
     CollisionRadius=25.000000
     CollisionHeight=10.000000
     SkelMesh=1
     Skeletal=SkelModel'Players.Ragnar'
}
