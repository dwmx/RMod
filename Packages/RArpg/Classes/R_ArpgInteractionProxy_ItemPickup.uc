//==============================================================================
//	R_ArpgInteractionProxy_ItemPickup
//	Interaction proxy spawned for items that can be picked up in the world
//==============================================================================
class R_ArpgInteractionProxy_ItemPickup extends R_ArpgInteractionProxy;

function Name GetProxyType() { return PROXY_TYPE_PICKUP; }