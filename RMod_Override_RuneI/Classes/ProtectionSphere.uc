//=============================================================================
// ProtectionSphere.
//=============================================================================
class ProtectionSphere expands Effects;

var() float GlowHigh;
var() float DecayPerSecond;

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local rotator rot;

	rot = rotator(HitLoc - Location);
	Spawn(class'ProtSphereDamage',,,HitLoc,rot);
	return false;	// end swipe
}

/*
function Tick(float DeltaTime)
{
	if (ScaleGlow > 0)
	{
		ScaleGlow -= DeltaTime * DecayPerSecond;
		if (ScaleGlow < 0)
		{
			ScaleGlow = 0;
			bHidden=true;
		}
	}
}
*/

defaultproperties
{
     GlowHigh=3.000000
     DecayPerSecond=2.000000
     DrawType=DT_SkeletalMesh
     Style=STY_Translucent
     Sprite=Texture'RuneFX.Spark1'
     Texture=Texture'RuneFX.Spark1'
     DrawScale=13.000000
     ScaleGlow=0.400000
     CollisionRadius=50.000000
     CollisionHeight=50.000000
     bCollideActors=True
     bSweepable=True
     Skeletal=SkelModel'objects.Fruit'
}
