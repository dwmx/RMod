//=============================================================================
// PlayerCarcass.
//=============================================================================
class PlayerCarcass extends RuneCarcass;

function PlayStabRemove()
{
	PlayAnim('ReactToPullout', 1.0, 0.1);
}

defaultproperties
{
     PrePivot=(Z=38.000000)
     CollisionRadius=40.000000
     CollisionHeight=8.000000
     Skeletal=SkelModel'Players.Ragnar'
}
