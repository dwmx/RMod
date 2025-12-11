//==============================================================================
//	R_RBotsDebug_View
//	Base class for encapsulating debug view information, with the ability to
//	toggle off and on
//	R_RBotsDebug manages all debug views
//==============================================================================
class R_RBotsDebug_View extends RBotsDebug.R_DBView abstract;

function R_RBotsDebug GetRBotsDebugMutator()
{
	return R_RBotsDebug(Owner);
}

// Utility function for subclasses -- gets NavMesh from parent debug actor
simulated function R_NavMesh GetNavMesh()
{
	local R_RBotsDebug RBotsDebug;

	if(Owner != None)
	{
		RBotsDebug = R_RBotsDebug(Owner);
		if(RBotsDebug != None)
		{
			return RBotsDebug.GetNavMesh();
		}
	}
}

function R_NavMeshActorTracker GetNavMeshActorTracker()
{
	local R_RBotsDebug RBotsDebug;

	if(Owner != None)
	{
		RBotsDebug = R_RBotsDebug(Owner);
		if(RBotsDebug != None)
		{
			return RBotsDebug.GetNavMeshActorTracker();
		}
	}
	return None;
}

defaultproperties
{
	RemoteRole=ROLE_None
}