//==============================================================================
//	R_ArpgTest_Item
//	Basic tests for Item objects
//==============================================================================
class R_ArpgTest_Item extends R_ArpgTest abstract;

static function String GetTestNameString()
{
	return "Item";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItem Item;
	local int ItemGridSizeX, ItemGridSizeY;
	local SkelModel ItemSkeletal;
	local Texture ItemUITexture;

	// Test creation
	Item = CreateMockItem();
	if(Item == None)
	{
		FailedResonString = "Item creation failed";
		return false;
	}

	// Set grid size and check again
	Item.SetItemGridSize(4, 4);
	if(!Item.GetItemGridSize(ItemGridSizeX, ItemGridSizeY) || ItemGridSizeX != 4 || ItemGridSizeY != 4)
	{
		FailedResonString = "GetItemGridSize should have returned true but returned false";
		return false;
	}

	return true;
}