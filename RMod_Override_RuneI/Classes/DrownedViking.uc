//=============================================================================
// DrownedViking.
//=============================================================================
class DrownedViking expands RuneCarcass
	abstract;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	Velocity = vect(0, 0, 0);
	SetPhysics(PHYS_None);
	
	PrePivot.Z += 25;
	
	Enable('Tick');	
}

function Bump(Actor Other)
{
	local vector v;

	if(Other.Mass > Mass)
	{	
		v = Location - Other.Location;
		Velocity = Normal(v) * (Other.Mass - Mass);
		if(VSize(Velocity) > 150)
		{ // Cap the velocity
			Velocity = 150 * Normal(Velocity);			
		}
	}
	
}

simulated function Tick(float DeltaSeconds)
{
	local rotator r;
	local float velSize;
	local vector oldLoc;
	local vector vel;

	vel = Velocity + Region.Zone.ZoneVelocity;
	
	if(vel != vect(0, 0, 0))
	{
		oldLoc = Location;
		SetLocation(Location + vel * DeltaSeconds);
		if(!Region.Zone.bWaterZone)
		{ // Keep the body in the water
			SetLocation(oldLoc);
			Velocity.Z = -100;
		}
					
		velSize = VSize(vel);
		Velocity *= 0.98; // dampen
	}
	else
	{
		velSize = 0;
	}
	
	r = Rotation;
	r.Roll += (velSize * 50 + 300 + FRand() * 200) * DeltaSeconds;
	r.Yaw += (velSize * 50 + 300 + FRand() * 200) * DeltaSeconds;
	SetRotation(r);	
}

defaultproperties
{
     bLookFocusPlayer=True
     AnimSequence=DTH_ALL_death1_AN0N
     AnimFrame=0.950000
     LODPercentMax=0.300000
     CollisionRadius=30.000000
     CollisionHeight=35.000000
     bBlockActors=True
     bBlockPlayers=True
     Mass=20.000000
     Skeletal=SkelModel'Players.Ragnar'
}
