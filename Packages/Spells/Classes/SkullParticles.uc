class SkullParticles extends ParticleSystem;

event PostBeginPlay()
{
	super.PostBeginPlay();

	LastTime = Level.TimeSeconds;
	CurrentTime = Level.TimeSeconds;
}

defaultproperties
{
     ParticleCount=64
     ParticleTexture(0)=Texture'RuneFX.SparkWhite'
     ShapeVector=(X=2.000000,Y=2.000000)
     VelocityMin=(X=-15.000000,Y=-15.000000,Z=-15.000000)
     VelocityMax=(X=15.000000,Y=15.000000,Z=15.000000)
     ScaleMin=0.300000
     ScaleMax=0.450000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=1.000000
     LifeSpanMax=1.700000
     AlphaStart=255
     bAlphaFade=True
     Style=STY_Translucent
     ScaleGlow=5.000000
     VisibilityRadius=800.000000
     VisibilityHeight=500.000000
}