//==============================================================================
//	R_ArpgTest_ItemSlot_InitialState
//	Tests the initial state return values immediately after creating ItemSlot
//==============================================================================
class R_ArpgTest_ItemSlot_InitialState extends R_ArpgTest_ItemSlot abstract;

static function String GetTestNameString()
{
	return "ItemSlot Initial State";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ArpgItemSlot ItemSlot;

	ItemSlot = CreateMockItemSlot();

	if(!RunItemSlotTests(ItemSlot, None, "Initial State", FailedResonString))
	{
		return false;
	}

	return true;
}