//==============================================================================
//	R_ArpgAttributeSet
//==============================================================================
class R_ArpgAttributeSet extends R_ArpgObject;

//------------------------------------------------------------------------------

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
	++AttributeCount;

	// Call Set so that constraints may be applied to initial value
	SetAttributeBaseValue(AttributeName, OptionalInitialValue);
}

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

//	SetAttributeBaseValue
//	Overrides the value of the specified attribute with the value provided
//	Use PreAttributeChange to perform clamping or reject value changes
//	Use PostAttributeChange to fire events
function SetAttributeBaseValue(Name AttributeName, float NewBaseValue)
{
	local int Index;
	local float PreviousValue, NewValue, ModifiedNewValue;

	if(!GetAttributeIndex(AttributeName, Index))
	{
		// Invalid Attribute
		return;
	}

	PreviousValue = Attributes[Index].BaseValue;
	NewValue = NewBaseValue;

	// Clamp to min and max if the attribute is using them
	if(Attributes[Index].bUseMinimumValue)
	{
		NewValue = FMax(NewValue, Attributes[Index].MinimumValue);
	}
	if(Attributes[Index].bUseMaximumValue)
	{
		NewValue = FMin(NewValue, Attributes[Index].MaximumValue);
	}

	// If no change, return
	if(PreviousValue == NewValue)
	{
		return;
	}

	if(!PreAttributeChange(AttributeName, PreviousValue, NewValue, ModifiedNewValue))
	{
		// Change rejected
		return;
	}

	if(PreviousValue == ModifiedNewValue)
	{
		// PreAttributeChange modified the value such that there will be no change
		return;
	}

	Attributes[Index].BaseValue = ModifiedNewValue;
	PostAttributeChange(AttributeName, PreviousValue, ModifiedNewValue);
}

//	PreAttributeChange
//	Called immediately before changing the value of the specified attribute
//	This is where you should apply any attribute constraints like clamping
//	Return false to reject the change
function bool PreAttributeChange(
	Name AttributeName,
	float PreviousValue,
	float NewValue,
	out float OutModifiedNewValue)
{
	OutModifiedNewValue = NewValue;
	return true;
}

//	PostAttributeChange
//	Called immediately after changing the value of the specified attribute
//	NewValue reflects the currently stored value for the attribute
//	This is where you should fire events related to attribute changes
function PostAttributeChange(
	Name AttributeName,
	float PreviousValue,
	float NewValue)
{
	local R_ArpgEventPayload AttributeChangedPayload;

	AttributeChangedPayload.NameArg = AttributeName;
	AttributeChangedPayload.FloatArgs[0] = PreviousValue;
	AttributeChangedPayload.FloatArgs[1] = NewValue;
	FireEvent(EVENT_ATTRIBUTE_CHANGED, AttributeChangedPayload);
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
function bool GetAttributeValue(Name AttributeName, out float OutValue)
{
	local int Index;

	if(!GetAttributeIndex(AttributeName, Index))
	{
		return false;
	}

	OutValue = Attributes[Index].BaseValue;
	return true;
}

//	IncrementAttributeValue
//	Increment the specified attribute by the given amount
//	If attribute is not found, this will fail silently
function IncrementAttribute(Name AttributeName, float Amount)
{
	local float CurrentBaseValue;

	if(!GetAttributeValue(AttributeName, CurrentBaseValue))
	{
		return;
	}

	SetAttributeBaseValue(AttributeName, CurrentBaseValue + Amount);
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
	out float OutAttributeValue)
{
	if(Index < 0 || Index >= AttributeCount)
	{
		return false;
	}

	OutAttributeName = Attributes[Index].AttributeName;
	OutAttributeValue = Attributes[Index].BaseValue;
	return true;
}

//------------------------------------------------------------------------------
function Tick(float DeltaSeconds) {}