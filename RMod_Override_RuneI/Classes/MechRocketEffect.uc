//=============================================================================
// MechRocketEffect.
//=============================================================================
class MechRocketEffect expands ParticleSystem;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();	
	VelocityMax = -(vector(Rotation) * 50);
}

defaultproperties
{
     ParticleCount=30
     ParticleTexture(0)=FireTexture'RuneFX.Flame'
     ScaleMin=0.700000
     ScaleMax=1.200000
     ScaleDeltaX=0.600000
     ScaleDeltaY=0.600000
     LifeSpanMin=0.050000
     LifeSpanMax=0.100000
     AlphaStart=200
     AlphaEnd=50
     bAlphaFade=True
     SpawnOverTime=1.000000
     bDirectional=True
     Style=STY_Translucent
}
