//==============================================================================
//	R_ArpgAttributeSet
//==============================================================================
class R_ArpgAttributeSet extends R_ArpgObject;

//------------------------------------------------------------------------------

const INVALID_SOURCE_UID = 0;
const OPERATION_NO_OP = 0;
const OPERATION_ADD = 1;
const OPERATION_MULTIPLY = 2;
struct R_ArpgAttributeModifier
{
	var float Magnitude;
	var int Operation;
	var int SourceUID;
};

struct R_ArpgAttribute
{
	var Name AttributeName;
	var float BaseValue;
	var float AggregateValue;
	var float MinimumValue;
	var float MaximumValue;
	var bool bUseMinimumValue;
	var bool bUseMaximumValue;
	var R_ArpgAttributeModifier Modifiers[32];
};
var private R_ArpgAttribute Attributes[64];
var private int AttributeCount;

//------------------------------------------------------------------------------

const EVENT_ATTRIBUTE_CHANGED = 'AttributeChanged';
var private R_ArpgObject EventListener;

//------------------------------------------------------------------------------

function InitializeArpgObject()
{
	InitializeAttributes();
}

function InitializeAttributes()
{
	// To be implemented in child class
	// Use CreateAttribute to build the set of attributes
}

//	CreateAttribute
//	Adds a unique attribute to this AttributeSet with the specified name
//	By default, Attributes are initialized to a value of 0.0
//	Attributes are not meant to be removed, only added
function CreateAttribute(
	Name AttributeName,
	optional float OptionalInitialValue,
	optional float OptionalMinimumValue,
	optional bool bUseMinimumValue,
	optional float OptionalMaximumValue,
	optional bool bUseMaximumValue)
{
	local int i;

	if(AttributeCount >= ArrayCount(Attributes))
	{
		return;
	}

	for(i = 0; i < AttributeCount; ++i)
	{
		if(Attributes[i].AttributeName == AttributeName)
		{
			return;
		}
	}

	if(OptionalMinimumValue > OptionalMaximumValue)
	{
		OptionalMinimumValue = OptionalMaximumValue;
	}

	Attributes[AttributeCount].AttributeName = AttributeName;
	Attributes[AttributeCount].MinimumValue = OptionalMinimumValue;
	Attributes[AttributeCount].bUseMinimumValue = bUseMinimumValue;
	Attributes[AttributeCount].MaximumValue = OptionalMaximumValue;
	Attributes[AttributeCount].bUseMaximumValue = bUseMaximumValue;

	for(i = 0; i < ArrayCount(Attributes[AttributeCount].Modifiers); ++i)
	{
		Attributes[AttributeCount].Modifiers[i].Magnitude = 0.0;
		Attributes[AttributeCount].Modifiers[i].Operation = OPERATION_NO_OP;
		Attributes[AttributeCount].Modifiers[i].SourceUID = INVALID_SOURCE_UID;
	}

	++AttributeCount;

	// Call Set so that constraints may be applied to initial value
	SetAttributeBaseValue(AttributeName, OptionalInitialValue);
}

//------------------------------------------------------------------------------

//	SetAttributeBaseValue
//	Update the BaseValue and trigger attribute recalculation
function SetAttributeBaseValue(Name AttributeName, float NewBaseValue)
{
	CalculateAttributeFromBaseValue(AttributeName, NewBaseValue);
}

//	IncrementAttributeValue
//	Increment the BaseValue and trigger attribute recalculation
function IncrementAttributeBaseValue(Name AttributeName, float Amount)
{
	local int Index;

	if(!GetAttributeIndex(AttributeName, Index))
	{
		return;
	}

	CalculateAttributeFromBaseValue(AttributeName, Attributes[Index].BaseValue + Amount);
}

//	AddAttributeModifier
//	Add a traceable modifier to the specified attribute
//	Remove the modifier by calling RemoveAttributeModifiersBySource
function AddAttributeModifier(Name AttributeName, float Magnitude, int Operation, int SourceUID)
{
	local int Index;
	local int ModifierArraySize;
	local int i;

	if(SourceUID == INVALID_SOURCE_UID || !GetAttributeIndex(AttributeName, Index))
	{
		return;
	}

	ModifierArraySize = ArrayCount(Attributes[Index].Modifiers);
	for(i = 0; i < ModifierArraySize; ++i)
	{
		if(Attributes[Index].Modifiers[i].Operation == OPERATION_NO_OP)
		{
			Attributes[Index].Modifiers[i].Magnitude = Magnitude;
			Attributes[Index].Modifiers[i].Operation = Operation;
			Attributes[Index].Modifiers[i].SourceUID = SourceUID;
			CalculateAttributeFromBaseValueViaIndex(Index, Attributes[Index].BaseValue);
			return;
		}
	}
}

