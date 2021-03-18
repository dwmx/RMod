//=============================================================================
// GlowplantSparks.
//=============================================================================
class GlowplantSparks expands ParticleSystem;

defaultproperties
{
     ParticleCount=32
     ParticleTexture(0)=Texture'RuneFX.SparkBlue'
     ShapeVector=(X=14.000000,Y=14.000000)
     VelocityMin=(X=-15.000000,Y=-15.000000,Z=30.000000)
     VelocityMax=(X=15.000000,Y=15.000000,Z=80.000000)
     ScaleMin=0.100000
     ScaleMax=0.150000
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
