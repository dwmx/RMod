class R_ATestCollection_RBase extends R_ATestCollection abstract;

static function String GetTestCollectionNameString()
{
	return "R_ObjectList Tests";
}

static function int GetNumTests()
{
	return 33;
}

static function Class<R_ATest> GetTestAtIndex(int TestIndex)
{
	switch(TestIndex)
	{
        // List tests
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
		case 14: return Class'RBaseTests.R_ATest_List_InsertBadIndex';
		case 15: return Class'RBaseTests.R_ATest_List_InsertHead';
		case 16: return Class'RBaseTests.R_ATest_List_InsertMiddle';
		case 17: return Class'RBaseTests.R_ATest_List_InsertTail';

		// Math tests
		case 18: return Class'RBaseTests.R_ATest_Math_Floor';
		case 19: return Class'RBaseTests.R_ATest_Math_Ceil';
		case 20: return Class'RBaseTests.R_ATest_Math_Round';

		// Grid tests
		case 21: return Class'RBaseTests.R_ATest_Grid_LocationToIndex';
		case 22: return Class'RBaseTests.R_ATest_Grid_IndexToLocation';
		case 23: return Class'RBaseTests.R_ATest_Grid_DuplexIndexing';

		// Utility library tests
		case 24: return Class'RBaseTests.R_ATest_Utilities_BinaryString';
		case 25: return Class'RBaseTests.R_ATest_Utilities_CompressTwoInts';
		case 26: return Class'RBaseTests.R_ATest_Utilities_DecompressTwoInts';
		case 27: return Class'RBaseTests.R_ATest_Utilities_CompressTwoIntsDuplex';

		// Geometry tests
		case 28: return Class'RBaseTests.R_ATest_Geometry_LineSegmentIntersect';
		case 29: return Class'RBaseTests.R_ATest_Geometry_LineSegmentDistance';
		case 30: return Class'RBaseTests.R_ATest_Geometry_LocationWithinTriangle';
		case 31: return Class'RBaseTests.R_ATest_Geometry_Triangle';
		case 32: return Class'RBaseTests.R_ATest_Geometry_TriangleIntersectAABB';
	}

	return None;
}