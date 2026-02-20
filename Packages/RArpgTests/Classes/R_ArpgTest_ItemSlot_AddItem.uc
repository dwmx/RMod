//==============================================================================
//	R_ArpgTest_ItemSlot_AddItem
//	Tests AddItem functionality of ItemSlot
//==============================================================================
class R_ArpgTest_ItemSlot_AddItem extends R_ArpgTest_ItemSlot abstract;

static function String GetTestNameString()
{
	return "ItemSlot Add Item";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItemSlot ItemSlot;
	local R_ArpgItem Item, Item2;
	local R_ArpgItem ItemResult;
	local int IntResult;

	ItemSlot = CreateMockItemSlot();
	Item = CreateMockItem();
	Item2 = CreateMockItem();
	
	// Initial state tests
	if(!RunItemSlotTests(ItemSlot, None, "Initial State", FailedResonString))
	{
		return false;
	}

	// Add one item
	if(!ItemSlot.AddItem(Item))
	{
		FailedResonString = "AddItem returned false, should have returned true";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, Item, "Add One Item", FailedResonString))
	{
		return false;
	}

	// Add a second item and test again
	if(ItemSlot.AddItem(Item2))
	{
		FailedResonString = "AddItem returned true, should have returned false";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, Item, "Add Two Items", FailedResonString))
	{
		return false;
	}

	// Add None and test again
	if(ItemSlot.AddItem(None))
	{
		FailedResonString = "AddItem returned true, should have returned false";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, Item, "Add None", FailedResonString))
	{
		return false;
	}

	return true;
}