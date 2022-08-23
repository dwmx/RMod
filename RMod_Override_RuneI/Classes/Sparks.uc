//=============================================================================
// Sparks.
//=============================================================================
class Sparks expands ParticleSystem;

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=20
     ParticleTexture(0)=Texture'RuneFX.Spark1'
     ParticleTexture(1)=Texture'RuneFX.Spark3'
     ShapeVector=(X=6.000000,Y=6.000000,Z=6.000000)
     VelocityMin=(X=50.000000,Y=50.000000,Z=80.000000)
     VelocityMax=(X=80.000000,Y=80.000000,Z=120.000000)
     ScaleMin=0.100000
     ScaleMax=0.200000
     ScaleDeltaX=1.500000
     ScaleDeltaY=1.500000
     LifeSpanMin=0.300000
     LifeSpanMax=0.600000
     AlphaStart=200
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.500000
     bOneShot=True
     SpawnOverTime=0.200000
     TextureChangeTime=0.150000
     bDirectional=True
     Style=STY_Translucent
}
