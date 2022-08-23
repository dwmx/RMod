//=============================================================================
// DealieFishSchool.
//=============================================================================
class DealieFishSchool extends FlockMasterPawn;

var() byte schoolsize;
var  byte	activeFish;
var() float schoolradius;
var bool	validDest;
var bool	bSawPlayer;
var vector StartLocation;

function Texture PainSkin(int BodyPart)
{
}

function PreSetMovement()
{
	bCanSwim = true;
	bCanFly = true;
	MinHitWall = -0.6;
}

function PostBeginPlay()
{
	StartLocation = Location;
	Super.PostBeginPlay();
}

singular function ZoneChange( ZoneInfo NewZone )
{
	local Dealiefish aFish;
	if (!NewZone.bWaterZone)
	{
		if ( !SetLocation(OldLocation) || (!Region.Zone.bWaterZone) )
			SetLocation(StartLocation);
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		MoveTimer = -1.0;
	}
	SetPhysics(PHYS_Swimming);
}

singular function HeadZoneChange( ZoneInfo NewZone )
{
	local Dealiefish aFish;
	if ( (MoveTarget!=Enemy) && !NewZone.bWaterZone)
	{
		Destination.Z = Location.Z - 50;
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		MoveTimer = -1.0;
	}
}

function FishDied()
{
	activeFish--;
	if (activeFish == 0)
		destroy();
}

function RemoveFish()
{
	local Dealiefish aFish;
	local Pawn aPawn;

	aPawn = Level.PawnList;
	While ( aPawn != None )
	{
		aFish = Dealiefish(aPawn);
		if ( (aFish != None) && (aFish.School == self) && !aFish.PlayerCanSeeMe() )
			Remove(aFish);
		aPawn = aPawn.NextPawn;
	}
}	

function Remove(Dealiefish aFish)
{
	schoolsize++;
	activeFish--;
	SetTimer(1.0, false);		// Replentish the school
	aFish.Destroy();
}

function ReplentishOne()
{
	schoolsize++;
	activeFish--;
	SetTimer(1.0, false);		// Replentish the school
}

function SpawnFish()
{
	if ( schoolsize > 0 )
		Timer();
}

function Timer()
{
	if ( schoolsize > 0 )
		SpawnAFish();
	if ( schoolsize > 0 )
		SpawnAFish();
	if ( schoolsize > 0 )
		SpawnAFish();
	if ( schoolsize > 0 )
		SetTimer(0.1, false);
}

function SpawnAFish()
{
	local DealieFish fish;

	fish = spawn(class 'DealieFish', self, '', Location + VRand() * CollisionRadius);
	if (fish != None)
	{
		schoolsize--;
		activeFish++;
	}
}

auto state stasis
{
ignores EncroachedBy, FootZoneChange;
	
	function SeePlayer(Actor SeenPlayer)
	{
		enemy = Pawn(SeenPlayer);
		SpawnFish();
		Gotostate('wandering');
	}

Begin:
	SetPhysics(PHYS_None);
CleanUp:
	if ( activeFish > 0 )
	{
		Sleep(1.0);
		RemoveFish();
		Goto('Cleanup');
	}
}		

state wandering
{
ignores EncroachedBy, FootZoneChange;

	function SeePlayer(Actor SeenPlayer)
	{
		bSawPlayer = true;
		Enemy = Pawn(SeenPlayer);
		Disable('SeePlayer');
		Enable('EnemyNotVisible');
	}

	function EnemyNotVisible()
	{
		Enemy = None;
		Disable('EnemyNotVisible');
		Enable('SeePlayer');
	}
	
	function PickDestination()
	{
		local actor hitactor;
		local vector hitnormal, hitlocation;
		
		Destination = Location + VRand() * 1000;
		Destination.Z = 0.5 * (Destination.Z - 250 + Location.Z);
		HitActor = Trace(HitLocation, HitNormal, Destination, Location, false);
		if ( (HitActor != None) && (VSize(HitLocation - Location) < 1.5 * CollisionRadius) )
		{
			Destination = 2 * Location - Destination;
			HitActor = Trace(HitLocation, HitNormal, Destination, Location, false);
		}
		if (HitActor != None)
			Destination = HitLocation - CollisionRadius * Normal(Destination - Location);
	}
	
Begin:
	SetPhysics(PHYS_Swimming);
	
Wander:
	if (Enemy == None)
	{
		bSawPlayer = false;
		Sleep(5.0);
		if ( !bSawPlayer )
		{
			RemoveFish();
			GotoState('Stasis');
		}
		else if ( Enemy == None )
			Goto('Wander');
	}

	validDest = false;	
	MoveTarget = None;
	PickDestination();
	MoveTo(Destination);

	validDest = true;
	if ( FRand() < 0.1 )
		Sleep(5 + 6 * FRand());
	else
		Sleep(0.5 + 2 * FRand());
	Goto('Wander');
}

//------------------------------------------------------------
//
// STATE SplinePath
//
// Used to script a dealie fish school swimming on a particular path
//------------------------------------------------------------

state() SplinePath
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, PainTimer, Landed;

	function Trigger(actor other, pawn eventInstigator)
	{
		local InterpolationPoint i;

		if(Event != 'None')
			foreach AllActors(class 'InterpolationPoint', i, Event)
				if(i.Position == 0)
				{ // Found a matching path
					SpawnFish(); // Spawn the fish to follow this leader
					validDest = true; // Tell the fish that this school location is always valid

					SetCollision(true, false, false);
					bCollideWorld = False;
					Target = i;
					SetPhysics(PHYS_Interpolating);
					PhysRate = 1.0;
					PhysAlpha = 0.0;
					bInterpolating = true;
					return;
				}
	}

begin:
}

defaultproperties
{
     schoolsize=12
     schoolradius=150.000000
     WaterSpeed=500.000000
     AirSpeed=800.000000
     AccelRate=4000.000000
     PeripheralVision=-5.000000
     UnderWaterTime=-1.000000
     bHidden=True
     SoundRadius=7
     SoundVolume=66
     SoundPitch=137
     AmbientSound=Sound'EnvironmentalSnd.Bubbles.bubbleswater01L'
     CollisionRadius=50.000000
     CollisionHeight=100.000000
     Mass=10.000000
     Buoyancy=10.000000
}
