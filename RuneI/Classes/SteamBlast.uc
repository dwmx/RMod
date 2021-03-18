//=============================================================================
// SteamBlast.
//=============================================================================
class SteamBlast expands ParticleSystem;

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=10
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     ShapeVector=(X=6.000000,Y=6.000000,Z=1.000000)
     VelocityMin=(X=1.000000,Y=1.000000,Z=15.000000)
     VelocityMax=(X=4.000000,Y=4.000000,Z=40.000000)
     ScaleMin=0.200000
     ScaleMax=0.600000
     ScaleDeltaX=0.400000
     ScaleDeltaY=2.000000
     LifeSpanMin=0.800000
     LifeSpanMax=1.400000
     AlphaStart=55
     bAlphaFade=True
     bOneShot=True
     SpawnOverTime=0.300000
     Style=STY_Translucent
}
