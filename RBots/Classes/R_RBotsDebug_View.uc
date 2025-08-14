//==============================================================================
//	R_RBotsDebug_View
//	Base class for encapsulating debug view information, with the ability to
//	toggle off and on
//	R_RBotsDebug manages all debug views
//==============================================================================
class R_RBotsDebug_View extends Actor abstract;

simulated event PostRender(Canvas C) {} // To be implemented in subclasses

defaultproperties
{
	RemoteRole=ROLE_None
}