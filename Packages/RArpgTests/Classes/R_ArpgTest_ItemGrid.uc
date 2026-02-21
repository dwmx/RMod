//==============================================================================
//	R_ArpgTest_ItemGrid
//	Base class for ItemGrid tests
//	Contains helper functions to run full ItemGrid state checks
//==============================================================================
class R_ArpgTest_ItemGrid extends R_ArpgTest abstract;

static function R_ArpgItemGrid CreateMockItemGrid()
{
	local R_ArpgItemGrid ItemGrid;
	ItemGrid = R_ArpgItemGrid(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgItemGrid'));
	ItemGrid.SetGridSize(4, 4); // default small grid
	return ItemGrid;
}

// Runs a series of checks for the ItemGrid
static function bool RunItemGridTests(
	R_ArpgItemGrid ItemGrid,
	R_ArpgItem StoredItems[16],
	int StoredItemCount,
	String TestPrefix,
	out String FailedReasonString)
{
	local int i, j;
	local R_ArpgItem ItemResult;
	local int IntResult;
	local int SizeX, SizeY;
	local int IndexX, IndexY;

	TestPrefix = TestPrefix $ ":";

	if(ItemGrid == None)
	{
		FailedReasonString = TestPrefix @ "Bad ItemGrid";
		return false;
	}

	//--------------------------------------------------------------------------
	//	Check item count
	IntResult = ItemGrid.GetItemCount();
	if(IntResult != StoredItemCount)
	{
		FailedReasonString = TestPrefix @ "GetItemCount returned" @ IntResult @ ", expected " @ StoredItemCount;
		return false;
	}

	//--------------------------------------------------------------------------
	//	Check each index sequentially
	for(i = 0; i < StoredItemCount; ++i)
	{
		if(!ItemGrid.IsValidIndex(i))
		{
			FailedReasonString = TestPrefix @ "IsValidIndex(" @ i @ ") returned false, expected true";
			return false;
		}
		if(!ItemGrid.GetItem(i, ItemResult))
		{
			FailedReasonString = TestPrefix @ "GetItem(" @ i @ ") returned false, expected true";
			return false;
		}
		if(ItemResult != StoredItems[i])
		{
			FailedReasonString = TestPrefix @ "GetItem(" @ i @ ") returned wrong item";
			return false;
		}
		if(!ItemGrid.GetItemIndex(StoredItems[i], IntResult))
		{
			FailedReasonString = TestPrefix @ "GetItemIndex returned false, expected true";
			return false;
		}
		if(IntResult != i)
		{
			FailedReasonString = TestPrefix @ "GetItemIndex returned" @ IntResult @ ", expected " @ i;
			return false;
		}
	}

	//--------------------------------------------------------------------------
	//	Check invalid indices
	for(i = StoredItemCount; i < StoredItemCount + 4; ++i)
	{
		if(ItemGrid.IsValidIndex(i))
		{
			FailedReasonString = TestPrefix @ "IsValidIndex(" @ i @ ") returned true, expected false";
			return false;
		}
		if(ItemGrid.GetItem(i, ItemResult))
		{
			FailedReasonString = TestPrefix @ "GetItem(" @ i @ ") returned true, expected false";
			return false;
		}
		if(ItemResult != None)
		{
			FailedReasonString = TestPrefix @ "GetItem(" @ i @ ") returned non-none, expected None";
			return false;
		}
	}

	//--------------------------------------------------------------------------
	//	Check ContainsItem for stored items
	for(i = 0; i < StoredItemCount; ++i)
	{
		if(!ItemGrid.ContainsItem(StoredItems[i]))
		{
			FailedReasonString = TestPrefix @ "ContainsItem returned false for stored item " @ i;
			return false;
		}
	}

	// Check ContainsItem for None
	if(ItemGrid.ContainsItem(None))
	{
		FailedReasonString = TestPrefix @ "ContainsItem returned true for None";
		return false;
	}

	return true;
}