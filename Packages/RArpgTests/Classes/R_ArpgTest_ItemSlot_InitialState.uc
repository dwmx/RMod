//==============================================================================
//	R_ArpgTest_ItemSlot_InitialState
//	Base class for ItemSlot tests
//==============================================================================
class R_ArpgTest_ItemSlot_InitialState extends R_ArpgTest_ItemSlot abstract;

static function String GetTestNameString()
{
	return "ItemSlot Initial State";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItemSlot ItemSlot;
	local R_ArpgItem Item;
	local int IntResult;

	ItemSlot = CreateMockItemSlot();

	if(ItemSlot.IsValidIndex(0))
	{
		FailedResonString = "IsValidIndex(0) returned true when it should have returned false";
		return false;
	}

	if(ItemSlot.ContainsItem(None))
	{
		FailedResonString = "ContainsItem(None) returned true when it should have returned false";
		return false;
	}

	IntResult = ItemSlot.GetItemCount();
	if(IntResult != 0)
	{
		FailedResonString = "GetItemCount() returned" @ IntResult @ "when it should have returned 0";
		return false;
	}

	if(ItemSlot.GetItem(0, Item))
	{
		FailedResonString = "GetItem(0) returned true when it should have returned false";
		return false;
	}

	if(ItemSlot.GetItemIndex(None, IntResult))
	{
		FailedResonString = "GetItemIndex(None) returned true when it should have returned false";
		return false;
	}

	return true;
}