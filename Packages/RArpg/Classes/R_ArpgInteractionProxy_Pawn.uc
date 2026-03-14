//==============================================================================
//	R_ArpgInteractionProxy_Pawnn
//==============================================================================
class R_ArpgInteractionProxy_Pawn extends R_ArpgInteractionProxy;

function Name GetProxyType() { return PROXY_TYPE_TARGET; }

function String GetDisplayString()
{
	local R_ArpgPawn LocalPawn;

	LocalPawn = R_ArpgPawn(Owner);
	if(LocalPawn != None)
	{
		return LocalPawn.GetDisplayNameString();
	}
	return Super.GetDisplayString();
}

function bool GetAttributeValue(
	Name AttributeName,
	optional out float BaseValue,
	optional out float AggregateValue)
{
	local R_ArpgPawn LocalPawn;

	LocalPawn = R_ArpgPawn(Owner);
	if(LocalPawn != None)
	{
		return LocalPawn.GetAttributeValue(AttributeName, BaseValue, AggregateValue);
	}
	return Super.GetAttributeValue(AttributeName, BaseValue, AggregateValue);
}

function DrawInWorldHUD(Canvas C)
{
	local R_ArpgPawn LocalPawn;

	LocalPawn = R_ArpgPawn(Owner);
	if(LocalPawn != None)
	{
		LocalPawn.DrawInWorldHUD(C);
	}
}