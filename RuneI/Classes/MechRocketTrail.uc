//=============================================================================
// MechRocketTrail.
//=============================================================================
class MechRocketTrail expands ParticleSystem;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	VelocityMax = -(vector(Rotation) * 75);
}

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=30
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     VelocityMin=(Z=-20.000000)
     ScaleMin=0.500000
     ScaleMax=1.000000
     ScaleDeltaX=0.700000
     ScaleDeltaY=0.700000
     LifeSpanMin=0.200000
     LifeSpanMax=0.400000
     AlphaStart=100
     AlphaEnd=25
     PercentOffset=1
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-1.100000
     SpawnOverTime=1.000000
     bDirectional=True
     Style=STY_Translucent
}
