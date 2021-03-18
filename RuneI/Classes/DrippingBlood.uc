//=============================================================================
// DrippingBlood.
//=============================================================================

class DrippingBlood expands ParticleSystem;

defaultproperties
{
     ParticleCount=2
     ParticleTexture(0)=Texture'RuneFX2.blooddrop'
     OriginOffset=(Z=-3.000000)
     ScaleMin=0.300000
     ScaleMax=0.500000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=0.400000
     LifeSpanMax=0.750000
     AlphaStart=250
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.100000
     SpawnOverTime=1.500000
     Style=STY_Translucent
}
