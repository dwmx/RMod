//==============================================================================
//	R_DynamicMapData
//	Defines all data which should be dynamically loaded on a per-map basis
//==============================================================================
class R_DynamicMapData extends Actor abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'DynamicMapData';

var Class<R_NavMesh> NavMeshClass;
var R_NavMesh NavMesh;

var Class<R_NavMeshActorTracker> NavMeshActorTrackerClass;
var R_NavMeshActorTracker NavMeshActorTracker;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	InitializeNavMesh();
	InitializeNavMeshActorTracker();
	AddInitialTrackedActors();
}

final function InitializeNavMesh()
{
	local String FailedLogString;

	if(NavMeshClass == None)
	{
		Utilities.Static.RLog("No NavMeshClass configured for" @ Self, LogCategory);
	}
	else
	{
		NavMesh = new(None) NavMeshClass;
		if(NavMesh == None)
		{
			Utilities.Static.RLog("Failed to spawn NavMesh from class" @ NavMeshClass, LogCategory);
		}
		else
		{
			Utilities.Static.RLog("Instantiated NavMesh from class:" @ NavMeshClass @ " -- Initializing and building", LogCategory);
			NavMesh.InitializeNavMeshBase();
			BuildNavMesh(); // Subclass will construct the NavMesh here

			// Validate the constructed NavMesh
			if(!NavMesh.ValidateNavMesh(FailedLogString))
			{
				Utilities.Static.RLog("NavMesh validation failed:" @ FailedLogString, LogCategory);
			}
			else
			{
				Utilities.Static.RLog("NavMesh built and validated, now post-processing", LogCategory);
				NavMesh.PostProcessNavMeshBase();
			}
		}
	}
}

final function InitializeNavMeshActorTracker()
{
	if(NavMeshActorTrackerClass == None)
	{
		Utilities.Static.RLog("Failed to initialize NavMeshActorTracker -- NavMeshActorTrackerClass:" @ NavMeshActorTrackerClass, LogCategory);
		return;
	}

	NavMeshActorTracker = new(None) NavMeshActorTrackerClass;
	if(NavMeshActorTracker == None)
	{
		Utilities.Static.RLog("Failed to initialize NavMeshActorTracker -- Instantiation failed", LogCategory);
		return;
	}

	NavMeshActorTracker.SetNavMesh(NavMesh);
	Utilities.Static.RLog("Initialized NavMeshActorTracker", LogCategory);
}

function AddInitialTrackedActors()
{
	local Inventory I;

	// Track all Inventorys
	foreach AllActors(Class'Engine.Inventory', I)
	{
		NavMeshActorTracker.TrackActor(I);
	}
}

function BuildNavMesh(); // To be implemented in subclasses

function R_NavMesh GetNavMesh() { return NavMesh; }
function R_NavMeshActorTracker GetNavMeshActorTracker() { return NavMeshActorTracker; }

event Tick(float DeltaSeconds)
{
	if(NavMeshActorTracker != None)
	{
		NavMeshActorTracker.Update();
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
	NavMeshClass=Class'RBots.R_NavMesh_Implementation'
	NavMeshActorTrackerClass=Class'RBots.R_NavMeshActorTracker_Implementation'
}