//==============================================================================
//	R_BlackBoard_Implementation
//	Implementation of the R_BlackBoard class
//==============================================================================
class R_BlackBoard_Implementation extends R_BlackBoard;

//------------------------------------------------------------------------------
//	BlackBoardTypeCodes
//
//	BlackBoard entries are stored as Key:Value pairs, where each Value
//	has an associated Type -- These consts tie the entry to its type
const BlackBoardTypeCodeInvalid	= 0;
const BlackBoardTypeCodeInt	 	= 1;
const BlackBoardTypeCodeFloat 	= 2;
const BlackBoardTypeCodeVector 	= 3;
const BlackBoardTypeCodeActor 	= 4;

// Bounds for type code validation -- update as needed
const BlackBoardTypeCodeValidMin = 1;
const BlackBoardTypeCodeValidMax = 4;

// Default values assigned when adding keys or returning invalid Get calls
const DefaultIntValue = 0;
const DefaultFloatValue = 0.0;
const DefaultVectorValue = Vect(0,0,0);
const DefaultActorValue = None;

//------------------------------------------------------------------------------
//	Entries

struct R_BlackBoardEntry
{
	var Name Key;
	var int BlackBoardTypeCode;

	// All types that an entry may hold
	var int AsInt;
	var float AsFloat;
	var Vector AsVector;
	var Actor AsActor;
};

var private R_BlackBoardEntry EntryArray[256];
var private int NumEntries;

const InvalidIndex = -1;

//------------------------------------------------------------------------------

function InitBotObject()
{
	NumEntries = 0;
}

//------------------------------------------------------------------------------

function bool InternalAddKey(Name Key, int BlackBoardTypeCode)
{
	local String LogWarning;
	local int i;

	if(BlackBoardTypeCode < BlackBoardTypeCodeValidMin || BlackBoardTypeCode > BlackBoardTypeCodeValidMax)
	{	// Invalid TypeCode
		LogWarning = "AddKey failed -- Attempted to add key with bad TypeCode:" @ BlackBoardTypeCode;
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return false;
	}

	if(NumEntries >= ArrayCount(EntryArray))
	{	// Array is full
		LogWarning = "AddKey failed -- Array is full";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return false;
	}

	for(i = 0; i < NumEntries; ++i)
	{	// Ensure the key is not already present
		if(EntryArray[i].Key == Key)
		{
			LogWarning = "AddKey failed -- Key is already present:" @ Key;
			Warn(LogWarning);
			Utilities.Static.RLog(LogWarning, LogCategory);
			return false;
		}
	}

	// Add key
	EntryArray[NumEntries].Key = Key;
	EntryArray[NumEntries].BlackBoardTypeCode = BlackBoardTypeCode;

	// Init all types
	EntryArray[NumEntries].AsInt = DefaultIntValue;
	EntryArray[NumEntries].AsFloat = DefaultFloatValue;
	EntryArray[NumEntries].AsVector = DefaultVectorValue;
	EntryArray[NumEntries].AsActor = DefaultActorValue;

	++NumEntries;
}

function bool InternalGetKeyIndex(Name Key, int BlackBoardTypeCode, out int OutIndex)
{
	local int i;

	for(i = 0; i < NumEntries; ++i)
	{
		if(EntryArray[i].Key == Key)
		{
			if(EntryArray[i].BlackBoardTypeCode == BlackBoardTypeCode)
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

function bool AddInt(Name Key)		{ return InternalAddKey(Key, BlackBoardTypeCodeInt); }
function bool AddFloat(Name Key)	{ return InternalAddKey(Key, BlackBoardTypeCodeFloat); }
function bool AddVector(Name Key)	{ return InternalAddKey(Key, BlackBoardTypeCodeVector); }
function bool AddActor(Name Key)	{ return InternalAddKey(Key, BlackBoardTypeCodeActor); }

//------------------------------------------------------------------------------
//	Getters

function bool GetInt(Name Key, out int OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, BlackBoardTypeCodeInt, Index))
	{
		OutValue = DefaultIntValue;
		return false;
	}
	OutValue = EntryArray[Index].AsInt;
	return true;
}

function bool GetFloat(Name Key, out float OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, BlackBoardTypeCodeFloat, Index))
	{
		OutValue = DefaultFloatValue;
		return false;
	}
	OutValue = EntryArray[Index].AsFloat;
	return true;
}

