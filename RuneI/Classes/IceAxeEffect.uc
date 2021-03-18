//=============================================================================
// IceAxeEffect.
//=============================================================================
class IceAxeEffect expands ParticleSystem;

defaultproperties
{
     ParticleCount=25
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     OriginOffset=(Y=-6.000000)
     ShapeVector=(X=5.000000,Y=5.000000,Z=-5.000000)
     ScaleMin=0.400000
     ScaleMax=0.700000
     ScaleDeltaX=0.500000
     ScaleDeltaY=0.500000
     LifeSpanMin=0.450000
     LifeSpanMax=1.000000
     AlphaStart=35
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-0.060000
     SpawnOverTime=2.000000
     Style=STY_Translucent
}
