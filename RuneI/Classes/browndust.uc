//=============================================================================
// BrownDust.
//=============================================================================
class BrownDust expands ParticleSystem;

defaultproperties
{
     ParticleCount=10
     ParticleTexture(0)=Texture'RuneFX.browndust'
     ShapeVector=(X=6.000000,Y=6.000000,Z=6.000000)
     VelocityMin=(X=-1.000000,Y=-1.000000,Z=2.000000)
     VelocityMax=(X=-3.000000,Y=-3.000000,Z=4.000000)
     ScaleMin=0.200000
     ScaleMax=0.300000
     ScaleDeltaX=3.000000
     ScaleDeltaY=2.500000
     LifeSpanMin=0.150000
     LifeSpanMax=0.250000
     AlphaStart=75
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-0.050000
     bConvergeX=True
     bConvergeY=True
     Style=STY_AlphaBlend
     bUnlit=True
}
