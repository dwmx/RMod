//==============================================================================
//	R_ArpgInteractionProxy_ItemPickup
//	Interaction proxy spawned for items that can be picked up in the world
//==============================================================================
class R_ArpgInteractionProxy_ItemPickup extends R_ArpgInteractionProxy;

//------------------------------------------------------------------------------

function R_ArpgItemActor GetProxyOwnerItemActor()
{
	return R_ArpgItemActor(Owner);
}

//------------------------------------------------------------------------------

function Name GetProxyType() { return PROXY_TYPE_PICKUP; }

function String GetDisplayString()
{
	local R_ArpgItemActor LocalItemActor;

	LocalItemActor = GetProxyOwnerItemActor();
	if(LocalItemActor != None)
	{
		return LocalItemActor.GetItemDisplayString();
	}
	return Super.GetDisplayString();
}