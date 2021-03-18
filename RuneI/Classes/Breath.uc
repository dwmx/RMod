//=============================================================================
// Breath.
//=============================================================================
class Breath expands ParticleSystem;

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=10
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     SystemLifeSpan=1.500000
     ShapeVector=(X=3.000000,Y=3.000000,Z=3.000000)
     VelocityMin=(X=20.000000,Y=20.000000,Z=5.000000)
     VelocityMax=(X=30.000000,Y=30.000000,Z=10.000000)
     ScaleMin=0.100000
     ScaleMax=0.200000
     ScaleDeltaX=3.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=1.000000
     LifeSpanMax=1.500000
     AlphaStart=70
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-0.010000
     bApplyZoneVelocity=True
     ZoneVelocityScale=0.500000
     bOneShot=True
     SpawnDelay=0.600000
     SpawnOverTime=0.150000
     bDirectional=True
     Style=STY_Translucent
}
