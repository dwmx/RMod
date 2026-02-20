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
	return 1;
}

static function Class<R_ATest> GetTestAtIndex(int TestIndex)
{
	switch(TestIndex)
	{
	case 0:			return Class'RArpgTests.R_ArpgTest_Item';
	}

	return None;
}