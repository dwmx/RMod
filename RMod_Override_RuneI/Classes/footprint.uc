//=============================================================================
// Footprint.
//=============================================================================
class Footprint extends Decal;

var float ElapsedTime;


simulated function PostBeginPlay()
{
	ElapsedTime = 0;
}

simulated function DirectionalAttach(vector Dir, vector Norm)
{
	if (Dir.Z < 0)
		Dir.Z = -Dir.Z;
	SetRotation(rotator(Norm));
	if( !AttachDecal(100, Dir) )	// trace 100 units ahead in direction of current rotation
		Destroy();
}

simulated function Tick(float DeltaTime)
{
	ElapsedTime += DeltaTime;

	AlphaScale = 1.0 - (ElapsedTime / 10.0);
	AlphaScale = FClamp(AlphaScale, 0.0, Default.AlphaScale);
	
	if (AlphaScale <= 0)
	{
		AlphaScale = 0;
		Destroy();
	}
}

defaultproperties
{
     Style=STY_Modulated
     Texture=Texture'RuneFX.footprint'
}
