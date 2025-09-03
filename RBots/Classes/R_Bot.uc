//==============================================================================
//	R_Bot
//	The brains and controller for bots
//==============================================================================
class R_Bot extends Actor;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'Bot';

const NavLib = Class'RBots.R_NavLibrary';

var private bool bBotInitialized;

// BotObjects
var private R_BotObject BotObjects[16];

const BotObject_Perception = Class'RBots.R_BotPerception';

// Behavior
var private Class<R_BotBehavior> InitialBehaviorClass;
var private R_BotBehavior ActiveBehavior;

const Behavior_Fight = Class'RBots.R_BotBehavior_Fight';
const Behavior_FindWeapon = Class'RBots.R_BotBehavior_FindWeapon';
const Behavior_Wander = Class'RBots.R_BotBehavior_Wander';

// Player
var private PlayerPawn OwnedPlayerPawn;
var private PlayerReplicationInfo OwnedPRI;

// Navigation
var private R_NavMesh CachedNavMesh;
var private R_NavPath NavPath;
var private R_NavPathObserver AttachedNavPathObserver;
const PATH_DISTANCE_TOLERANCE = 16.0;

// Control
var private Vector AccumulatedInputVector;
var private Vector LastInputVector;

event BeginPlay()
{
	bBotInitialized = false;
}

function R_NavMesh GetNavMesh()
{
	local R_DynamicMapData MapData;

	if(CachedNavMesh == None)
	{
		foreach AllActors(Class'RBots.R_DynamicMapData', MapData)
		{
			CachedNavMesh = MapData.GetNavMesh();
			break;
		}
	}
	
	return CachedNavMesh;
}

// Attaches NavPathObserver object to collect additional data from FindPath
function AttachNavPathObserver(R_NavPathObserver NewNavPathObserver)
{
	DetachNavPathObserver();
	AttachedNavPathObserver = NewNavPathObserver;
}

// Detaches, but does not destroy, current NavPathObserver object
function DetachNavPathObserver()
{
	if(AttachedNavPathObserver != None)
	{
		AttachedNavPathObserver = None;
	}
}

// Get the currently attached NavPathObserver, or None
function R_NavPathObserver GetNavPathObserver()
{
	return AttachedNavPathObserver;
}

// Attempts to find a path between Start and End, and if successful, updates the Bot's path vars
// Returns true if path was found and updated
function bool TryUpdatePath(Vector Start, Vector End)
{
	local R_NavMesh LocalNavmesh;

	LocalNavMesh = GetNavMesh();
	if(LocalNavMesh != None)
	{
		return LocalNavMesh.FindPath(Start, End, NavPath, AttachedNavPathObserver);
	}

	return false;
}

// Clears this Bot's current path
function ClearPath()
{
	NavPath.Clear();
}

// Called by BotManager when granted a PlayerPawn
function PossessedPlayerPawn(PlayerPawn NewPlayerPawn)
{
	local PlayerReplicationInfo PRI;

	if(NewPlayerPawn == None)
	{
		Utilities.Static.RLog("Attempted to possess bad pawn:" @ NewPlayerPawn, LogCategory);
		return;
	}
	
	OwnedPlayerPawn = NewPlayerPawn;
	OwnedPlayerPawn.GotoState('PlayerWalking');
	Utilities.Static.RLog("Possessed player pawn" @ NewPlayerPawn, LogCategory);

	if(OwnedPlayerPawn.PlayerReplicationInfo != None)
	{
		OwnedPRI = OwnedPlayerPawn.PlayerReplicationInfo;
	}
	else
	{
		Utilities.Static.RLog("Failed to acquire reference to PRI", LogCategory);
	}

	InitPlayerReplicationInfo(OwnedPRI);
}

function InitPlayerReplicationInfo(PlayerReplicationInfo NewPRI)
{
	NewPRI.PlayerName = "IAmABot";
}

function InitializeBot()
{
	if(bBotInitialized)
	{
		return;
	}
	bBotInitialized = true;
	
	Utilities.Static.RLog("Initializing bot" @ Self, LogCategory);

	// Create BotObjects
	CreateBotObject(BotObject_Perception);

	// Spawn NavPath
	if(NavPath == None)
	{
		NavPath = new(None) Class'RBots.R_NavPath';
		NavPath.InitNavPath();
	}

	if(InitialBehaviorClass != None)
	{
		SetBehavior(InitialBehaviorClass);
	}
}

function PlayerPawn GetOwnedPlayerPawn()
{
	return OwnedPlayerPawn;
}

function PlayerReplicationInfo GetOwnedPRI()
{
	return OwnedPRI;
}

function R_BotBehavior GetActiveBehavior()
{
	return ActiveBehavior;
}

//	CreateBotObject
//	Main function for creating, initializating, and auto-managing bot subobjects
function R_BotObject CreateBotObject(Class<R_BotObject> BotObjectClass)
{
	local int i;

	if(BotObjectClass == None)
	{
		Utilities.Static.RLog("CreateBotObject failed -- BotObjectClass:" @ BotObjectClass, LogCategory);
		return None;
	}

	Utilities.Static.RLog("Creating BotObject from class" @ BotObjectClass, LogCategory);

	for(i = 0; i < ArrayCount(BotObjects); ++i)
	{
		if(BotObjects[i] == None)
		{
			break;
		}
	}

	if(i >= ArrayCount(BotObjects))
	{
		Utilities.Static.RLog("CreateBotObject failed -- BotObjects array overflow", LogCategory);
		return None;
	}

	BotObjects[i] = new(Self) BotObjectClass;
	if(BotObjects[i] == None)
	{
		Utilities.Static.RLog("CreateBotObject failed -- Failed to instantiate from BotObjectClass:" @ BotObjectClass, LogCategory);
		return None;
	}

	BotObjects[i].BaseInitBotObject(Self);
	return BotObjects[i];
}