//	RemoveAttributeModifiersBySource
//	Remove all attribute modifiers matching the specified SourceUID
function RemoveAttributeModifiersBySource(int SourceUID)
{
	local int ModifiedAttributeIndices[ArrayCount(Attributes)];
	local int ModifiedAttributeCount;
	local bool bAdded;
	local int Index;
	local int ModifierArraySize;
	local int i;

	// Remove all modifiers matching the SourceUID and keep reference
	// to which attributes had at least one modifier removed
	ModifiedAttributeCount = 0;
	for(Index = 0; Index < AttributeCount; ++Index)
	{
		ModifierArraySize = ArrayCount(Attributes[Index].Modifiers);
		bAdded = false;
		for(i = 0; i < ModifierArraySize; ++i)
		{
			if(Attributes[Index].Modifiers[i].SourceUID == SourceUID)
			{
				Attributes[Index].Modifiers[i].Magnitude = 0.0;
				Attributes[Index].Modifiers[i].Operation = OPERATION_NO_OP;
				Attributes[Index].Modifiers[i].SourceUID = INVALID_SOURCE_UID;
				if(!bAdded)
				{
					bAdded = true;
					ModifiedAttributeIndices[ModifiedAttributeCount] = Index;
					++ModifiedAttributeCount;
				}
			}
		}
	}

	// All attributes that had at least one modifier removed need to be recalculated
	for(Index = 0; Index < ModifiedAttributeCount; ++Index)
	{
		CalculateAttributeFromBaseValueViaIndex(ModifiedAttributeIndices[Index], Attributes[Index].BaseValue);
	}
}

//	CalculateAttributeFromBaseValue
//	Recalculates both the Base and Aggregate values of the given Attribute, using
//	the provided BaseValue as a starting point
//	Clamps against Attribute's inherent min and max, and allows PreAttributeChange
//	functions to further clamp values before applying
function CalculateAttributeFromBaseValue(Name AttributeName, float BaseValue)
{
	local int Index;

	if(!GetAttributeIndex(AttributeName, Index))
	{
		return;
	}

	CalculateAttributeFromBaseValueViaIndex(Index, BaseValue);
}

function CalculateAttributeFromBaseValueViaIndex(int AttributeIndex, float BaseValue)
{
	local int Index;
	local Name AttributeName;
	local float PreviousBase, PreviousAggregate;
	local float NewBase, NewAggregate;
	local float ModifierAdd, ModifierMultiply;
	local int i;

	Index = AttributeIndex;
	AttributeName = Attributes[i].AttributeName;

	PreviousBase = Attributes[Index].BaseValue;
	PreviousAggregate = Attributes[Index].AggregateValue;

	NewBase = BaseValue;

	// Clamp new base value to attribute's inherent boundaries
	if(Attributes[Index].bUseMinimumValue)	NewBase = FMax(NewBase, Attributes[Index].MinimumValue);
	if(Attributes[Index].bUseMaximumValue)	NewBase = FMin(NewBase, Attributes[Index].MaximumValue);

	// PreAttributeBaseValueChange may further clamp the attribute
	PreAttributeBaseValueChange(AttributeName, Index, PreviousBase, NewBase, NewBase);

	// Calculate the aggregate
	ModifierAdd = 0.0;
	ModifierMultiply = 0.0;
	for(i = 0; i < ArrayCount(Attributes[Index].Modifiers); ++i)
	{
		switch(Attributes[Index].Modifiers[i].Operation)
		{
		case OPERATION_ADD:			ModifierAdd += Attributes[Index].Modifiers[i].Magnitude; 		break;
		case OPERATION_MULTIPLY:	ModifierMultiply += Attributes[Index].Modifiers[i].Magnitude;	break;
		}
	}

	NewAggregate = (BaseValue + ModifierAdd) + (BaseValue + ModifierAdd) * ModifierMultiply;

	// Clamp the aggregate to attribute's inherent boundaries
	if(Attributes[Index].bUseMinimumValue)	NewAggregate = FMax(NewAggregate, Attributes[Index].MinimumValue);
	if(Attributes[Index].bUseMaximumValue)	NewAggregate = FMin(NewAggregate, Attributes[Index].MaximumValue);

	// Update the attribute
	Attributes[Index].BaseValue = NewBase;
	Attributes[Index].AggregateValue = NewAggregate;

	// PreAttributeAggregateValueChange may further clamp the aggregate value
	PreAttributeAggregateValueChange(AttributeName, Index, PreviousAggregate, NewAggregate, NewAggregate);
}

