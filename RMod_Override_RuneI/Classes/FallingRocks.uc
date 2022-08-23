//=============================================================================
// FallingRocks.
//=============================================================================

class FallingRocks expands ParticleSystem;

defaultproperties
{
     ParticleCount=10
     ParticleTexture(0)=Texture'RuneFX.browndust'
     OriginOffset=(Z=-8.000000)
     VelocityMin=(X=-15.000000,Y=-15.000000)
     VelocityMax=(X=15.000000,Y=15.000000)
     ScaleMin=0.100000
     ScaleMax=0.500000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=0.400000
     LifeSpanMax=0.900000
     AlphaStart=20
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.050000
     SpawnOverTime=1.000000
     Style=STY_Translucent
}
