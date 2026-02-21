//==============================================================================
//	R_ArpgTest_ItemGrid_AddAndRemoveItem
//	Tests AddItem and RemoveItem functionality
//==============================================================================
class R_ArpgTest_ItemGrid_AddAndRemoveItem extends R_ArpgTest_ItemGrid abstract;

static function String GetTestNameString()
{
	return "ItemGrid Add and Remove Item";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItemGrid ItemGrid;
	local R_ArpgItem Item1, Item2;
	local R_ArpgItem StoredItems[16];
	local int StoredItemCount;

	ItemGrid = CreateMockItemGrid();
	ItemGrid.SetGridSize(4, 4);

	Item1 = CreateMockItem();
	Item1.SetItemGridSize(2, 2);

	Item2 = CreateMockItem();
	Item2.SetItemGridSize(2, 2);

	StoredItemCount = 0;

	// Initial state
	if(!RunItemGridTests(ItemGrid, StoredItems, StoredItemCount, "Initial State", FailedResonString))
	{
		return false;
	}

	// Add first item
	if(!ItemGrid.AddItem(Item1))
	{
		FailedResonString = "AddItem returned false for Item1, expected true";
		return false;
	}
	StoredItems[StoredItemCount++] = Item1;
	if(!RunItemGridTests(ItemGrid, StoredItems, StoredItemCount, "After AddItem1", FailedResonString))
	{
		return false;
	}

	// Add second item
	if(!ItemGrid.AddItem(Item2))
	{
		FailedResonString = "AddItem returned false for Item2, expected true";
		return false;
	}
	StoredItems[StoredItemCount++] = Item2;
	if(!RunItemGridTests(ItemGrid, StoredItems, StoredItemCount, "After AddItem2", FailedResonString))
	{
		return false;
	}

	// Remove non-existent item
	if(ItemGrid.RemoveItem(None))
	{
		FailedResonString = "RemoveItem(None) returned true, expected false";
		return false;
	}
	if(!RunItemGridTests(ItemGrid, StoredItems, StoredItemCount, "After Remove None", FailedResonString))
	{
		return false;
	}

	// Remove Item1
	if(!ItemGrid.RemoveItem(Item1))
	{
		FailedResonString = "RemoveItem(Item1) returned false, expected true";
		return false;
	}
	StoredItems[0] = StoredItems[1]; // shift remaining
	StoredItemCount--;
	if(!RunItemGridTests(ItemGrid, StoredItems, StoredItemCount, "After Remove Item1", FailedResonString))
	{
		return false;
	}

	// Remove Item2
	if(!ItemGrid.RemoveItem(Item2))
	{
		FailedResonString = "RemoveItem(Item2) returned false, expected true";
		return false;
	}
	StoredItemCount = 0;
	if(!RunItemGridTests(ItemGrid, StoredItems, StoredItemCount, "After Remove Item2", FailedResonString))
	{
		return false;
	}

	return true;
}