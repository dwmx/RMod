//=============================================================================
// Snow.
//=============================================================================
class Snow expands ParticleSystem;

defaultproperties
{
     bSpriteInEditor=True
     ParticleCount=64
     ParticleTexture(0)=Texture'RuneFX.Snow'
     ShapeVector=(X=500.000000,Y=500.000000,Z=75.000000)
     VelocityMin=(X=10.000000,Y=5.000000,Z=-50.000000)
     VelocityMax=(X=30.000000,Y=10.000000,Z=-100.000000)
     ScaleMin=0.500000
     ScaleMax=0.700000
     LifeSpanMin=3.000000
     LifeSpanMax=5.000000
     AlphaStart=128
     AlphaEnd=128
     bApplyZoneVelocity=True
     ZoneVelocityScale=0.500000
     SpawnOverTime=2.000000
     bForceRender=True
     Style=STY_Translucent
}
