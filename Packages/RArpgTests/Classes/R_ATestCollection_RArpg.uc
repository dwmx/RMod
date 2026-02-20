class R_ATestCollection_RArpg extends R_ATestCollection abstract;

static function String GetTestCollectionNameString()
{
	return "Arpg Tests";
}

static function int GetNumTests()
{
	return 0;
}

static function Class<R_ATest> GetTestAtIndex(int TestIndex)
{
	return None;
}