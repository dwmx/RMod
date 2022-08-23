//=============================================================================
// ActorGenerator.
//=============================================================================
class ActorGenerator expands Keypoint;

//
// To do:
//
// - Apply DLYType to Sleep (and expand enum DLYType)
// - Implement "initial rotation" direction velocity
// - Tweak values for direction weights
//

// EDITABLE INSTANCE VARIABLES ------------------------------------------------

var() class<actor>	ActorClass[4];
var() float			ActorProbability[4];
var() bool			bRandomPosition;
var() bool			bTriggerCreations;
var() bool			bMoveWhenUnreachable;	// For trialpit beast
var() bool			bRespawn;		// Multiplayer, if false the object will not respawn
var() float			DelayAlways;
var() float			DelayRandom;
var() name			SpawnOrders;
var() name			SpawnOrdersTag;
var() enum DLYType
{
	DLY_STEADY,
	DLY_INCREASE,
	DLY_DECREASE
} DelayType;
var() float			DirectionWeight;
var() float			DirectionWeightRandom;
var() byte			QuantityAlways;
var() byte			QuantityRandom;
var() bool			bLoopForever;
var() bool			bInitiallyActive;
var() name			SpawnWithEvent;
var() name			SpawnWithTag;
var() class<Weapon>	SpawnWithWeapon;
var() class<Shield>	SpawnWithShield;
var() int			SpawnWithHealth;
var() float			SpawnWithDrawScale;
var() float			SpawnWithHuntDistance;
var() bool			bSpawnWithNoWeapon;
var() bool			bSpawnWithNoShield;
var() name			SpawnWithTriggerOrders;
var() name			SpawnWithTriggerOrdersTag;
var() name			SpawnWithAlertOrders;
var() name			SpawnWithAlertOrdersTag;
//var() class<Sark>	ZombieSarkClass; // Type of Sark that zombies will transform into


// INSTANCE VARIABLES ---------------------------------------------------------

var int TotalActorCount;
var actor TOther;
var pawn TEventInstigator;
var class<actor> AdjustedClass[4];
var float AdjustedProbability[4];
var int ClassCount;

// FUNCTIONS ------------------------------------------------------------------

function BeginPlay()
{
	local int i;
	local float totalProb;

	totalProb = 0.0;
	ClassCount = 0;
	for(i = 0; i < 4; i++)
	{
		if(ActorClass[i] == None || ActorProbability[i] ~= 0.0)
			continue;
		AdjustedClass[ClassCount] = ActorClass[i];
		totalProb += ActorProbability[i];
		AdjustedProbability[ClassCount] = totalProb;
		ClassCount++;
	}
	if(ClassCount > 0)
		for(i = 0; i < ClassCount; i++)
			AdjustedProbability[i] /= totalProb;
}


function SpawnNewActor()
{
	local actor newActor;
	local vector newLocation;
	local vector X,Y,Z;

	newActor = Spawn(GenRandClass());
	if(newActor == None)
		return;

	newLocation = Location;
	if(bRandomPosition)
	{
		newLocation.x += FRand()*CollisionRadius*2 - CollisionRadius;
		newLocation.y += FRand()*CollisionRadius*2 - CollisionRadius;
		newLocation.z += FRand()*CollisionHeight*2 - CollisionHeight;
	}
	newActor.SetLocation(newLocation);

	if (DirectionWeightRandom != 0)
	{
		newActor.Velocity = VRand()*100*DirectionWeightRandom;
		newActor.Velocity.z = 0;
	}
	else
	{
		GetAxes(Rotation, X,Y,Z);
		newActor.Velocity = X*DirectionWeight;
	}

	if (SpawnWithEvent != '')
		newActor.Event = SpawnWithEvent;
	if (SpawnWithTag != '')
		newActor.Tag = SpawnWithTag;

	newActor.DrawScale *= SpawnWithDrawScale;

	if (ScriptPawn(newActor) != None)
	{
		if (SpawnOrders != '')
			ScriptPawn(newActor).Orders = SpawnOrders;

		if (SpawnOrdersTag != '')
			ScriptPawn(newActor).OrdersTag = SpawnOrdersTag;

		if (SpawnWithTriggerOrders != '')
			ScriptPawn(newActor).TriggerOrders = SpawnWithTriggerOrders;

		if (SpawnWithTriggerOrdersTag != '')
			ScriptPawn(newActor).TriggerOrdersTag = SpawnWithTriggerOrdersTag;

		if (SpawnWithAlertOrders != '')
			ScriptPawn(newActor).AlertOrders = SpawnWithAlertOrders;

		if (SpawnWithAlertOrdersTag != '')
			ScriptPawn(newActor).AlertOrdersTag = SpawnWithAlertOrdersTag;

		if(bSpawnWithNoWeapon)
			ScriptPawn(newActor).StartWeapon = None;			
		else if(SpawnWithWeapon != None)
			ScriptPawn(newActor).StartWeapon = SpawnWithWeapon;

		if(bSpawnWithNoShield)
			ScriptPawn(newActor).StartShield = None;			
		else if(SpawnWithShield != None)
			ScriptPawn(newActor).StartShield = SpawnWithShield;

		if (SpawnWithHealth != 0)
			ScriptPawn(newActor).Health = SpawnWithHealth;

		if (SpawnWithHuntDistance != 0)
			ScriptPawn(newActor).HuntDistance = SpawnWithHuntDistance;

/* No longer able to select type of sark a zombie will turn into.  They always transform into Spawn
		// For zombies, set the Sark type that this zombie can transform into
		if(newActor.IsA('Zombie') && ZombieSarkClass != None)
		{
			Zombie(newActor).SarkClass = ZombieSarkClass;
		}
*/
		// Set up whether the scriptpawn should stand still when the enemy is unreachable
		ScriptPawn(newActor).bMoveWhenUnreachable = bMoveWhenUnreachable;
	}

	if(Inventory(newActor) != None && !bRespawn)
	{ // If bRespawn if false, then don't allow the actor to respawn in multiplayer
		Inventory(newActor).RespawnTime = 0;
	}

	if(bTriggerCreations)
		newActor.Trigger(TOther, TEventInstigator);
}

function class<Actor> GenRandClass()
{
	local float p;
	local int i;

	p = FRand();
	for(i = 0; i < ClassCount; i++)
		if(p < AdjustedProbability[i])
			return AdjustedClass[i];

	return None;
}

// STATES ---------------------------------------------------------------------

auto state Waiting
{
	function BeginState()
	{
		if (bInitiallyActive)
		{
			bInitiallyActive = false;
			Trigger(self, None);
		}
	}

	function Trigger(actor other, pawn eventInstigator)
	{
		if(ClassCount > 0)
		{
			TOther = other;
			TEventInstigator = eventInstigator;
			GotoState('GenerateActors');
		}
	}

}


state GenerateActors
{
	function BeginState()
	{
		TotalActorCount = QuantityAlways + Rand(QuantityRandom+1);
	}

	function Trigger(actor other, pawn eventInstigator)
	{
		GotoState('Waiting');
	}

begin:
	while(TotalActorCount > 0 || bLoopForever)
	{
		SpawnNewActor();
		Sleep(DelayAlways + FRand()*DelayRandom);
		TotalActorCount--;
	}
	GotoState('Waiting');
}

defaultproperties
{
     bRespawn=True
     SpawnWithDrawScale=1.000000
     bStatic=False
     bDirectional=True
     CollisionRadius=32.000000
     CollisionHeight=8.000000
}
