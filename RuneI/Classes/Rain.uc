//=============================================================================
// Rain.
//=============================================================================
class Rain expands ParticleSystem;

defaultproperties
{
     bSpriteInEditor=True
     ParticleCount=64
     ParticleTexture(0)=Texture'RuneFX.Rain'
     ParticleSpriteType=PSPRITE_Vertical
     ShapeVector=(X=128.000000,Y=128.000000,Z=25.000000)
     VelocityMin=(Z=-200.000000)
     VelocityMax=(X=10.000000,Z=-300.000000)
     ScaleMin=0.400000
     ScaleMax=0.600000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.500000
     LifeSpanMin=0.600000
     LifeSpanMax=0.900000
     AlphaStart=100
     AlphaEnd=100
     bApplyGravity=True
     GravityScale=0.650000
     ZoneVelocityScale=0.200000
     SpawnOverTime=2.000000
     bForceRender=True
     Style=STY_Translucent
}
