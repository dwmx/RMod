//==============================================================================
//	R_ArpgItemActor_Pickup
//	World representation of an item that's sitting on the ground, waiting to be
//	picked up
//==============================================================================
class R_ArpgItemActor_Pickup extends R_ArpgItemActor;

const InteractionProxyClass = Class'RArpg.R_ArpgInteractionProxy_ItemPickup';

event PostBeginPlay()
{
	Super.PostBeginPlay();

	Spawn(InteractionProxyClass, Self);
}

defaultproperties
{
	CollisionHeight=32.0
	CollisionRadus=32.0
}