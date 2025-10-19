//==============================================================================
//	R_KeyValueStore_Implementation
//==============================================================================
class R_KeyValueStore_Implementation extends R_KeyValueStore;

//------------------------------------------------------------------------------
// TypeCodes
// These identify what is stored at each Key entry
const TypeCodeInvalid 	= 0;
const TypeCodeBool		= 1;
const TypeCodeInt 		= 2;
const TypeCodeFloat 	= 3;
const TypeCodeVector 	= 4;
const TypeCodeActor 	= 5;
const TypeCodeObject 	= 6;
const TypeCodeClass 	= 7;

// Min and Max valid TypeCode values -- adjust as needed for new types
const TypeCodeValidMin	= 1;
const TypeCodeValidMax	= 7;

//------------------------------------------------------------------------------
const DefaultBool 		= 0;
const DefaultInt 		= 0;
const DefaultFloat 		= 0.0;
const DefaultVector 	= Vect(0,0,0);
const DefaultActor 		= None;
const DefaultObject 	= None;
const DefaultClass 		= None;

struct R_KeyValueEntry
{
	var Name Key;
	var int TypeCode;

	// All valid types
	var int AsInt;
	var float AsFloats[3];
	var Object AsObject;
};

var private R_KeyValueEntry EntryArray[256];
var private int NumEntries;

function InternalInitializeValuesForEntryIndex(int Index)
{
	EntryArray[Index].AsInt = 0;
	EntryArray[Index].AsFloats[0] = 0.0;
	EntryArray[Index].AsFloats[1] = 0.0;
	EntryArray[Index].AsFloats[2] = 0.0;
	EntryArray[Index].AsObject = None;
}

//------------------------------------------------------------------------------

function Initialize()
{
	NumEntries = 0;
}

function bool InternalAddKey(Name Key, int TypeCode)
{
	local String LogString;
	local int i;

	if(Key == '' || Key == 'None')
	{	// Key must be valid
		LogString = "Invalid Key Name -- Cannot be 'None' or ''";
		GoTo FailWithLogString;
	}

	if(TypeCode < TypeCodeValidMin || TypeCode > TypeCodeValidMax)
	{	// TypeCode must be within range
		LogString = "Bad TypeCode:" @ TypeCode;
		GoTo FailWithLogString;
	}

	if(NumEntries >= ArrayCount(EntryArray))
	{	// Store is full
		LogString = "Array overflow";
		GoTo FailWithLogString;
	}

	for(i = 0; i < NumEntries; ++i)
	{	// Key must not already be present
		if(EntryArray[i].Key == Key)
		{
			LogString = "Key already present";
			GoTo FailWithLogString;
		}
	}

	// Add and initialize the Key:Value pair
	i = NumEntries;
	InternalInitializeValuesForEntryIndex(i);
	EntryArray[i].Key = Key;
	EntryArray[i].TypeCode = TypeCode;
	++NumEntries;

	return true;

FailWithLogString:
	LogString = "AddKey failed for Key '" $ Key $ "' --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return false;
}

function bool InternalGetKeyIndex(Name Key, int TypeCode, out int OutIndex)
{
	local int i;

	for(i = 0; i < NumEntries; ++i)
	{
		if(EntryArray[i].Key == Key)
		{
			if(EntryArray[i].TypeCode == TypeCode)
			{
				OutIndex = i;
				return true;
			}
			else
			{
				OutIndex = InvalidIndex;
				return false;
			}
		}
	}

	OutIndex = InvalidIndex;
	return false;
}

//------------------------------------------------------------------------------

function bool AddBool(Name Key)		{ return InternalAddKey(Key, TypeCodeBool); }
function bool AddInt(Name Key)		{ return InternalAddKey(Key, TypeCodeInt); }
function bool AddFloat(Name Key)	{ return InternalAddKey(Key, TypeCodeFloat); }
function bool AddVector(Name Key)	{ return InternalAddKey(Key, TypeCodeVector); }
function bool AddActor(Name Key)	{ return InternalAddKey(Key, TypeCodeActor); }
function bool AddObject(Name Key)	{ return InternalAddKey(Key, TypeCodeObject); }
function bool AddClass(Name Key)	{ return InternalAddKey(Key, TypeCodeClass); }

//------------------------------------------------------------------------------
//	Getters

function bool GetBool(Name Key, out byte OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeBool, Index))
	{
		OutValue = DefaultBool;
		return false;
	}
	OutValue = byte(EntryArray[Index].AsInt);
	return true;
}

function bool GetInt(Name Key, out int OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeInt, Index))
	{
		OutValue = DefaultInt;
		return false;
	}
	OutValue = EntryArray[Index].AsInt;
	return true;
}

function bool GetFloat(Name Key, out float OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeFloat, Index))
	{
		OutValue = DefaultFloat;
		return false;
	}
	OutValue = EntryArray[Index].AsFloats[0];
	return true;
}

function bool GetVector(Name Key, out Vector OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeVector, Index))
	{
		OutValue = DefaultVector;
		return false;
	}
	OutValue.X = EntryArray[Index].AsFloats[0];
	OutValue.Y = EntryArray[Index].AsFloats[1];
	OutValue.Z = EntryArray[Index].AsFloats[2];
	return true;
}

