//==============================================================================
//	R_ArpgTest_ItemSlot
//	Base class for ItemSlot tests
//==============================================================================
class R_ArpgTest_ItemSlot extends R_ArpgTest abstract;

static function R_ArpgItemSlot CreateMockItemSlot()
{
	local R_ArpgItemSlot ItemSlot;

	ItemSlot = R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgItemSlot'));

	return ItemSlot;
}

// Run series of tests on an ItemSlot with the assumption that it stores
// the item specified in StoredItem
static function bool RunItemSlotTests(
	R_ArpgItemSlot ItemSlot,
	R_ArpgItem StoredItem,
	String TestPrefix,
	out String FailedReasonString)
{
	local R_ArpgItem ItemResult;
	local int IntResult;

	TestPrefix = TestPrefix $ ":";

	if(ItemSlot == None)
	{
		FailedReasonString = TestPrefix @ "Bad ItemSlot";
		return false;
	}

	//--------------------------------------------------------------------------
	//	Empty Slot Tests
	if(StoredItem == None)
	{
		if(ItemSlot.IsValidIndex(0))
		{
			FailedReasonString = TestPrefix @ "IsValidIndex returned true, expected false";
			return false;
		}

		if(ItemSlot.ContainsItem(StoredItem))
		{
			FailedReasonString = TestPrefix @ "ContainsItem returned true, expected false";
			return false;
		}

		IntResult = ItemSlot.GetItemCount();
		if(IntResult != 0)
		{
			FailedReasonString = TestPrefix @ "GetItemCount returned" @ IntResult $ ", expected 0";
			return false;
		}

		if(ItemSlot.GetItem(0, ItemResult))
		{
			FailedReasonString = TestPrefix @ "GetItem returned true, expected false";
			return false;
		}

		if(ItemResult != None)
		{
			FailedReasonString = TestPrefix @ "GetItem returned" @ ItemResult @ "expected None";
			return false;
		}

		if(ItemSlot.GetItemIndex(StoredItem, IntResult))
		{
			FailedReasonString = TestPrefix @ "GetItemIndex returned true, expected false";
			return false;
		}

		if(IntResult != -1)
		{
			FailedReasonString = TestPrefix @ "GetItemIndex returned" @ IntResult @ "expected -1";
			return false;
		}
	}

	//--------------------------------------------------------------------------
	//	Non-empty Slot Tests
	else
	{
		if(!ItemSlot.IsValidIndex(0))
		{
			FailedReasonString = TestPrefix @ "IsValidIndex returned false, expected true";
			return false;
		}

		if(!ItemSlot.ContainsItem(StoredItem))
		{
			FailedReasonString = TestPrefix @ "ContainsItem returned false, expected true";
			return false;
		}

		IntResult = ItemSlot.GetItemCount();
		if(IntResult != 1)
		{
			FailedReasonString = TestPrefix @ "GetItemCount returned" @ IntResult $ ", expected 1";
			return false;
		}

		if(!ItemSlot.GetItem(0, ItemResult))
		{
			FailedReasonString = TestPrefix @ "GetItem returned false, expected true";
			return false;
		}

		if(ItemResult != StoredItem)
		{
			FailedReasonString = TestPrefix @ "GetItem returned" @ ItemResult @ "expected" @ StoredItem;
			return false;
		}

		if(!ItemSlot.GetItemIndex(StoredItem, IntResult))
		{
			FailedReasonString = TestPrefix @ "GetItemIndex returned false, expected true";
			return false;
		}

		if(IntResult != 0)
		{
			FailedReasonString = TestPrefix @ "GetItemIndex returned" @ IntResult @ "expected 0";
			return false;
		}
	}

	return true;
}