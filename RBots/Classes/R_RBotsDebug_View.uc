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

simulated event PostRender(Canvas C) {} // To be implemented in subclasses

// Implement in subclasses
simulated function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager) {}

defaultproperties
{
	RemoteRole=ROLE_None
}