//	PreAttributeBaseValueChange
//	Called when calculating the new BaseValue for the given Attribute
//	NewBaseValue is already clamped against the Attribute's inherent min and max values
//	This is where child classes can implement clamping one attribute against another
//	- (i.e. clamp 'Health' against 'MaxHealth')
function PreAttributeBaseValueChange(
	Name AttributeName,
	int AttributeIndex,
	float PreviousBaseValue,
	float NewBaseValue,
	out float OutModifiedNewBaseValue)
{
	OutModifiedNewBaseValue = NewBaseValue;
}

//	PreAttributeAggregateValueChange
//	Called when calculating the new AggregateValue for the given Attribute
//	NewAggregateValue is already clamped against the Attribute's inherent min and max values
//	This is where child classes can clamp the aggregated value against another attribute
function PreAttributeAggregateValueChange(
	Name AttributeName,
	int AttributeIndex,
	float PreviousAggregateValue,
	float NewAggregateValue,
	out float OutModifiedNewAggregateValue)
{
	OutModifiedNewAggregateValue = NewAggregateValue;
}

//	PostAttributeChange
//	Called immediately after updating an Attribute's Base and Aggregate values
//	Fires an AttributeChanged event
function PostAttributeChange(
	Name AttributeName,
	int AttributeIndex,
	float PreviousBaseValue, float PreviousAggregateValue,
	float NewBaseValue, float NewAggregateValue)
{
	local R_ArpgEventPayload EventPayload;

	// Internally, it's possible for an attribute to "change" without any of the values changing
	// But event listeners are only really concerned with the values changing, so this event
	// only fires if the values have changed
	if(PreviousBaseValue == NewBaseValue && PreviousAggregateValue == NewAggregateValue)
	{
		return;
	}

	EventPayload.NameArg = AttributeName;
	EventPayload.FloatArgs[0] = PreviousBaseValue;
	EventPayload.FloatArgs[1] = PreviousAggregateValue;
	EventPayload.FloatArgs[2] = NewBaseValue;
	EventPayload.FloatArgs[3] = NewAggregateValue;

	FireEvent(EVENT_ATTRIBUTE_CHANGED, EventPayload);
}

//------------------------------------------------------------------------------

//	HasAttribute
//	Returns true if this AttributeSet has an attribute matching the specified name
function bool HasAttribute(Name AttributeName)
{
	local int i;

	for(i = 0; i < AttributeCount; ++i)
	{
		if(Attributes[i].AttributeName == AttributeName)
		{
			return true;
		}
	}
	return false;
}

//	GetAttributeIndex
//	Returns the index into this container corresponding to the attribute with the provided name
//	Returns false if no such attribute was found
function bool GetAttributeIndex(Name AttributeName, out int OutAttributeIndex)
{
	local int i;

	for(i = 0; i < AttributeCount; ++i)
	{
		if(Attributes[i].AttributeName == AttributeName)
		{
			OutAttributeIndex = i;
			return true;
		}
	}
	OutAttributeIndex = INVALID_INDEX;
	return false;
}

//	SetEventListener
//	Sets the object that will receive events from this AttributeSet
function SetEventListener(R_ArpgObject NewEventListener)
{
	EventListener = NewEventListener;
}

function FireEvent(Name EventName, R_ArpgEventPayload Payload)
{
	if(EventListener != None)
	{
		EventListener.ReceiveArpgEvent(EventName, Self, Payload);
	}
}

//	GetAttributeValue
//	Retrieves the current value of the specified attribute
//	Returns false if the attribute could not be found
function bool GetAttributeValue(
	Name AttributeName,
	out float OutBaseValue,
	out float OutAggregateValue)
{
	local int Index;

	if(!GetAttributeIndex(AttributeName, Index))
	{
		return false;
	}

	OutBaseValue = Attributes[Index].BaseValue;
	OutAggregateValue = Attributes[Index].AggregateValue;
	return true;
}



//------------------------------------------------------------------------------
//	Iterator Functions
function int GetAttributeCount()
{
	return AttributeCount;
}

//	GetAttributeByIndex
//	Returns the attribute name and value at the specified index
//	Return false if the specified index is invalid
function bool GetAttributeByIndex(
	int Index,
	out Name OutAttributeName,
	out float OutAttributeBaseValue,
	out float OutAttributeAggregateValue)
{
	if(Index < 0 || Index >= AttributeCount)
	{
		return false;
	}

	OutAttributeName = Attributes[Index].AttributeName;
	OutAttributeBaseValue = Attributes[Index].BaseValue;
	OutAttributeAggregateValue = Attributes[Index].AggregateValue;
	return true;
}

//------------------------------------------------------------------------------
function Tick(float DeltaSeconds) {}