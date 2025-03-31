class R_ATestCollection_RBase extends R_ATestCollection abstract;

static function String GetTestCollectionNameString()
{
	return "R_ObjectList Tests";
}

static function int GetNumTests()
{
	return 14;
}

static function Class<R_ATest> GetTestAtIndex(int TestIndex)
{
	switch(TestIndex)
	{
		case 0: return Class'RBaseTests.R_ATest_List';
		case 1: return Class'RBaseTests.R_ATest_List_Add';
		case 2: return Class'RBaseTests.R_ATest_List_AddMultiple';
		case 3: return Class'RBaseTests.R_ATest_List_AddNone';
		case 4: return Class'RBaseTests.R_ATest_List_AddUnique';
		case 5: return Class'RBaseTests.R_ATest_List_AddUniqueMultiple';
		case 6: return Class'RBaseTests.R_ATest_List_AddUniqueNone';
		case 7: return Class'RBaseTests.R_ATest_List_Remove';
		case 8: return Class'RBaseTests.R_ATest_List_RemoveMultiple';
		case 9: return Class'RBaseTests.R_ATest_List_RemoveStaggered';
		case 10: return Class'RBaseTests.R_ATest_List_RemoveNone';
		case 11: return Class'RBaseTests.R_ATest_List_Iteration';
		case 12: return Class'RBaseTests.R_ATest_List_Contains';
		case 13: return Class'RBaseTests.R_ATest_List_Find';
	}

	return None;
}