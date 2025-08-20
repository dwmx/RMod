//==============================================================================
//	R_Bot
//	The brains and controller for bots
//==============================================================================
class R_Bot extends Actor;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'Bot';

const PATH_POINT_ARRAY_SIZE = 32;
var private Vector PathPoints[32];
var private int NumPathPoints;

var private R_PathFindData AttachedPathFindData;

var R_BotNavMesh CachedNavMesh;

var private PlayerPawn OwnedPlayerPawn;
var private PlayerReplicationInfo OwnedPRI;

var private R_Behavior ActiveBehavior;

var private Class<R_Behavior> InitialBehaviorClass;

var private Vector AccumulatedInputVector;
var private Vector LastInputVector;

const PATH_DISTANCE_TOLERANCE = 16.0;

function R_BotNavMesh GetNavMesh()
{
	local R_BotNavMesh LocalNavMesh;

	if(CachedNavMesh == None)
	{
		foreach AllActors(Class'RBots.R_BotNavMesh', LocalNavMesh)
		{
			break;
		}
		CachedNavMesh = LocalNavMesh;
	}
	
	return CachedNavMesh;
}

// Attaches PathFindData object to collect additional data from FindPath
function AttachPathFindData(R_PathFindData NewPathFindData)
{
	DetachPathFindData();
	AttachedPathFindData = NewPathFindData;
}

// Detaches, but does not destroy, current PathFindData object
function DetachPathFindData()
{
	if(AttachedPathFindData != None)
	{
		AttachedPathFindData = None;
	}
}

// Attempts to find a path between Start and End, and if successful, updates the Bot's path vars
// Returns true if path was found and updated
function bool TryUpdatePath(Vector Start, Vector End)
{
	local R_BotNavMesh LocalNavmesh;

	LocalNavMesh = GetNavMesh();
	if(LocalNavMesh != None)
	{
		return LocalNavMesh.FindPath(Start, End, PathPoints, NumPathPoints, AttachedPathFindData);
	}

	return false;
}

// Clears this Bot's current path
function ClearPath()
{
	NumPathPoints = 0;
}

function bool GetPathPoint(int Index, out Vector PathPoint)
{
	if(Index < 0 || Index >= NumPathPoints || Index >= PATH_POINT_ARRAY_SIZE)
	{
		Index = -1;
		PathPoint = Vect(0,0,0);
		return false;
	}

	PathPoint = PathPoints[Index];
	return true;
}

// Currently only implemented for PathBot
function bool GetDesiredPathStart(out Vector OutDesiredStart) { return false; }
function bool GetDesiredPathEnd(out Vector OutDesiredEnd) { return false; }

function int GetNumPathPoints()
{
	return NumPathPoints;
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
	Utilities.Static.RLog("Initializing bot" @ Self, LogCategory);
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

function R_Behavior GetActiveBehavior()
{
	return ActiveBehavior;
}

function SetBehavior(Class<R_Behavior> BehaviorClass)
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

event Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);

	if(OwnedPlayerPawn != None)
	{
		// Spawn fire to respawn, for now
		if(OwnedPlayerPawn.Health <= 0)
		{
			OwnedPlayerPawn.Fire();
		}
	}

	if(ActiveBehavior != None)
	{
		ActiveBehavior.BehaviorTick(DeltaSeconds);
	}

	TickMovement(DeltaSeconds);
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
	local Vector PawnLocation;
	local int ClosestIndex;
	local float ClosestDistance, CurrentDistance;
	local Vector P0, P1;
	local Vector Result;
	local float EndDistance;
	local int i;

	if(NumPathPoints == 0 || OwnedPlayerPawn == None)
	{
		return Vect(0,0,0);
	}

	PawnLocation = OwnedPlayerPawn.Location;
	ClosestIndex = -1;
	ClosestDistance = 999999.0f;
	for(i = 0; i < NumPathPoints; ++i)
	{
		CurrentDistance = VSize(PathPoints[i] - PawnLocation);
		if(CurrentDistance < ClosestDistance)
		{
			ClosestDistance = CurrentDistance;
			ClosestIndex = i;
		}
	}

	if(ClosestIndex == -1)
	{
		return Vect(0,0,0);
	}

	if(ClosestIndex == NumPathPoints - 1)
	{
		P0 = PathPoints[NumPathPoints - 2];
		P1 = PathPoints[NumPathPoints - 1];
	}
	else
	{
		P0 = PathPoints[ClosestIndex];
		P1 = PathPoints[ClosestIndex + 1];
	}

	EndDistance = VSize(Vect(1,1,0) * PathPoints[NumPathPoints - 1] - Vect(1,1,0) * PawnLocation);
	if(EndDistance <= PATH_DISTANCE_TOLERANCE)
	{
		return Vect(0,0,0);
	}

	if(DistanceFromLineSegment(PawnLocation, P0, P1) > 16)
	{
		Result = P0 - PawnLocation;
		Result.Z = 0.0;
	}
	else
	{
		Result = P1 - P0;
		Result.Z = 0.0;
	}

	return Normal(Result);
}

function float DistanceFromLineSegment(Vector Location, Vector P0, Vector P1)
{
	local Vector Delta0, Delta1;
	local Vector Offset;

	Location.Z = 0;
	P0.Z = 0;
	P1.Z = 0;

	Delta0 = P1 - P0;
	Delta0 = Normal(Delta0);
	Delta1 = Location - P0;

	return VSize(Delta1 - (Delta0 * (Delta1 Dot Delta0)));
}

function Vector GetLastInputVector()
{
	return LastInputVector;
}

defaultproperties
{
	//InitialBehaviorClass=Class'RBots.R_Behavior_Wander'
	InitialBehaviorClass=Class'RBots.R_Behavior_FindWeapon'
}