//=============================================================================
// StoneHammerEffect.
//=============================================================================

class StoneHammerEffect expands ParticleSystem;

defaultproperties
{
     ParticleCount=10
     ParticleTexture(0)=Texture'RuneFX.Rock1'
     OriginOffset=(Z=-8.000000)
     VelocityMin=(X=-20.000000,Y=-20.000000)
     VelocityMax=(X=20.000000,Y=20.000000)
     ScaleMin=0.100000
     ScaleMax=0.500000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=0.400000
     LifeSpanMax=0.700000
     AlphaStart=20
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.050000
     SpawnOverTime=1.000000
     Style=STY_Translucent
}
