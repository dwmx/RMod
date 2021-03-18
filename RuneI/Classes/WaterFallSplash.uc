//=============================================================================
// WaterFallSplash.
//=============================================================================
class WaterFallSplash expands splash;

/*
Usage: Place at bottom of waterfall (middle widht, on the water (if too low, will see particles come underwater
		Aim outwards from the waterfall (towards the direction the player will probably be... Set RadiusSpan
NOTE: Ripples are provided, but should only be used if neccessary (does SPAWN individual actors...) mc
*/

var(WaterFallSplash) int VerticalIntensity;
var(WaterFallSplash)  int HorizontalIntensity;
var(WaterFallSplash) int RadiusSpan;

var(Splash) bool bCreateRipples;

var vector offsetVect;
var vector rotVect;

function PostBeginPlay()
{
	local int i;
	
	
	
	Super.PostBeginPlay();

   //Get the vector orthogonal to the rotation, so that we know which direction to expand in....
    rotVect = vector(Rotation);
	offsetVect = (rotVect cross vect(0,0,1)) * RadiusSpan;
	
	
}


simulated function SystemInit()
{
	local int i;
		
	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Valid = True;
		ParticleArray[i].Alpha = vect(1,1,1)*AlphaStart;
		ParticleArray[i].LifeSpan = LifeSpanMax;
		ParticleArray[i].TextureIndex = NumTextures * FRand();
		ParticleArray[i].Style = Style;
		ParticleArray[i].ScaleStartX = 0.1;
		ParticleArray[i].ScaleStartY = 0.1;
		ParticleArray[i].XScale = 0.1;
		ParticleArray[i].YScale = 0.1;
	
			//Set Up The Velocity of the Particles (based on the rotation, and the Horz & Vert Intensities...)	
		ParticleArray[i].Velocity = rotVect * HorizontalIntensity * FRand();
		ParticleArray[i].Velocity.Z = VerticalIntensity * FRand();
		
			//Set Location of Particle, somewhere along the orthogonal to the rotation...
		ParticleArray[i].Location = Location + 2 * (FRand() - 0.5) * offsetVect;
	}
		
	RippleDelay = 0;	//For use of delaying ripples (if used)
	IsLoaded=true;
}


simulated function Tick(float DeltaTime)
{
	local int i;

	
	for (i=0; i<ParticleCount; i++)
	{
		if(ParticleArray[i].Valid)
		 {
		 		//Update Location
	     ParticleArray[i].Location =
	        ParticleArray[i].Location + (ParticleArray[i].Velocity * DeltaTime);
	    	 
	    	 	//If at level of the spawner AND velocity is downward, reset particle (and maybe create ripple)
	     if(ParticleArray[i].Velocity.Z < 0 && ParticleArray[i].Location.Z < Location.Z)
	     { 
	      if(bCreateRipples) 
	      {
	       //Check to see if it is okay to create a ripple yet (minimizes overhead of too many actors)
	       if(++RippleDelay >= RippleChance)
	       {
	        spawn(SpawnRipple, self, , ParticleArray[i].Location, rot(0,0,0));
	        RippleDelay = 0;
	       }
	      }//End if(bCreateRipples)
	      
	      ParticleReset(i);		//Reset the particle (is a never-ending system)  
	     }
		}
	}//End For-Loop
}


		//Reset the passed-in Particle
function ParticleReset(int partIndex)
{
 ParticleArray[partIndex].LifeSpan = LifeSpanMax;
 ParticleArray[partIndex].Velocity = rotVect * HorizontalIntensity * FRand();
 ParticleArray[partIndex].Velocity.Z = VerticalIntensity * FRand();		
 ParticleArray[partIndex].Location = Location + 2 * (FRand() - 0.5) * offsetVect;
}

Simulated function Debug(Canvas canvas, int mode)
{
  	Super.Debug(canvas, mode);
	Canvas.DrawText("WaterFallSplash:");
	Canvas.CurY -= 8;
	
	Canvas.DrawLine3D(Location + offsetVect, Location - offsetVect, 0,255,255);
	Canvas.DrawLine3D(Location, Location + rotVect * 20, 255,255,255);
}

defaultproperties
{
     VerticalIntensity=100
     HorizontalIntensity=50
     RadiusSpan=60
     RippleChance=15
     bSystemOneShot=False
     SystemLifeSpan=999999.000000
     LifeSpanMin=999999.000000
     LifeSpanMax=999999.000000
     bWaterOnly=False
     bOneShot=False
     bForceRender=True
     bDirectional=True
     CollisionRadius=50.000000
}
