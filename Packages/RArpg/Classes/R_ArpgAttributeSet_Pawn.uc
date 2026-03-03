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
	bPerformClamp = true;

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