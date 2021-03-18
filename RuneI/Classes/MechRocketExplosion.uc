//=============================================================================
// MechRocketExplosion.
//=============================================================================
class MechRocketExplosion expands ParticleSystem;

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=30
     ParticleTexture(0)=FireTexture'RuneFX.Flame'
     VelocityMin=(X=-50.000000,Y=-25.000000,Z=-25.000000)
     VelocityMax=(X=50.000000,Y=25.000000,Z=25.000000)
     ScaleMin=0.400000
     ScaleMax=1.800000
     ScaleDeltaX=0.700000
     ScaleDeltaY=0.700000
     LifeSpanMin=0.100000
     LifeSpanMax=0.500000
     AlphaStart=200
     AlphaEnd=75
     bAlphaFade=True
     bOneShot=True
     SpawnOverTime=0.200000
     bDirectional=True
     Style=STY_Translucent
}
