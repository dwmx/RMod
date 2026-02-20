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
	return 2;
}

static function Class<R_ATest> GetTestAtIndex(int TestIndex)
{
	switch(TestIndex)
	{
	case 0:			return Class'RArpgTests.R_ArpgTest_Item';
	case 1:			return Class'RArpgTests.R_ArpgTest_ItemSlot_InitialState';
	}

	return None;
}