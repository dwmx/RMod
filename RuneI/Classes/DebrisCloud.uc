//=============================================================================
// DebrisCloud.
//=============================================================================
class DebrisCloud expands ParticleSystem;

function SetRadius(float Radius)
{
	ScaleMin = 0.062500*0.9*Radius;
	ScaleMax = ScaleMin;
}

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=2
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     ScaleMin=1.000000
     ScaleMax=1.000000
     ScaleDeltaX=2.000000
     ScaleDeltaY=2.000000
     LifeSpanMin=0.800000
     LifeSpanMax=0.800000
     AlphaStart=200
     bAlphaFade=True
     GravityScale=0.100000
     bOneShot=True
     SpawnOverTime=0.150000
     bDirectional=True
     Style=STY_Translucent
}
