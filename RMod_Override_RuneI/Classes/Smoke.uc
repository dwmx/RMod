//=============================================================================
// Smoke.
//=============================================================================
class Smoke expands ParticleSystem;

defaultproperties
{
     ParticleCount=50
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     ShapeVector=(X=10.000000,Y=10.000000,Z=4.000000)
     VelocityMin=(Z=80.000000)
     VelocityMax=(Z=100.000000)
     ScaleMin=0.800000
     ScaleMax=1.000000
     ScaleDeltaX=1.600000
     ScaleDeltaY=1.250000
     LifeSpanMin=0.650000
     LifeSpanMax=1.000000
     AlphaStart=40
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-0.100000
     SpawnOverTime=1.000000
     Style=STY_Translucent
     bUnlit=True
     AmbientSound=Sound'EnvironmentalSnd.Steam.steam11L'
}
