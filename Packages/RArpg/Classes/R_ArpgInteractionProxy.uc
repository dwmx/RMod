//==============================================================================
//	R_ArpgInteractionProxy
//	Actor which acts as a hit-detection proxy for another Actor
//	Used for In-World UI interactions
//==============================================================================
class R_ArpgInteractionProxy extends Actor;

//------------------------------------------------------------------------------

// Proxy Types
// To be returned by GetProxyType
// InWorldUI uses the ProxyType to determine how to draw the proxy, how to
// interact with it, and what parameters to request from it
const PROXY_TYPE_PROXY 	= 'Proxy';
const PROXY_TYPE_PICKUP = 'Pickup';

//------------------------------------------------------------------------------

function Name GetProxyType() 		{ return PROXY_TYPE_PROXY; }
function String GetDisplayString()	{ return "Interaction Proxy"; }

//------------------------------------------------------------------------------

function NotifySelectionStateChanged(bool bNewSelectionState)
{
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if(Owner == None)
	{
		Destroy();
		return;
	}
}

event Tick(float DeltaSeconds)
{
	if(Owner == None)
	{
		Destroy();
		return;
	}

	SetCollisionSize(Owner.CollisionRadius, Owner.CollisionHeight);
	SetLocation(Owner.Location);
}

function Actor GetProxyOwner()
{
	return Owner;
}

defaultproperties
{
	RemoteRole=ROLE_None
	DrawType=DT_None
	bCollideActors=true
	bBlockActors=false
	bBlockPlayers=false
}