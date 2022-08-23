//=============================================================================
// RuneSpheres.
//=============================================================================
class RuneSpheres expands ParticleSystem;

var float ElapsedTime;
var float MaxDeviation;


// init function
simulated function SystemInit()
{
	local int i;
	local float f;

	ElapsedTime = RandRange(0.0, 5.0);
	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Valid = True;
		ParticleArray[i].Velocity = vect(0,0,0);
		ParticleArray[i].Alpha = vect(1,1,1)*AlphaStart;
		ParticleArray[i].LifeSpan = LifeSpanMin + (LifeSpanMax-LifeSpanMin)*FRand();
		ParticleArray[i].TextureIndex = 0;
		ParticleArray[i].Style = Style;

		if (bRelativeToSystem)
			ParticleArray[i].Location = vect(0,0,0);
		else
			ParticleArray[i].Location = Location;

		// small sparks
		f = 0.25;
		ParticleArray[i].ScaleStartX = f;
		ParticleArray[i].ScaleStartY = f;
		ParticleArray[i].XScale = f;
		ParticleArray[i].YScale = f;
	}

	IsLoaded=true;
}

simulated function Tick(float DeltaTime)
{
	local int i;

	ElapsedTime += DeltaTime;
	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Location = Location +
			(vect(1,0,0) * Sin(ElapsedTime*(i+0.5)) * MaxDeviation) +
			(vect(0,1,0) * Cos(ElapsedTime*(i+0.5)) * MaxDeviation) +
			(vect(0,0,1) * (Sin(ElapsedTime)+1) * (i*0.05) * MaxDeviation);
	}
}

defaultproperties
{
     MaxDeviation=20.000000
     ParticleCount=10
     ParticleTexture(0)=Texture'RuneFX.Spark1'
     ShapeVector=(X=8.000000,Y=8.000000,Z=2.000000)
     VelocityMin=(X=0.300000,Y=0.300000,Z=50.000000)
     VelocityMax=(X=2.500000,Y=2.500000,Z=120.000000)
     ScaleMin=0.250000
     ScaleMax=0.250000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=999999.000000
     LifeSpanMax=999999.000000
     AlphaStart=10
     AlphaEnd=10
     bEventSystemInit=True
     RemoteRole=ROLE_SimulatedProxy
     Style=STY_Translucent
     ScaleGlow=3.000000
}
