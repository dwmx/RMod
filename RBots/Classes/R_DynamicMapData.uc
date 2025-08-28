//==============================================================================
//	R_DynamicMapData
//	Defines all data which should be dynamically loaded on a per-map basis
//==============================================================================
class R_DynamicMapData extends Actor abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'DynamicMapData';

var Class<R_NavMesh> NavMeshClass;
var R_NavMesh NavMesh;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	InitializeNavMesh();
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
		NavMesh = Spawn(NavMeshClass);
		if(NavMesh == None)
		{
			Utilities.Static.RLog("Failed to spawn NavMesh from class" @ NavMeshClass, LogCategory);
		}
		else
		{
			Utilities.Static.RLog("Instantiated NavMesh from class:" @ NavMeshClass @ " -- Initializing and building", LogCategory);
			NavMesh.InitializeNavMesh();
			BuildNavMesh(); // Subclass will construct the NavMesh here

			// Validate the constructed NavMesh
			if(!NavMesh.ValidateNavMesh(FailedLogString))
			{
				Utilities.Static.RLog("NavMesh validation failed:" @ FailedLogString, LogCategory);
			}
			else
			{
				Utilities.Static.RLog("NavMesh built and validated, now post-processing", LogCategory);
				NavMesh.PostProcessNavMesh();
			}
		}
	}
}

function BuildNavMesh() {} // To be implemented in subclasses

defaultproperties
{
	RemoteRole=ROLE_None
	NavMeshClass=Class'RBots.R_BotNavMesh'
	//NavMeshClass=Class'RBots.R_NavMesh_New'
}