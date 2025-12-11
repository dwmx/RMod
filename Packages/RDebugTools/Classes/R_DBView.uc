//==============================================================================
//	R_DBView
//	Base class for encapsulating debug view information, with the ability to
//	toggle off and on
//==============================================================================
class R_DBView extends Actor abstract;

function R_DBMutator GetDebugMutator()
{
	return R_DBMutator(Owner);
}

function DebugTargetChanged(Actor OldDebugTarget, Actor NewDebugTarget)
{}

// Unnecessary to implement PostRender -- use DrawDebugView
simulated event PostRender(Canvas C) {}

// Implement in subclasses
simulated function DrawDebugView(Canvas C, R_DBStringManager StringManager) {}

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

defaultproperties
{
	RemoteRole=ROLE_None
}