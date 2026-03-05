//==============================================================================
//	R_ArpgAttributeSet_Pawn
//	Defines the core set of attributes used by all Pawns
//==============================================================================
class R_ArpgAttributeSet_Pawn extends R_ArpgAttributeSet;

const ATTRIBUTE_MAX_HEALTH = 'MaxHealth';
const ATTRIBUTE_HEALTH = 'Health';

function InitializeAttributes()
{
	CreateAttribute(ATTRIBUTE_MAX_HEALTH, 100.0, 0.0, true);
	CreateAttribute(ATTRIBUTE_HEALTH, 100.0, 0.0, true);
}

//	ClipToMaxAttribute
//	Clip a given attribute value against its max attribute if there is one
//	Always clip against the aggregate value of the max
function float ClipToMaxAttribute(Name AttributeName, float Value)
{
	local float BaseValue, AggregateValue;
	local bool bPerformClip;

	bPerformClip = false;
	switch(AttributeName)
	{
	case ATTRIBUTE_HEALTH:	bPerformClip = GetAttributeValue(ATTRIBUTE_MAX_HEALTH, BaseValue, AggregateValue);	break;
	}

	if(bPerformClip)
	{
		return FMin(Value, AggregateValue);
	}
	else
	{
		return Value;
	}
}

//	PreAttributeBaseValueChange
//	Clip attributes against their max attribute if there is one
function PreAttributeBaseValueChange(
	Name AttributeName,
	int AttributeIndex,
	float PreviousBaseValue,
	float NewBaseValue,
	out float OutModifiedNewBaseValue)
{
	OutModifiedNewBaseValue = ClipToMaxAttribute(AttributeName, NewBaseValue);
}

//	PreAttributeAggregateValueChange
//	Clip attribute aggregates against the max attribute if there is one
function PreAttributeAggregateValueChange(
	Name AttributeName,
	int AttributeIndex,
	float PreviousAggregateValue,
	float NewAggregateValue,
	out float OutModifiedNewAggregateValue)
{
	OutModifiedNewAggregateValue = ClipToMaxAttribute(AttributeName, NewAggregateValue);
}

function PostAttributeChange(
	Name AttributeName,
	int AttributeIndex,
	float PreviousBaseValue, float PreviousAggregateValue,
	float NewBaseValue, float NewAggregateValue)
{
	local float AffectedBaseValue, AffectedAggregateValue;
	local float NewAffectedValue;

	// Clamp Health to MaxHealth aggregated value
	if(AttributeName == ATTRIBUTE_MAX_HEALTH)
	{
		if(GetAttributeValue(ATTRIBUTE_HEALTH, AffectedBaseValue, AffectedAggregateValue))
		{
			NewAffectedValue = FMin(AffectedBaseValue, NewAggregateValue);
			SetAttributeBaseValue(ATTRIBUTE_HEALTH, NewAffectedValue);
		}
	}

	Super.PostAttributeChange(
		AttributeName,
		AttributeIndex,
		PreviousBaseValue, PreviousAggregateValue,
		NewBaseValue, NewAggregateValue);
}