function bool GetActor(Name Key, out Actor OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeActor, Index))
	{
		OutValue = DefaultActor;
		return false;
	}
	OutValue = Actor(EntryArray[Index].AsObject);
	return true;
}

function bool GetObject(Name Key, out Object OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeObject, Index))
	{
		OutValue = DefaultObject;
		return false;
	}
	OutValue = EntryArray[Index].AsObject;
	return true;
}

function bool GetClass(Name Key, out Class OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeClass, Index))
	{
		OutValue = DefaultClass;
		return false;
	}
	OutValue = Class(EntryArray[Index].AsObject);
	return true;
}

//------------------------------------------------------------------------------
//	Setters
function bool SetBool(Name Key, byte Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeBool, Index))
	{
		return false;
	}
	EntryArray[Index].AsInt = Clamp(Value, 0, 1);
	return true;
}

function bool SetInt(Name Key, int Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeInt, Index))
	{
		return false;
	}
	EntryArray[Index].AsInt = Value;
	return true;
}

function bool SetFloat(Name Key, float Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeFloat, Index))
	{
		return false;
	}
	EntryArray[Index].AsFloats[0] = Value;
	return true;
}

function bool SetVector(Name Key, Vector Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeVector, Index))
	{
		return false;
	}
	EntryArray[Index].AsFloats[0] = Value.X;
	EntryArray[Index].AsFloats[1] = Value.Y;
	EntryArray[Index].AsFloats[2] = Value.Z;
	return true;
}

function bool SetActor(Name Key, Actor Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeActor, Index))
	{
		return false;
	}
	EntryArray[Index].AsObject = Value;
	return true;
}

function bool SetObject(Name Key, Object Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeObject, Index))
	{
		return false;
	}
	EntryArray[Index].AsObject = Value;
	return true;
}

function bool SetClass(Name Key, Class Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, TypeCodeClass, Index))
	{
		return false;
	}
	EntryArray[Index].AsObject = Value;
	return true;
}

//------------------------------------------------------------------------------
// 	Iteration

function int GetNumKeys()
{
	return NumEntries;
}

function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutTypeCode)
{
	if(Index < 0 || Index >= Min(NumEntries, ArrayCount(EntryArray)))
	{
		OutKey = 'None';
		OutTypeCode = TypeCodeInvalid;
		return false;
	}

	OutKey = EntryArray[Index].Key;
	OutTypeCode = EntryArray[Index].TypeCode;
	return true;
}

//------------------------------------------------------------------------------
//	Logging / Diagnostics

function String GetStringForTypeCode(int TypeCode)
{
	switch(TypeCode)
	{
	case TypeCodeInvalid:	return "Invalid";
	case TypeCodeBool:		return "Bool";
	case TypeCodeInt:		return "Int";
	case TypeCodeFloat:		return "Float";
	case TypeCodeVector:	return "Vector";
	case TypeCodeActor:		return "Actor";
	case TypeCodeObject:	return "Object";
	case TypeCodeClass:		return "Class";
	}
	return "Unrecognized";
}

function String GetStringForKeyValueEntry(out R_KeyValueEntry InEntry)
{
	local String TypeCodeString;
	local String ValueString;
	local Vector AsVector;

	TypeCodeString = GetStringForTypeCode(InEntry.TypeCode);

	switch(InEntry.TypeCode)
	{
	case TypeCodeBool:
		if(InEntry.AsInt > 0)	ValueString = "true";
		else					ValueString = "false";
		break;
	case TypeCodeInt:
		ValueString = String(InEntry.AsInt);
		break;
	case TypeCodeFloat:
		ValueString = Utilities.Static.FloatToString(InEntry.AsFloats[0], 4);
		break;
	case TypeCodeVector:
		AsVector.X = InEntry.AsFloats[0];
		AsVector.Y = InEntry.AsFloats[1];
		AsVector.Z = InEntry.AsFloats[2];
		ValueString = String(AsVector);
		break;
	case TypeCodeActor:
		ValueString = String(Actor(InEntry.AsObject));
		break;
	case TypeCodeObject:
		ValueString = String(InEntry.AsObject);
		break;
	case TypeCodeClass:
		ValueString = String(Class(InEntry.AsObject));
		break;
	}

	return "{" $ "Key:" @ String(InEntry.Key) $ "," @ "Type:" @ TypeCodeString $ "," @ "Value:" @ ValueString $ "}";
}

function DumpToLog()
{
	local String LogString;
	local int i;

	Utilities.Static.RLog("--------------------", LogCategory);
	Utilities.Static.RLog("(" $ Self $ ")");
	Utilities.Static.RLog("KeyValueStore Log Dump", LogCategory);
	Utilities.Static.RLog("NumEntries:" @ NumEntries, LogCategory);

	for(i = 0; i < NumEntries; ++i)
	{
		LogString = "- EntryArray[" $ i $ "]:" @ GetStringForKeyValueEntry(EntryArray[i]);
		Utilities.Static.RLog(LogString, LogCategory);
	}

	Utilities.Static.RLog("--------------------", LogCategory);
}