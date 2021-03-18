//=============================================================================
// SeekerTrail.
//=============================================================================
class SeekerTrail expands ParticleSystem;

var float ElapsedTime;
var float MaxDeviation;


// init function
simulated function SystemInit()
{
	local int i;
	local float f;

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

		switch(i)
		{
		case 0:// case 1: case 2: case 3: case 4: case 5:
			// Large Spark
			f = RandRange(1.0, 1.1);
			//ParticleArray[i].Location += VRand()*5;
			ParticleArray[i].ScaleStartX = f;
			ParticleArray[i].ScaleStartY = f;
			ParticleArray[i].XScale = f;
			ParticleArray[i].YScale = f;
			break;
		default:
			// smaller sparks
			f = RandRange(0.2, 0.3);
			ParticleArray[i].Location += VRand()*10;
			ParticleArray[i].ScaleStartX = f;
			ParticleArray[i].ScaleStartY = f;
			ParticleArray[i].XScale = f;
			ParticleArray[i].YScale = f;
			//ParticleArray[i].Velocity *= 2;
			//ParticleArray[i].LifeSpan *= 0.5;
			break;
		}
	}

	IsLoaded=true;
}

simulated function Tick(float DeltaTime)
{
	local int i;
	local vector X,Y,Z;

	ElapsedTime += DeltaTime;
	GetAxes(Rotation, X,Y,Z);
	for (i=1; i<ParticleCount; i++)
	{
		ParticleArray[i].Location = (Y * Sin(ElapsedTime*i) * MaxDeviation) + (Z * Cos(ElapsedTime*i) * 2 * MaxDeviation);
	}
}

defaultproperties
{
     MaxDeviation=10.000000
     bRelativeToSystem=True
     ParticleCount=8
     ParticleTexture(0)=Texture'RuneFX.Spark1'
     ShapeVector=(X=8.000000,Y=8.000000,Z=2.000000)
     VelocityMin=(X=0.300000,Y=0.300000,Z=50.000000)
     VelocityMax=(X=2.500000,Y=2.500000,Z=120.000000)
     ScaleMin=0.700000
     ScaleMax=1.100000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=30.000000
     LifeSpanMax=30.000000
     AlphaStart=10
     AlphaEnd=10
     bEventSystemInit=True
     Style=STY_Translucent
     ScaleGlow=3.000000
}
