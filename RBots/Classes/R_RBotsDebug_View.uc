//==============================================================================
//	R_RBotsDebug_View
//	Base class for encapsulating debug view information, with the ability to
//	toggle off and on
//	R_RBotsDebug manages all debug views
//==============================================================================
class R_RBotsDebug_View extends Actor abstract;

function R_RBotsDebug GetDebugMutator()
{
	return R_RBotsDebug(Owner);
}

function DebugTargetChanged(R_Bot OldDebugTarget, R_Bot NewDebugTarget)
{}

simulated event PostRender(Canvas C) {} // To be implemented in subclasses

// Implement in subclasses
simulated function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager) {}

// Utility function for returning the player pawn debug is being viewed from
function PlayerPawn GetPlayerPawnOwner()
{
	local PlayerPawn PP;

	if(Owner != None && Owner.Owner != None)
	{
		return PlayerPawn(Owner.Owner);
	}
	return None;
}

function Vector GetPlayerPawnOwnerLocation()
{
	local PlayerPawn PP;

	PP = GetPlayerPawnOwner();
	if(PP != None)
	{
		return PP.Location;
	}
	return Vect(0,0,0);
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