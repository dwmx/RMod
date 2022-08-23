//=============================================================================
// MechRocketSmoke.
//=============================================================================
class MechRocketSmoke expands ParticleSystem;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();	
	OriginOffset = vector(Rotation) * 20;
}

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=25
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     OriginOffset=(X=50.000000,Y=50.000000)
     VelocityMin=(X=-10.000000,Y=-20.000000,Z=-20.000000)
     VelocityMax=(X=-10.000000,Y=20.000000,Z=20.000000)
     ScaleMin=0.500000
     ScaleMax=1.000000
     ScaleDeltaX=0.500000
     ScaleDeltaY=0.500000
     LifeSpanMin=0.500000
     LifeSpanMax=1.000000
     AlphaStart=100
     AlphaEnd=1
     bAlphaFade=True
     bOneShot=True
     SpawnOverTime=0.200000
     bDirectional=True
     Style=STY_Translucent
}
