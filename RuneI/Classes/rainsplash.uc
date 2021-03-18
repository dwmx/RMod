//=============================================================================
// RainSplash.
//=============================================================================
class RainSplash expands ParticleSystem;

defaultproperties
{
     bSpriteInEditor=True
     ParticleCount=32
     ParticleTexture(0)=Texture'RuneFX.splash'
     ShapeVector=(X=128.000000,Y=128.000000,Z=2.000000)
     ScaleMin=0.250000
     ScaleMax=0.150000
     LifeSpanMin=0.200000
     LifeSpanMax=0.100000
     AlphaStart=35
     AlphaEnd=35
     SpawnOverTime=2.000000
     bForceRender=True
     Style=STY_Translucent
}
