//=============================================================================
// ShortBrazer.
//=============================================================================
class ShortBrazer expands FireObject;

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_METAL;
}

defaultproperties
{
     FireClass=Class'RuneI.Fire'
     Style=STY_Masked
     CollisionHeight=23.000000
     bBlockActors=True
     bBlockPlayers=True
     Skeletal=SkelModel'objects.ShortBrazer'
}
