//==============================================================================
//	R_ATestCollection_RArpg
//	Test collection for the RArpg package
//==============================================================================
class R_ATestCollection_RArpg extends R_ATestCollection abstract;

static function String GetTestCollectionNameString()
{
	return "Arpg Tests";
}

static function int GetNumTests()
{
	return 9;
}

static function Class<R_ATest> GetTestAtIndex(int TestIndex)
{
	switch(TestIndex)
	{
	case 0:			return Class'RArpgTests.R_ArpgTest_Item';
	case 1:			return Class'RArpgTests.R_ArpgTest_ItemSlot_InitialState';
	case 2:			return Class'RArpgTests.R_ArpgTest_ItemSlot_AddItem';
	case 3:			return Class'RArpgTests.R_ArpgTest_ItemSlot_AddAndRemoveItem';
	case 4:			return Class'RArpgTests.R_ArpgTest_ItemSlot_StateTransition';
	case 5:			return Class'RArpgTests.R_ArpgTest_ItemGrid_InitialState';
	case 6:			return Class'RArpgTests.R_ArpgTest_ItemGrid_AddAndRemoveItem';
	case 7:			return Class'RArpgTests.R_ArpgTest_ItemGrid_AddItemAtGridIndex';
	case 8:			return Class'RArpgTests.R_ArpgTest_ItemGrid_Query';
	}

	return None;
}