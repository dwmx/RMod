//=============================================================================
// BabyTubeStriker.
//=============================================================================
class BabyTubeStriker expands TubeStriker;

function class<Actor> SeveredLimbClass(int BodyPart)
{
	return None;
}

defaultproperties
{
     FlailSound=Sound'CreaturesSnd.TubeStriker.tubeflail01'
     MeleeRange=100.000000
     DrawScale=0.500000
     PrePivot=(Z=-32.000000)
     CollisionRadius=11.500000
     CollisionHeight=23.500000
}
