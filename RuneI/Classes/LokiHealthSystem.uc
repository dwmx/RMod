//=============================================================================
// LokiHealthSystem.
//=============================================================================
class LokiHealthSystem expands ParticleSystem;

defaultproperties
{
     ParticleCount=6
     ParticleTexture(0)=Texture'RuneFX.Deely1'
     ShapeVector=(X=4.000000,Y=4.000000,Z=4.000000)
     VelocityMin=(X=5.000000,Y=5.000000,Z=10.000000)
     VelocityMax=(X=10.000000,Y=10.000000,Z=20.000000)
     ScaleMin=0.050000
     ScaleMax=0.080000
     LifeSpanMin=0.200000
     LifeSpanMax=0.300000
     AlphaStart=80
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.200000
     Style=STY_Translucent
}
