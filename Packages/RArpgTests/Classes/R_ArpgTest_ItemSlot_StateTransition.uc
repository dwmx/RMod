//==============================================================================
//	R_ArpgTest_ItemSlot_StateTransition
//	Cycles between different items stored in an ItemSlot
//==============================================================================
class R_ArpgTest_ItemSlot_StateTransition extends R_ArpgTest_ItemSlot abstract;

static function String GetTestNameString()
{
	return "ItemSlot State Transition";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItemSlot ItemSlot;
	local R_ArpgItem Item1, Item2, Item3;

	ItemSlot = CreateMockItemSlot();
	Item1 = CreateMockItem();
	Item2 = CreateMockItem();
	Item3 = CreateMockItem();
	
	// Initial state tests
	if(!RunItemSlotTests(ItemSlot, None, "Initial State", FailedResonString))
	{
		return false;
	}

	// Add Item1
	if(!ItemSlot.AddItem(Item1))
	{
		FailedResonString = "AddItem returned false, expected true";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, Item1, "Add Item1", FailedResonString))
	{
		return false;
	}

	// Remove Item1
	if(!ItemSlot.RemoveItem(Item1))
	{
		FailedResonString = "RemoveItem returned false, expected true";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, None, "Remove Item1", FailedResonString))
	{
		return false;
	}

	// Add Item2
	if(!ItemSlot.AddItem(Item2))
	{
		FailedResonString = "AddItem returned false, expected true";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, Item2, "Add Item2", FailedResonString))
	{
		return false;
	}

	// Remove Item2
	if(!ItemSlot.RemoveItem(Item2))
	{
		FailedResonString = "RemoveItem returned false, expected true";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, None, "Remove Item2", FailedResonString))
	{
		return false;
	}

	// Add Item3
	if(!ItemSlot.AddItem(Item3))
	{
		FailedResonString = "AddItem returned false, expected true";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, Item3, "Add Item3", FailedResonString))
	{
		return false;
	}

	// Remove Item3
	if(!ItemSlot.RemoveItem(Item3))
	{
		FailedResonString = "RemoveItem returned false, expected true";
		return false;
	}
	if(!RunItemSlotTests(ItemSlot, None, "Remove Item3", FailedResonString))
	{
		return false;
	}

	return true;
}