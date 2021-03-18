//=============================================================================
// VampireTrail.
//=============================================================================
class VampireTrail expands Effects;

var WeaponSwipe Swipe;
var() class<WeaponSwipe> SwipeClass;

var Pawn VampireDest;
var float ToDestVelocity;
var float alpha;
var int HealthBoost;

var() Sound	SpawnSound;
var() Sound HealthBoostSound;


replication
{
	reliable if (ROLE==ROLE_Authority)
		VampireDest;
}

function ServerBegin()
{
	PlaySound(SpawnSound, SLOT_Misc, 0.6,,, 0.9 + (FRand() * 0.2));
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	ToDestVelocity = 800 + 200 * FRand(); // velocity to the player
	alpha = 0;

	Swipe = Spawn(SwipeClass, self,, Location,);
	if(Swipe != None)
	{
		Swipe.RemoteRole=ROLE_None;		// Spawn on clients, don't replicate
		Swipe.BaseJointIndex = JointNamed('one');
		Swipe.OffsetJointIndex = JointNamed('two');
		Swipe.SystemLifeSpan = -1;
		Swipe.SwipeSpeed = 2;
		AttachActorToJoint(Swipe, JointNamed('one'));
	}

	ServerBegin();
}

simulated function Destroyed()
{
	if (Swipe!=None)
		Swipe.Destroy();
}

function ServerReachedDest()
{
	Spawn(Class'VampireReplenish',,, Location);
	
	// Flash the screen if the actor receiving the health is a Player
	if(VampireDest.IsA('PlayerPawn'))
		PlayerPawn(VampireDest).ClientFlash(-0.100, vect(200, 50, 50));

	// Give health to the actor when struck (TODO:  Remote Server function call)
	if(VampireDest.Health > 0)
	{
		VampireDest.Health += HealthBoost;
		if(VampireDest.Health > VampireDest.MaxHealth)
			VampireDest.Health = VampireDest.MaxHealth;
	}

	PlaySound(HealthBoostSound, SLOT_Misc, 0.6,,, 0.9 + (FRand() * 0.2));
}

simulated function Tick(float DeltaTime)
{
	local vector toDest;
	local float dist;
	local vector v;

	if(VampireDest == None)
	{
//		Destroy();
		return;
	}

	alpha += DeltaTime * 0.8;
	if(alpha > 1.0)
		alpha = 1.0;

	toDest = VampireDest.Location - Location;
	if(VSize(toDest) < 20)
	{
		ServerReachedDest();
		Destroy();
		return;
	}

	v = Velocity * (1.0 - alpha) + (ToDestVelocity * Normal(toDest)) * alpha + VRand() * 40;
	Velocity += Acceleration * DeltaTime;
	
	if(VSize(v) > 1000)
		v = 1000 * Normal(v);

	SetLocation(Location + v * DeltaTime);
}

defaultproperties
{
     SwipeClass=Class'RuneI.WeaponSwipeVampHealthTrail'
     SpawnSound=Sound'OtherSnd.Pickups.pickup04'
     HealthBoostSound=Sound'OtherSnd.Pickups.pickup01'
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_SkeletalMesh
     DrawScale=1.500000
     Skeletal=SkelModel'objects.FX_Trail'
}
