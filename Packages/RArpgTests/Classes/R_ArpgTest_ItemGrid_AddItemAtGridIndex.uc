//==============================================================================
//	R_ArpgTest_ItemGrid_AddItemAtGridIndex
//	Tests AddItemAtGridIndex and grid region validity
//==============================================================================
class R_ArpgTest_ItemGrid_AddItemAtGridIndex extends R_ArpgTest_ItemGrid abstract;

static function String GetTestNameString()
{
	return "ItemGrid AddItemAtGridIndex";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItemGrid ItemGrid;
	local R_ArpgItem Item1, Item2;
	local R_ArpgItem StoredItems[16];
	local int StoredItemCount;
	local int X, Y;

	ItemGrid = CreateMockItemGrid();
	ItemGrid.SetGridSize(8, 8);

	Item1 = CreateMockItem();
	Item1.SetItemGridSize(2, 2);

	Item2 = CreateMockItem();
	Item2.SetItemGridSize(2, 2);
	
	StoredItemCount = 0;

	// Place Item1 at 0,0
	if(!ItemGrid.AddItemAtGridIndex(Item1, 0, 0))
	{
		FailedResonString = "AddItemAtGridIndex(Item1,0,0) returned false, expected true";
		return false;
	}
	StoredItems[StoredItemCount++] = Item1;

	// Attempt to place overlapping Item2 at 0,0 (should fail)
	if(ItemGrid.AddItemAtGridIndex(Item2, 0, 0))
	{
		FailedResonString = "AddItemAtGridIndex(Item2,0,0) returned true, expected false";
		return false;
	}

	// Place Item2 at 3,3 (bottom-right)
	if(!ItemGrid.AddItemAtGridIndex(Item2, 3, 3))
	{
		FailedResonString = "AddItemAtGridIndex(Item2,3,3) returned false, expected true";
		return false;
	}
	StoredItems[StoredItemCount++] = Item2;

	if(!RunItemGridTests(ItemGrid, StoredItems, StoredItemCount, "After AddItemAtGridIndex", FailedResonString))
	{
		return false;
	}

	return true;
}