function R_BotObject GetBotObjectByClass(Class<R_BotObject> BotObjectClass)
{
	local int i;

	for(i = 0; i < ArrayCount(BotObjects); ++i)
	{
		if(BotObjects[i] != None && BotObjects[i].Class == BotObjectClass)
		{
			return BotObjects[i];
		}
	}

	return None;
}

function SetBehavior(Class<R_BotBehavior> BehaviorClass)
{
	if(ActiveBehavior != None)
	{
		ActiveBehavior.BehaviorTerminated();
	}

	if(BehaviorClass != None)
	{
		ActiveBehavior = new(None) BehaviorClass;
		if(ActiveBehavior == None)
		{
			Utilities.Static.RLog("Failed to instantiate new active behavior from class" @ BehaviorClass, LogCategory);
		}
		else
		{
			ActiveBehavior.InitializeBehavior(Self, OwnedPlayerPawn);
			ActiveBehavior.BehaviorActivated();
		}
	}
}

function Class<R_BotBehavior> DetermineDesiredBehavior()
{
	local PlayerPawn P;

	P = GetOwnedPlayerPawn();
	if(P != None)
	{
		if(P.Weapon == None)
		{
			return Behavior_FindWeapon;
		}
		else
		{
			return Behavior_Fight;
		}
	}
}

event Tick(float DeltaSeconds)
{
	local Class<R_BotBehavior> DesiredBehavior;

	Super.Tick(DeltaSeconds);

	if(OwnedPlayerPawn != None)
	{
		// Spawn fire to respawn, for now
		if(OwnedPlayerPawn.Health <= 0)
		{
			OwnedPlayerPawn.Fire();
		}
	}

	// Tick BotObjects
	TickBotObjects(DeltaSeconds);

	// Tick Behavior
	DesiredBehavior = DetermineDesiredBehavior();
	if(DesiredBehavior != ActiveBehavior.Class)
	{
		SetBehavior(DesiredBehavior);
	}

	if(ActiveBehavior != None)
	{
		ActiveBehavior.BehaviorTick(DeltaSeconds);
	}

	TickMovement(DeltaSeconds);
}

//	TickBotObjects
//	Tick all bot objects created via CreateBotObject
//	BotObjects can disable their tick via SetTickBotObjectEnabled
function TickBotObjects(float DeltaSeconds)
{
	local int i;

	for(i = 0; i < ArrayCount(BotObjects); ++i)
	{
		if(BotObjects[i] != None)
		{
			BotObjects[i].BaseTickBotObject(DeltaSeconds);
		}
	}
}

function TickMovement(float DeltaSeconds)
{
	local Vector MovementVector;

	// Consume accumulated input vector
	MovementVector = Normal(AccumulatedInputVector) * FClamp(VSize(AccumulatedInputVector), 0.0, 1.0);
	AccumulatedInputVector = Vect(0,0,0);

	if(OwnedPlayerPawn != None)
	{
		OwnedPlayerPawn.Acceleration = OwnedPlayerPawn.AccelRate * MovementVector;
		LastInputVector = MovementVector;
	}
}

function AddMovementInput(Vector MovementInputVector)
{
	AccumulatedInputVector += MovementInputVector;
}

// Returns the movement input vector which will best follow the current path
function Vector GetPathFollowMovementInputVector()
{
	local Vector PawnLocation, PathLocation;
	local Vector P0, P1;
	local int ClosestIndex;
	local int NumPathLocations;
	local float EndDistance;
	local int i;
	local Vector Result;
	
	if(NavPath == None || OwnedPlayerPawn == None)
	{
		return Vect(0,0,0);
	}

	PawnLocation = OwnedPlayerPawn.Location;
	ClosestIndex = NavPath.GetClosestPathLocationIndex2D(PawnLocation);

	if(ClosestIndex == NavLib.Static.InvalidIndex())
	{
		return Vect(0,0,0);
	}

	NumPathLocations = NavPath.GetNumPathLocations();

	if(ClosestIndex == NumPathLocations - 1)
	{
		NavPath.GetPathLocation(NumPathLocations - 2, P0);
		NavPath.GetPathLocation(NumPathLocations - 1, P1);
	}
	else
	{
		NavPath.GetPathLocation(ClosestIndex, P0);
		NavPath.GetPathLocation(ClosestIndex + 1, P1);
	}

	NavPath.GetPathLocation(NumPathLocations - 1, PathLocation);
	EndDistance = VSize(Vect(1,1,0) * PathLocation - Vect(1,1,0) * PawnLocation);
	if(EndDistance <= PATH_DISTANCE_TOLERANCE)
	{
		return Vect(0,0,0);
	}

	if(NavLib.Static.DistanceLocationToLineSegment2D(PawnLocation, P0, P1) > PATH_DISTANCE_TOLERANCE)
	{
		Result = P0 - PawnLocation;
	}
	else
	{
		Result = P1 - P0;
	}

	Result = Result * Vect(1,1,0);	// XY Input only
	return Normal(Result);
}

function Vector GetLastInputVector()
{
	return LastInputVector;
}

defaultproperties
{
	//InitialBehaviorClass=Class'RBots.R_BotBehavior_Wander'
	InitialBehaviorClass=Class'RBots.R_BotBehavior_FindWeapon'
}