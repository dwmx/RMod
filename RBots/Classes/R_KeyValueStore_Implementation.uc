//==============================================================================
//	R_KeyValueStore_Implementation
//==============================================================================
class R_KeyValueStore_Implementation extends R_KeyValueStore;

var private R_KeyValuePair Entries[64];
var private int NumEntries;

//------------------------------------------------------------------------------

function int GetEntryIndexForKey(Name Key)
{
	local int i;

	for(i = 0; i < NumEntries; ++i)
	{
		if(Entries[i].Key == Key)
		{
			return i;
		}
	}
	return InvalidIndex;
}

function bool IsValidIndex(int Index)
{
	return Index >= 0 && Index < Min(NumEntries, ArrayCount(Entries));
}

//------------------------------------------------------------------------------

function bool Add(Name Key, int TypeCode)
{
	local String LogString;
	local R_Variant Value;
	local int i;

	if(!IsValidKey(Key))
	{	// Valid key check
		LogString = "Invalid Key:" @ Key;
		GoTo FailWithLogString;
	}

	NumEntries = Max(0, NumEntries);
	if(NumEntries >= ArrayCount(Entries))
	{	// Array overflow check
		LogString = "Array overflow, max =" @ ArrayCount(Entries);
		GoTo FailWithLogString;
	}

	for(i = 0; i < NumEntries; ++i)
	{	// Duplicate key check
		if(Entries[i].Key == Key)
		{
			LogString = "Duplicate Key entry:" @ Key;
			GoTo FailWithLogString;
		}
	}

	if(!InitializeVariant(TypeCode, Value))
	{
		LogString = "Value initialization failed";
		GoTo FailWithLogString;
	}

	Entries[NumEntries].Key = Key;
	Entries[NumEntries].Value = Value;
	++NumEntries;
	return true;

FailWithLogString:
	LogString = "Add failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return false;
}

function bool Set(Name Key, R_Variant Value)
{
	local String LogString;
	local int EntryIndex;

	EntryIndex = GetEntryIndexForKey(Key);
	if(EntryIndex == InvalidIndex)
	{
		LogString = "No entry found for" @ Key $", add the key first";
		GoTo FailWithLogString;
	}

	if(!MatchVariantType(Entries[EntryIndex].Value, Value))
	{
		LogString = "Type mismatch";
		GoTo FailWithLogString;
	}

	Entries[EntryIndex].Value = Value;
	return true;

FailWithLogString:
	LogString = "Set failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return false;
}

function bool Get(Name Key, out R_Variant OutVariant)
{
	local String LogString;
	local int EntryIndex;

	EntryIndex = GetEntryIndexForKey(Key);
	if(EntryIndex == InvalidIndex)
	{
		LogString = "No Entry found for" @ Key $ ", add the key first";
		GoTo FailWithLogString;
	}

	OutVariant = Entries[EntryIndex].Value;
	return true;

FailWithLogString:
	LogString = "Get failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return false;
}

function int GetMaxKeys()
{
	return ArrayCount(Entries);
}

function int GetNumKeys()
{
	return NumEntries;
}

function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutTypeCode)
{
	local String LogString;

	if(!IsValidIndex(Index))
	{
		LogString = "Invalid index:" @ Index;
		GoTo FailWithLogString;
	}

	OutKey = Entries[Index].Key;
	OutTypeCode = Entries[Index].Value.TypeCode;
	return true;

FailWithLogString:
	LogString = "GetKeyTypeAtIndex failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	OutKey = InvalidKey;
	OutTypeCode = TypeCodeInvalid;
	return false;
}