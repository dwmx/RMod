//=============================================================================
// DarkDwarfExplosion.
//=============================================================================
class DarkDwarfExplosion expands ParticleSystem;

defaultproperties
{
     ParticleCount=32
     ParticleTexture(0)=Texture'RuneFX.explosion1'
     SystemLifeSpan=0.500000
     ShapeVector=(X=5.000000,Y=5.000000,Z=5.000000)
     VelocityMin=(X=-2000.000000,Y=-2000.000000)
     VelocityMax=(X=2000.000000,Y=2000.000000,Z=2000.000000)
     ScaleMin=0.300000
     ScaleMax=0.500000
     ScaleDeltaX=0.300000
     ScaleDeltaY=0.300000
     LifeSpanMin=0.400000
     LifeSpanMax=0.800000
     AlphaEnd=180
     bAlphaFade=True
     SpawnDelay=0.100000
     SpawnOverTime=0.500000
     Style=STY_Translucent
}
