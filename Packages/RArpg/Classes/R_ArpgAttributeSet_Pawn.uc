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

//	PreAttributeBaseValueChange
//	Clip attributes against their max-value counterparts
//	i.e. Clip Health against MaxHealth or Mana against MaxMana
function PreAttributeBaseValueChange(
	Name AttributeName,
	int AttributeIndex,
	float PreviousBaseValue,
	float NewBaseValue,
	out float OutModifiedNewBaseValue)
{
	local float BaseValue, AggregateValue;
	local float MaxValue;
	local bool bPerformClip;

	switch(AttributeName)
	{
	case ATTRIBUTE_HEALTH:	bPerformClip = GetAttributeValue(ATTRIBUTE_MAX_HEALTH, BaseValue, AggregateValue);	break;
	}

	if(bPerformClip)
	{
		// Clip attributes against the aggregate value of the max counterpart
		// This means clip Health against MaxHealth after applying all of the +MaxHealth bonuses
		MaxValue = AggregateValue;
		OutModifiedNewBaseValue = FMin(NewBaseValue, MaxValue);
	}
	else
	{
		Super.PreAttributeBaseValueChange(
			AttributeName, AttributeIndex,
			PreviousBaseValue, NewBaseValue,
			OutModifiedNewBaseValue);
	}
}

//	PreAttributeAggregateValueChange
//	Clip the attribute's aggregate value against its max-value counterpart
function PreAttributeAggregateValueChange(
	Name AttributeName,
	int AttributeIndex,
	float PreviousAggregateValue,
	float NewAggregateValue,
	out float OutModifiedNewAggregateValue)
{
	local float BaseValue, AggregateValue;
	local float MaxValue;
	local bool bPerformClip;

	switch(AttributeName)
	{
	case ATTRIBUTE_HEALTH:	bPerformClip = GetAttributeValue(ATTRIBUTE_MAX_HEALTH, BaseValue, AggregateValue);	break;
	}

	if(bPerformClip)
	{
		// Clip attributes against the aggregate value of the max counterpart
		// This means clip Health against MaxHealth after applying all of the +MaxHealth bonuses
		MaxValue = AggregateValue;
		OutModifiedNewAggregateValue = FMin(NewAggregateValue, MaxValue);
	}
	else
	{
		Super.PreAttributeAggregateValueChange(
			AttributeName, AttributeIndex,
			PreviousAggregateValue, NewAggregateValue,
			OutModifiedNewAggregateValue);
	}
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