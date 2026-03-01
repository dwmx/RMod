//==============================================================================
//	R_ArpgDataStoreArray
//
//	ArpgDataStore implemented as a simple array
//	Very simple, but slow
//	If lookup speed becomes an issue, implement DataStore as a tree
//==============================================================================
class R_ArpgDataStoreArray extends R_ArpgDataStore;

struct R_ArpgDataStoreArrayEntry
{
	var R_ArpgTag Tag;
	var R_ArpgObject Data;
};
var private R_ArpgDataStoreArrayEntry Entries[2048];
var private int EntryCount;

//------------------------------------------------------------------------------

function InitializeArpgObject()
{
	EntryCount = 0;
}

function LogDumpArpgObject()
{
	local int i;

	Super.LogDumpArpgObject();

	Log("------------------------------------");
	Log("EntryCount:" @ EntryCount);
	Log("EntryCountMax:" @ ArrayCount(Entries));
	Log("------------------------------------");
	for(i = 0; i < EntryCount; ++i)
	{
		Log("Entries[" $ i $ "]:" @ TagLib.Static.ToString(Entries[i].Tag) @ Entries[i].Data);
	}
}

function bool AddData(R_ArpgTag Tag, R_ArpgObject Data)
{
	local int i;

	// Validate storage space and data arg
	if(EntryCount < ArrayCount(Entries) && Data == None)
	{
		return false;
	}

	// Make sure this tag hasn't been added already
	for(i = 0; i < EntryCount; ++i)
	{
		if(TagLib.Static.MatchExact(Entries[i].Tag, Tag))
		{
			return false;
		}
	}

	// Add the data
	Entries[EntryCount].Tag = Tag;
	Entries[EntryCount].Data = Data;
	++EntryCount;
	return true;
}

function bool GetData(R_ArpgTag Tag, out R_ArpgObject OutData)
{
	local int TagDepth;
	local int i, j;
	local int BestMatch, CurrentMatch;
	local int BestIndex;

	OutData = None;

	// Calc depth of the input tag
	TagDepth = 0;
	for(i = 0; i < ArrayCount(Tag.T); ++i)
	{
		if(Tag.T[i] == '')
		{
			break;
		}
		++TagDepth;
	}

	if(TagDepth == 0)
	{
		return false;
	}

	// Find the best, if there are any
	// Best match is whatever the deepst hierarchical match is
	// If Tag == 'This.Is.My.Tag'
	// Then 'This.Is.My' beats 'This.Is'
	BestMatch = 0;
	BestIndex = INVALID_INDEX;
	for(i = 0; i < EntryCount; ++i)
	{
		if(BestMatch == TagDepth)
		{
			break;
		}

		CurrentMatch = 0;
		for(j = 0; j < TagDepth; ++j)
		{
			if(Tag.T[j] != Entries[i].Tag.T[j])
			{
				break;
			}
			++CurrentMatch;
		}

		if(CurrentMatch > BestMatch)
		{
			BestMatch = CurrentMatch;
			BestIndex = i;
		}
	}

	// Return data if any was found
	if(BestIndex != INVALID_INDEX)
	{
		OutData = Entries[BestIndex].Data;
		return true;
	}
	return false;
}