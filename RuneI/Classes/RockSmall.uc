//=============================================================================
// RockSmall.
//=============================================================================
class RockSmall expands Rocks;


State Throw
{
	function BeginState()
	{
		RotationRate = rotator(VRand());
	}
	
	function Landed(vector norm, actor HitActor)
	{
		RotationRate.Pitch = 0;
		RotationRate.Yaw   = 0;
		RotationRate.Roll  = 0;
		SetTimer(10, false);
	}

	function Timer()
	{
		Destroy();
	}
}

defaultproperties
{
     ImpactSound=Sound'MurmurSnd.Rocks.rock01'
     DestroyedSound=Sound'MurmurSnd.Rocks.rock08'
     AmbientGlow=50
     LODCurve=LOD_CURVE_NONE
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     Mass=10.000000
     Skeletal=SkelModel'objects.Rocks'
}
