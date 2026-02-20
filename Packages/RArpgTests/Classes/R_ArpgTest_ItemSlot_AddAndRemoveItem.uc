//==============================================================================
//	R_ArpgTest_ItemSlot_AddAndRemoveItem
//	Tests AddItem and RemoveItem functionality for ItemSlot
//==============================================================================
class R_ArpgTest_ItemSlot_AddAndRemoveItem extends R_ArpgTest_ItemSlot abstract;

static function String GetTestNameString()
{
	return "ItemSlot Add Item and Remove Item";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItemSlot ItemSlot;
	local R_ArpgItem Item, Item2;

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

	// Remove None and test again
	if(ItemSlot.RemoveItem(None))
	{
		FailedResonString = "RemoveItem(None) returned true, expected false";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, Item, "Remove None", FailedResonString))
	{
		return false;
	}

	// Remove a real but non-contained item and test again
	if(ItemSlot.RemoveItem(Item2))
	{
		FailedResonString = "RemoveItem returned true, expected false";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, Item, "Remove non-none but non-contained", FailedResonString))
	{
		return false;
	}

	// Remove the stored item
	if(!ItemSlot.RemoveItem(Item))
	{
		FailedResonString = "RemoveItem returned false, expected true";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, None, "Remove Stored Item", FailedResonString))
	{
		return false;
	}

	return true;
}