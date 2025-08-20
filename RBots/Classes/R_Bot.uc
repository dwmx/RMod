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

var PlayerPawn OwnedPlayerPawn;
var PlayerReplicationInfo OwnedPRI;

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

defaultproperties
{

}