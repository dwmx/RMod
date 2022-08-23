//=============================================================================
// PowerUp.
//=============================================================================
class PowerUp expands ParticleSystem;

defaultproperties
{
     ParticleCount=40
     ParticleTexture(0)=Texture'RuneFX.Deely1'
     ShapeVector=(X=65.000000,Y=65.000000,Z=80.000000)
     VelocityMin=(X=2.000000,Y=2.000000,Z=2.000000)
     VelocityMax=(X=5.000000,Y=5.000000,Z=5.000000)
     ScaleMin=0.100000
     ScaleMax=0.200000
     ScaleDeltaX=0.300000
     ScaleDeltaY=0.300000
     LifeSpanMin=0.100000
     LifeSpanMax=0.400000
     AlphaEnd=180
     bAlphaFade=True
     bConvergeX=True
     bConvergeY=True
     bConvergeZ=True
     SpawnDelay=0.100000
     SpawnOverTime=1.000000
     Style=STY_Translucent
}
