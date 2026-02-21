//==============================================================================
//	R_ArpgTest_ItemGrid_Query
//	Tests QueryItemIntersectingGridIndex and QueryItemsIntersectingGridRegion
//==============================================================================
class R_ArpgTest_ItemGrid_Query extends R_ArpgTest_ItemGrid abstract;

static function String GetTestNameString()
{
	return "ItemGrid Query Functions";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItemGrid ItemGrid;
	local R_ArpgItem Item1, Item2, OutItem;
	local R_ArpgItem OutItems[16];
	local int OutItemCount;

	ItemGrid = CreateMockItemGrid();
	ItemGrid.SetGridSize(8, 8);

	Item1 = CreateMockItem();
	Item1.SetItemGridSize(1, 1);

	Item2 = CreateMockItem();
	Item2.SetItemGridSize(1, 1);

	// Place items
	ItemGrid.AddItemAtGridIndex(Item1, 0, 0);
	ItemGrid.AddItemAtGridIndex(Item2, 2, 2);

	// Query single intersecting item
	if(!ItemGrid.QueryItemIntersectingGridIndex(0, 0, OutItem) || OutItem != Item1)
	{
		FailedResonString = "QueryItemIntersectingGridIndex(0,0) failed";
		return false;
	}

	// Query empty spot
	if(!ItemGrid.QueryItemIntersectingGridIndex(1, 1, OutItem) || OutItem != None)
	{
		FailedResonString = "QueryItemIntersectingGridIndex(1,1) failed";
		return false;
	}

	// Query region covering both items
	if(!ItemGrid.QueryItemsIntersectingGridRegion(0, 0, 4, 4, OutItems, OutItemCount))
	{
		FailedResonString = "QueryItemsIntersectingGridRegion failed";
		return false;
	}
	if(OutItemCount != 2)
	{
		FailedResonString = "QueryItemsIntersectingGridRegion returned wrong count: " @ OutItemCount;
		return false;
	}

	return true;
}