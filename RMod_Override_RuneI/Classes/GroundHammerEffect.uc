//=============================================================================
// GroundHammerEffect.
//=============================================================================
class GroundHammerEffect expands ParticleSystem;

defaultproperties
{
     ParticleCount=10
     ParticleTexture(0)=FireTexture'RuneFX.Flame'
     VelocityMin=(X=-20.000000,Y=-20.000000,Z=-20.000000)
     VelocityMax=(X=20.000000,Y=20.000000,Z=20.000000)
     ScaleMin=0.500000
     ScaleMax=0.700000
     ScaleDeltaX=0.500000
     ScaleDeltaY=0.500000
     LifeSpanMin=0.800000
     LifeSpanMax=0.800000
     AlphaStart=60
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.050000
     Style=STY_Translucent
}
