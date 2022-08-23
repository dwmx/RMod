//=============================================================================
// FireRays.
//=============================================================================
class FireRays expands ParticleSystem;

defaultproperties
{
     ParticleCount=32
     ParticleTexture(0)=FireTexture'RuneFX.Flame'
     VelocityMin=(X=-0.300000,Y=-0.300000,Z=-0.300000)
     VelocityMax=(X=0.300000,Y=0.300000,Z=0.300000)
     ScaleMin=2.400000
     ScaleMax=2.500000
     ScaleDeltaX=1.900000
     ScaleDeltaY=2.200000
     LifeSpanMin=0.500000
     LifeSpanMax=0.900000
     AlphaStart=60
     bAlphaFade=True
     SpawnOverTime=0.500000
     Style=STY_Translucent
}
