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
const PROXY_TYPE_TARGET = 'Target';

//------------------------------------------------------------------------------

function Name GetProxyType() 		{ return PROXY_TYPE_PROXY; }
function String GetDisplayString()	{ return "Interaction Proxy"; }

function Name GetNameParam(Name ParamID);

// For Actors that implement the attribute system, this passes a call through
// to them. By default, returns false
function bool GetAttributeValue(
	Name AttributeName,
	optional out float BaseValue,
	optional out float AggregateValue)
{
	return false;
}

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

function DrawInWorldHUD(Canvas C);

defaultproperties
{
	RemoteRole=ROLE_None
	DrawType=DT_None
	bCollideActors=true
	bBlockActors=false
	bBlockPlayers=false
}