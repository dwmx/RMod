//=============================================================================
// GroundDust.
//=============================================================================
class GroundDust expands ParticleSystem;

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=25
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     ShapeVector=(X=25.000000,Y=25.000000,Z=3.000000)
     VelocityMin=(X=-1.000000,Y=-1.000000,Z=2.000000)
     VelocityMax=(X=-3.000000,Y=-3.000000,Z=4.000000)
     ScaleMin=0.400000
     ScaleMax=0.600000
     ScaleDeltaX=3.000000
     ScaleDeltaY=2.500000
     LifeSpanMin=0.400000
     LifeSpanMax=0.600000
     AlphaStart=80
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-0.050000
     bOneShot=True
     bConvergeX=True
     bConvergeY=True
     SpawnOverTime=0.100000
     bDirectional=True
     Style=STY_Translucent
     bUnlit=True
}
