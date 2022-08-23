//=============================================================================
// SwipeEffect.
//=============================================================================
class SwipeEffect expands ParticleSystem;

defaultproperties
{
     ParticleCount=20
     ParticleTexture(0)=Texture'RuneFX.swipe'
     ShapeVector=(X=4.000000,Y=4.000000,Z=4.000000)
     ScaleMin=10.000000
     ScaleMax=10.000000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=1.000000
     LifeSpanMax=1.000000
     AlphaStart=100
     bAlphaFade=True
     Style=STY_Translucent
}
