//=============================================================================
// Explosion.
//=============================================================================
class Explosion expands ParticleSystem;

var float testfloat;

// init function
function SystemInit()
{
	local int i;
	local float f;

	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Valid = True;
		ParticleArray[i].Velocity = (VRand()+vect(0,0,1))*10;
		ParticleArray[i].Alpha = vect(1,1,1)*AlphaStart;
		ParticleArray[i].LifeSpan = LifeSpanMin + (LifeSpanMax-LifeSpanMin)*FRand();
		ParticleArray[i].TextureIndex = 0;
		ParticleArray[i].Style = Style;

		switch(i)
		{
		case 0: case 1: case 2: case 3: case 4: case 5:
			// Large explosions
			f = RandRange(1.0, 1.1);
			ParticleArray[i].Location = Location + VRand()*10;
			ParticleArray[i].ScaleStartX = f;
			ParticleArray[i].ScaleStartY = f;
			ParticleArray[i].XScale = f;
			ParticleArray[i].YScale = f;
			break;
		default:
			// smaller explosions
			f = RandRange(0.2, 0.3);
			ParticleArray[i].Location = Location + VRand()*50;
			ParticleArray[i].ScaleStartX = f;
			ParticleArray[i].ScaleStartY = f;
			ParticleArray[i].XScale = f;
			ParticleArray[i].YScale = f;
			ParticleArray[i].Velocity *= 2;
			ParticleArray[i].LifeSpan *= 0.5;
			break;
		}
	}

	IsLoaded=true;
}

function Tick(float DeltaTime)
{
	local int i;

	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Alpha.Y -= DeltaTime;
		ParticleArray[i].Alpha.Z -= DeltaTime;
	}
}

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=16
     ParticleTexture(0)=Texture'RuneFX.WaterBlood'
     ShapeVector=(X=8.000000,Y=8.000000,Z=2.000000)
     VelocityMin=(X=0.300000,Y=0.300000,Z=50.000000)
     VelocityMax=(X=2.500000,Y=2.500000,Z=120.000000)
     ScaleMin=0.700000
     ScaleMax=1.100000
     ScaleDeltaX=1.500000
     ScaleDeltaY=1.500000
     LifeSpanMin=0.500000
     LifeSpanMax=1.500000
     AlphaStart=10
     AlphaEnd=20
     bOneShot=True
     bEventSystemInit=True
     Style=STY_Translucent
     ScaleGlow=3.000000
}
