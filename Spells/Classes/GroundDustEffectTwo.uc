class GroundDustEffectTwo extends ParticleSystem;

event PostBeginPlay()
{
	Super.PostBeginPlay();
}

defaultproperties
{
	bSystemOneShot=false
    ParticleCount=32
    ParticleTexture(0)=FireTexture'RuneFX.Smoke'
    ShapeVector=(X=4.000000,Y=4.000000,Z=3.000000)
    VelocityMin=(X=-32.000000,Y=-32.000000,Z=2.000000)
    VelocityMax=(X=32.000000,Y=32.000000,Z=4.000000)
    ScaleMin=0.4
    ScaleMax=0.5
    ScaleDeltaX=10.0
    ScaleDeltaY=10.0
    LifeSpanMin=0.400000
    LifeSpanMax=0.600000
    AlphaStart=100
    bAlphaFade=True
    bApplyGravity=false
    GravityScale=-0.050000
    bOneShot=false
    bConvergeX=True
    bConvergeY=True
    SpawnOverTime=0.100000
    bDirectional=True
    Style=STY_Translucent
    bUnlit=True
}