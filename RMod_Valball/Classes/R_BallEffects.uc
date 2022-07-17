/////////////////////////////////////////////////////////////////////////////////
//	R_BallEffects
//	Client-side actor spawned to add effects to R_Ball
class R_BallEffects extends Actor;

var class<SpawnableLight> BallLightClass;
var SpawnableLight BallLights[6];

var class<R_BallEffect_Swipe> BallSwipeClass;
var R_BallEffect_Swipe BallSwipe;

simulated event Tick(float DeltaSeconds)
{
	if(Owner == None)
	{
		Destroy();
		return;
	}
	
	UpdateBallLights();
	UpdateBallSwipe();
}

simulated function UpdateBallLights()
{
	local int i;
	local Vector Normals[6];
	local Vector LightLocation;
	local Vector OffsetLocation;
	local float OffsetMagnitude;
	local Rotator OffsetRotator;
	
	if(Owner == None)
	{
		return;
	}
	
	OffsetLocation = Owner.Location;
	OffsetMagnitude = Owner.CollisionRadius;
	OffsetRotator = Owner.Rotation;
	
	Normals[0] = Vect(1.0, 0.0, 0.0);
	Normals[1] = Vect(-1.0, 0.0, 0.0);
	Normals[2] = Vect(0.0, 1.0, 0.0);
	Normals[3] = Vect(0.0, -1.0, 0.0);
	Normals[4] = Vect(0.0, 0.0, 1.0);
	Normals[5] = Vect(0.0, 0.0, -1.0);
	
	for(i = 0; i < 6; ++i)
	{
		if(BallLights[i] == None)
		{
			BallLights[i] = Spawn(BallLightClass, Self);
			if(BallLights[i] == None)
			{
				continue;
			}
		}
		
		LightLocation = (-1.0 * Normals[i] * OffsetMagnitude) >> OffsetRotator;
		LightLocation += OffsetLocation;
		
		BallLights[i].SetLocation(LightLocation);
		BallLights[i].LightRadius = LightRadius;
		BallLights[i].LightSaturation = LightSaturation;
		BallLights[i].LightCone = LightCone;
		BallLights[i].LightHue = LightHue;
		BallLights[i].LightBrightness = LightBrightness;
	}
}

simulated function UpdateBallSwipe()
{
	if(BallSwipe == None)
	{
		BallSwipe = Spawn(BallSwipeClass, Self);
		if(BallSwipe == None)
		{
			return;
		}
	}
}

simulated event Destroyed()
{
	local int i;
	
	// Destroy lights
	for(i = 0; i < 6; ++i)
	{
		if(BallLights[i] != None)
		{
			BallLights[i].Destroy();
		}
	}
	
	// Destroy ball swipe
	if(BallSwipe != None)
	{
		BallSwipe.Destroy();
	}
}

defaultproperties
{
     BallLightClass=Class'RuneI.DanglerLight'
     BallSwipeClass=Class'Rmod_Valball.R_BallEffect_Swipe'
     RemoteRole=ROLE_None
     DrawType=DT_None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     LightBrightness=250
     LightHue=150
     LightSaturation=100
     LightRadius=4
     LightCone=4
}
