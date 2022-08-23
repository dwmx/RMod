//=============================================================================
// FlashCycle.
// Bright flash that fades up and down
//=============================================================================
class FlashCycle expands Effects;

var() float GlowLow;
var() float GlowHigh;

function PreBeginPlay()
{
	RotationRate=rotator(VRand())*5000;
	ScaleGlow=GlowHigh;
}

function Tick(float DeltaTime)
{
	ScaleGlow = RandRange(GlowLow, GlowHigh);
}

defaultproperties
{
     GlowLow=0.500000
     GlowHigh=2.500000
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
