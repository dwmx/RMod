//=============================================================================
// BloodSpurt.
// Spurts blood for a small duration, then destroys itself, used on
// gore caps after a limb has been severed
//=============================================================================
class BloodSpurt extends ParticleSystem;

defaultproperties
{
     ParticleCount=10
     ParticleTexture(0)=Texture'BloodFX.blood04_b'
     bRandomTexture=True
     ShapeVector=(X=3.000000,Y=3.000000,Z=5.000000)
     VelocityMin=(X=-3.000000,Y=-3.000000,Z=30.000000)
     VelocityMax=(X=3.000000,Y=3.000000,Z=60.000000)
     ScaleMin=0.100000
     ScaleMax=0.300000
     ScaleDeltaX=0.400000
     ScaleDeltaY=0.400000
     LifeSpanMin=0.100000
     LifeSpanMax=0.400000
     AlphaStart=255
     AlphaEnd=255
     bApplyGravity=True
     GravityScale=0.600000
     SpawnOverTime=0.100000
     LifeSpan=10.000000
     Style=STY_Modulated
}
