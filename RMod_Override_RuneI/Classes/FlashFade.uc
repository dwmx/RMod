//=============================================================================
// FlashFade.
// Bright flash that quickly fades out
//=============================================================================
class FlashFade expands Effects;

var() float GlowHigh;
var() float DecayPerSecond;

function PreBeginPlay()
{
	RotationRate=rotator(VRand())*5000;
	ScaleGlow=GlowHigh;
}

function Tick(float DeltaTime)
{
	if (ScaleGlow > 0)
	{
		ScaleGlow -= DeltaTime * DecayPerSecond;
		if (ScaleGlow < 0)
		{
			ScaleGlow = 0;
			Destroy();
		}
	}
}

defaultproperties
{
     GlowHigh=2.000000
     DecayPerSecond=2.500000
     DrawType=DT_SkeletalMesh
     Style=STY_Translucent
     Sprite=Texture'RuneFX.Spark1'
     Texture=Texture'RuneFX.Spark1'
     DrawScale=7.000000
     ScaleGlow=0.000000
     bParticles=True
     CollisionRadius=50.000000
     CollisionHeight=50.000000
     Skeletal=SkelModel'objects.Fruit'
}
