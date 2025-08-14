//==============================================================================
//	R_DynamicMapData
//	Defines all data which should be dynamically loaded on a per-map basis
//==============================================================================
class R_DynamicMapData extends Actor abstract;

const Utilities = Class'RBots.R_BotUtilities';

var Class<R_BotNavMesh> NavMeshClass;
var R_BotNavMesh NavMesh;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	InitializeNavMesh();
}

final function InitializeNavMesh()
{
	if(NavMeshClass == None)
	{
		Utilities.Static.RLog("No NavMeshClass configured for" @ Self);
	}
	else
	{
		NavMesh = Spawn(NavMeshClass);
		if(NavMesh == None)
		{
			Utilities.Static.RLog("Failed to spawn NavMesh from class" @ NavMeshClass);
		}
		else
		{
			Utilities.Static.RLog("Building NavMesh from class" @ NavMeshClass);
			BuildNavMesh(); // Subclass will construct the NavMesh here
			NavMesh.ValidateAndPostProcess(); // Validate the NavMesh after Subclass builds it
		}
	}
}

function BuildNavMesh() {} // To be implemented in subclasses

defaultproperties
{
	RemoteRole=ROLE_None
	NavMeshClass=Class'RBots.R_BotNavMesh'
}