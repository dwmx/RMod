//==============================================================================
//	R_ArpgItemActor_Pickup
//	World representation of an item that's sitting on the ground, waiting to be
//	picked up
//==============================================================================
class R_ArpgItemActor_Pickup extends R_ArpgItemActor;

var Class<R_ArpgInteractionProxy> InteractionProxyClass;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	Spawn(InteractionProxyClass, Self);
}

defaultproperties
{
	CollisionHeight=32.0
	CollisionRadus=32.0
	InteractionProxyClass=Class'R_ArpgInteractionProxy'
}