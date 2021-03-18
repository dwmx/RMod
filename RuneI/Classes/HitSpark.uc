//=============================================================================
// HitSpark.
//=============================================================================
class HitSpark expands ParticleSystem;

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=15
     ParticleTexture(0)=Texture'RuneFX.SparkBlue'
     VelocityMin=(X=-50.000000,Y=-50.000000,Z=-50.000000)
     VelocityMax=(X=50.000000,Y=50.000000,Z=75.000000)
     ScaleMin=0.100000
     ScaleMax=0.200000
     ScaleDeltaX=0.300000
     ScaleDeltaY=0.300000
     LifeSpanMin=0.300000
     LifeSpanMax=0.700000
     AlphaStart=225
     AlphaEnd=175
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.650000
     bOneShot=True
     bDirectional=True
     Style=STY_Translucent
}
