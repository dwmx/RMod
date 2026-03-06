//==============================================================================
//	R_ArpgItemActor_Pickup
//	World representation of an item that's sitting on the ground, waiting to be
//	picked up
//==============================================================================
class R_ArpgItemActor_Pickup extends R_ArpgItemActor;

var Class<R_ArpgTraceProxy> TraceProxyClass;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	Spawn(TraceProxyClass, Self);
}

defaultproperties
{
	TraceProxyClass=Class'R_ArpgTraceProxy'
}