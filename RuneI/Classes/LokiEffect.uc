//=============================================================================
// LokiEffect.
//=============================================================================
class LokiEffect expands ParticleSystem;

simulated function PostBeginPlay()
{
	local vector rotVect;
	local float Force;
	Super.PostBeginPlay();
	
	rotVect = vector(Rotation);

	if(Owner.IsA('LokiBust'))
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
     ParticleTexture(0)=Texture'RuneFX.lokismoke2'
     ScaleMin=2.500000
     ScaleMax=2.500000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=1.000000
     LifeSpanMax=1.500000
     AlphaStart=180
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-0.080000
     SpawnOverTime=1.500000
     bDirectional=True
     Style=STY_AlphaBlend
     CollisionRadius=100.000000
     CollisionHeight=50.000000
}
