//==============================================================================
//	R_ArpgTest_ItemGrid_InitialState
//	Tests initial state of ItemGrid
//==============================================================================
class R_ArpgTest_ItemGrid_InitialState extends R_ArpgTest_ItemGrid abstract;

static function String GetTestNameString()
{
	return "ItemGrid Initial State";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItemGrid ItemGrid;
	local R_ArpgItem StoredItems[16];

	ItemGrid = CreateMockItemGrid();

	return RunItemGridTests(ItemGrid, StoredItems, 0, "Initial State", FailedResonString);
}