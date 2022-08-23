//=============================================================================
// RespawnFire.
//=============================================================================
class RespawnFire expands Fire;

defaultproperties
{
     bSystemOneShot=True
     ParticleTexture(0)=Texture'RuneFX.SARKFIRE'
     ShapeVector=(X=15.000000,Y=15.000000,Z=5.000000)
     VelocityMin=(X=0.500000,Y=0.500000,Z=25.000000)
     VelocityMax=(X=2.200000,Y=2.200000,Z=35.000000)
     ScaleMin=1.000000
     ScaleMax=1.500000
     LifeSpanMin=1.000000
     LifeSpanMax=1.300000
     AlphaStart=100
     bOneShot=True
     AmbientSound=None
}
