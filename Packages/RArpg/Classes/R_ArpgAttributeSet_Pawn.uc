//==============================================================================
//	R_ArpgAttributeSet_Pawn
//	Defines the core set of attributes used by all Pawns
//==============================================================================
class R_ArpgAttributeSet_Pawn extends R_ArpgAttributeSet;

const ATTRIBUTE_MAX_HEALTH = 'MaxHealth';
const ATTRIBUTE_HEALTH = 'Health';

function InitializeAttributes()
{
	CreateAttribute('MaxHealth', 100.0);
	CreateAttribute('Health', 100.0);
}

//	PreAttributeChange
//	Perform clamping against Max attributes
function bool PreAttributeChange(
	Name AttributeName,
	float PreviousValue,
	float NewValue,
	out float OutModifiedNewValue)
{
	local float ClampMin;
	local float ClampMax;
	local bool bPerformClamp;

	ClampMin = 0.0;
	bPerformClamp = false;

	switch(AttributeName)
	{
	case ATTRIBUTE_HEALTH:	bPerformClamp = GetAttributeValue(ATTRIBUTE_MAX_HEALTH, ClampMax);	break;
	}

	if(!bPerformClamp)
	{
		return Super.PreAttributeChange(AttributeName, PreviousValue, NewValue, OutModifiedNewValue);
	}

	OutModifiedNewValue = FClamp(NewValue, ClampMin, ClampMax);
	return true;
}

//	PostAttributeChange
//	When Max attributes change, need to re-clamp the affected attributes
function PostAttributeChange(
	Name AttributeName,
	float PreviousValue,
	float NewValue)
{
	local float AffectedValue;
	local float NewAffectedValue;

	// When max health changes, re-clamp health
	if(AttributeName == ATTRIBUTE_MAX_HEALTH)
	{
		if(GetAttributeValue(ATTRIBUTE_HEALTH, AffectedValue))
		{
			NewAffectedValue = FClamp(AffectedValue, 0.0, NewValue);
			SetAttribute(ATTRIBUTE_HEALTH, NewAffectedValue);
		}
	}
}