function bool GetVector(Name Key, out Vector OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, BlackBoardTypeCodeVector, Index))
	{
		OutValue = DefaultVectorValue;
		return false;
	}
	OutValue = EntryArray[Index].AsVector;
	return true;
}

function bool GetActor(Name Key, out Actor OutValue)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, BlackBoardTypeCodeActor, Index))
	{
		OutValue = DefaultActorValue;
		return false;
	}
	OutValue = EntryArray[Index].AsActor;
	return true;
}

//------------------------------------------------------------------------------
//	Setters

function bool SetInt(Name Key, int Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, BlackBoardTypeCodeInt, Index))
	{
		return false;
	}
	EntryArray[Index].AsInt = Value;
	return true;
}

function bool SetFloat(Name Key, float Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, BlackBoardTypeCodeFloat, Index))
	{
		return false;
	}
	EntryArray[Index].AsFloat = Value;
}

function bool SetVector(Name Key, Vector Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, BlackBoardTypeCodeVector, Index))
	{
		return false;
	}
	EntryArray[Index].AsVector = Value;
	return true;
}

function bool SetActor(Name Key, Actor Value)
{
	local int Index;
	if(!InternalGetKeyIndex(Key, BlackBoardTypeCodeActor, Index))
	{
		return false;
	}
	EntryArray[Index].AsActor = Value;
	return true;
}

//------------------------------------------------------------------------------
//	Iteration

function int GetNumKeys()
{
	return NumEntries;
}

function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutBlackBoardTypeCode)
{
	if(Index < 0 || Index >= Min(NumEntries, ArrayCount(EntryArray)))
	{
		OutBlackBoardTypeCode = BlackBoardTypeCodeInvalid;
		return false;
	}

	OutKey = EntryArray[Index].Key;
	OutBlackBoardTypeCode = EntryArray[Index].BlackBoardTypeCode;
}

//------------------------------------------------------------------------------
//	Logging / Diagnostics

function String GetStringForBlackBoardTypeCode(int BlackBoardTypeCode)
{
	switch(BlackBoardTypeCode)
	{
	case BlackBoardTypeCodeInvalid:	return "Invalid";
	case BlackBoardTypeCodeInt:		return "Int";
	case BlackBoardTypeCodeFloat:	return "Float";
	case BlackBoardTypeCodeVector:	return "Vector";
	case BlackBoardTypeCodeActor:	return "Actor";
	}
	return "Unrecognized";
}

function String GetStringForBlackBoardEntry(out R_BlackBoardEntry InEntry)
{
	local String BlackBoardTypeCodeString;
	local String ValueString;

	BlackBoardTypeCodeString = GetStringForBlackBoardTypeCode(InEntry.BlackBoardTypeCode);

	switch(InEntry.BlackBoardTypeCode)
	{
	case BlackBoardTypeCodeInt:
		ValueString = String(InEntry.AsInt);
		break;
	case BlackBoardTypeCodeFloat:
		ValueString = Utilities.Static.FloatToString(InEntry.AsFloat, 4);
		break;
	case BlackBoardTypeCodeVector:
		ValueString = String(InEntry.AsVector);
		break;
	case BlackBoardTypeCodeActor:
		ValueString = String(InEntry.AsActor);
		break;
	}

	return "{" $ "Key:" @ String(InEntry.Key) $ "," @ "Type:" @ BlackBoardTypeCodeString $ "," @ "Value:" @ ValueString $ "}";
}

function DumpBlackBoardToLog()
{
	local String LogString;
	local int i;

	Utilities.Static.RLog("--------------------", LogCategory);
	Utilities.Static.RLog("BlackBoard Log Dump", LogCategory);
	Utilities.Static.RLog("NumEntries:" @ NumEntries, LogCategory);

	for(i = 0; i < NumEntries; ++i)
	{
		LogString = "- EntryArray[" $ i $ "]:" @ GetStringForBlackBoardEntry(EntryArray[i]);
		Utilities.Static.RLog(LogString, LogCategory);
	}

	Utilities.Static.RLog("--------------------", LogCategory);
}