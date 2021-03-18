//=============================================================================
// Splash.
//=============================================================================
class Splash expands ParticleSystem;
//You can change the type of Ripple if you need a different one (e.g. for Mud instead....) 
//NOTE: Keep RippleChance low, or you may have too much overhead if things get busy... mc

var(Splash) class<Ripple> SpawnRipple; //Which type of ripple to spawn on contact.
var(Splash) int NumTextures; //Number of textures to randomly pick from.
var(Splash) int RippleChance;  //Create a ripple every Nth time...

var int RippleDelay; //Keeps track of how long it has been since we have been allowed to create a ripple

simulated function SystemInit()
{
	local int i;
		
	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Valid = True;
		ParticleArray[i].Velocity.X = VelocityMin.X + (VelocityMax.X-VelocityMin.X)*FRand();
		ParticleArray[i].Velocity.Y = VelocityMin.Y + (VelocityMax.Y-VelocityMin.Y)*FRand();
		ParticleArray[i].Velocity.Z = VelocityMin.Z + (VelocityMax.Z-VelocityMin.Z)*FRand();
		
 		ParticleArray[i].Alpha = vect(1,1,1)*AlphaStart;
		ParticleArray[i].LifeSpan = LifeSpanMin + (LifeSpanMax-LifeSpanMin)*FRand();
		
		
		ParticleArray[i].TextureIndex = NumTextures * FRand();
		ParticleArray[i].Style = Style;

		ParticleArray[i].Location = Location;

		ParticleArray[i].ScaleStartX = 0.15;
		ParticleArray[i].ScaleStartY = 0.15;
		ParticleArray[i].XScale = 0.15;
		ParticleArray[i].YScale = 0.15;
	}

	RippleDelay = 0;
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
	    	 
	    	 	//If at level of the spawner AND velocity is downward, invalidate and cause ripple..
	     if(ParticleArray[i].Velocity.Z < 0 && ParticleArray[i].Location.Z < Location.Z)
	     {
	      ParticleArray[i].Valid = False;
	    	  
	      //Check to see if it is okay to create a ripple yet (minimizes overhead of too many actors)
	      if(++RippleDelay >= RippleChance)
	      {
	       spawn(SpawnRipple, self, , ParticleArray[i].Location, rot(0,0,0));
	       RippleDelay = 0;
	      }
	     }
		}
	}//End For-Loop
}

defaultproperties
{
     SpawnRipple=Class'RuneI.DropRipple'
     NumTextures=4
     RippleChance=4
     bSystemOneShot=True
     ParticleCount=40
     ParticleTexture(0)=Texture'RuneFX.splash1'
     ParticleTexture(1)=Texture'RuneFX.splash2'
     ParticleTexture(2)=Texture'RuneFX.splash3'
     ParticleTexture(3)=Texture'RuneFX.splash4'
     bRandomTexture=True
     ShapeVector=(X=10.000000,Y=10.000000,Z=4.000000)
     VelocityMin=(X=-50.000000,Y=-50.000000,Z=60.000000)
     VelocityMax=(X=50.000000,Y=50.000000,Z=120.000000)
     ScaleMin=0.400000
     ScaleMax=0.500000
     ScaleDeltaX=0.200000
     ScaleDeltaY=0.300000
     LifeSpanMin=1.000000
     LifeSpanMax=1.000000
     AlphaStart=250
     AlphaEnd=115
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.250000
     bApplyZoneVelocity=True
     bWaterOnly=True
     bOneShot=True
     SpawnOverTime=0.500000
     bEventSystemInit=True
     bStasis=False
     Style=STY_Translucent
}
