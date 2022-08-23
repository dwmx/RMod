//=============================================================================
// OdinEffect.
//=============================================================================
class OdinEffect expands ParticleSystem;

simulated function PostBeginPlay()
{
	local vector rotVect;
	local float Force;
	Super.PostBeginPlay();
	
	rotVect = vector(Rotation);

	if(Owner.IsA('Odin'))
	{
		Force = 10 * Owner.DrawScale;
		ScaleMax = 0.2 * Owner.DrawScale;
		ScaleMin = ScaleMax;
		GravityScale = 0.001 * Owner.DrawScale;	
	}
	else
	{
		Force = 50;
	}
	
	bDirectional = false;
	
	VelocityMax = (vect(0,0,1) cross rotVect - vect(0,0,1)) * Force;
	VelocityMin = (rotVect cross vect(0,0,1) - vect(0,0,1)) * Force;
}

defaultproperties
{
     ParticleCount=20
     ParticleTexture(0)=Texture'RuneFX.lokismoke'
     ScaleMin=1.000000
     ScaleMax=1.200000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=1.000000
     LifeSpanMax=1.500000
     AlphaStart=100
     bAlphaFade=True
     bApplyGravity=True
     SpawnOverTime=1.500000
     bDirectional=True
     Style=STY_AlphaBlend
     CollisionRadius=100.000000
     CollisionHeight=50.000000
}
