//==============================================================================
//	R_ArpgEntityAttributeSet
//	Contains a set of attributes and attribute modifiers
//	Meant to be owned by an ArpgEntity
//==============================================================================
class R_ArpgEntityAttributeSet extends R_ArpgObject;

//------------------------------------------------------------------------------

struct R_ArpgAttribute
{
	var Name Tag;
	var float Value;
};
var private R_ArpgAttribute Attributes[64];
var private int AttributeCount;

//------------------------------------------------------------------------------

function AddAttribute(Name AttributeTag)
{
	local int i;

	if(AttributeCount >= ArrayCount(Attributes))
	{
		return;
	}

	for(i = 0; i < AttributeCount; ++i)
	{
		if(Attributes[i].Tag == AttributeTag)
		{
			return;
		}
	}

	Attributes[AttributeCount].Tag = AttributeTag;
	Attributes[AttributeCount].Value = 0.0;
	++AttributeCount;
}

function int GetAttributeCount()
{
	return AttributeCount;
}

function bool GetAttributeByIndex(int Index, out Name OutAttributeTag, out float OutValue)
{
	if(Index >= 0 && Index < AttributeCount)
	{
		OutAttributeTag = Attributes[Index].Tag;
		OutValue = Attributes[Index].Value;
		return true;
	}
	return false;
}

//------------------------------------------------------------------------------

function InitializeArpgObject()
{
	AttributeCount = 0;
}