class R_ATest_Grid_LocationToIndex extends R_ATest_Grid abstract;

const INIT_INDEX_VALUE = 1000000;

static function String GetTestNameString()
{
	return "Grid world location to X,Y index";
}

static function bool RunTest(out String FailedResonString)
{
	local int GridUnitSize;
	local int IndexX, IndexY;
	local Vector TestLocation;

	GridUnitSize = 64;

	// Zero grid unit size condition
	InitializeIndices(IndexX, IndexY);
	GridLibrary.Static.CalcGridIndexFromLocation(0, Vect(0,0,0), IndexX, IndexY);
	if(IndexX != 0 || IndexY != 0)
	{
		GetFailedMessageString(FailedResonString, "zero grid unit size", 0, 0, IndexX, IndexY);
		return false;
	}

	// World origin condition
	InitializeIndices(IndexX, IndexY);
	GridLibrary.Static.CalcGridIndexFromLocation(GridUnitSize, Vect(0,0,0), IndexX, IndexY);
	if(IndexX != 0 || IndexY != 0)
	{
		GetFailedMessageString(FailedResonString, "world origin", 0, 0, IndexX, IndexY);
		return false;
	}

	// +X+Y condition
	InitializeIndices(IndexX, IndexY);
	InitializeTestLocation(TestLocation);
	TestLocation.X = GridUnitSize * 63;
	TestLocation.Y = GridUnitSize * 42;
	GridLibrary.Static.CalcGridIndexFromLocation(GridUnitSize, TestLocation, IndexX, IndexY);
	if(IndexX != 63 || IndexY != 42)
	{
		GetFailedMessageString(FailedResonString, "+X,+Y", 63, 42, IndexX, IndexY);
		return false;
	}

	// +X-Y condition
	InitializeIndices(IndexX, IndexY);
	InitializeTestLocation(TestLocation);
	TestLocation.X = GridUnitSize * 21;
	TestLocation.Y = GridUnitSize * -37;
	GridLibrary.Static.CalcGridIndexFromLocation(GridUnitSize, TestLocation, IndexX, IndexY);
	if(IndexX != 21 || IndexY != -37)
	{
		GetFailedMessageString(FailedResonString, "+X,-Y", 21, -37, IndexX, IndexY);
		return false;
	}

	// -X+Y condition
	InitializeIndices(IndexX, IndexY);
	InitializeTestLocation(TestLocation);
	TestLocation.X = GridUnitSize * -25;
	TestLocation.Y = GridUnitSize * 98;
	GridLibrary.Static.CalcGridIndexFromLocation(GridUnitSize, TestLocation, IndexX, IndexY);
	if(IndexX != -25 || IndexY != 98)
	{
		GetFailedMessageString(FailedResonString, "-X,+Y", -25, 98, IndexX, IndexY);
		return false;
	}

	// -X-Y condition
	InitializeIndices(IndexX, IndexY);
	InitializeTestLocation(TestLocation);
	TestLocation.X = GridUnitSize * -27;
	TestLocation.Y = GridUnitSize * -92;
	GridLibrary.Static.CalcGridIndexFromLocation(GridUnitSize, TestLocation, IndexX, IndexY);
	if(IndexX != -27 || IndexY != -92)
	{
		GetFailedMessageString(FailedResonString, "-X,-Y", -27, -92, IndexX, IndexY);
		return false;
	}

	// Fractional +X+Y condition
	InitializeIndices(IndexX, IndexY);
	InitializeTestLocation(TestLocation);
	TestLocation.X = GridUnitSize * 16 + (GridUnitSize >> 1);
	TestLocation.Y = GridUnitSize * 18 + (GridUnitSize >> 1);
	GridLibrary.Static.CalcGridIndexFromLocation(GridUnitSize, TestLocation, IndexX, IndexY);
	if(IndexX != 16 || IndexY != 18)
	{
		GetFailedMessageString(FailedResonString, "fractional +X+Y", 16, 18, IndexX, IndexY);
		return false;
	}

	// Fractional +X-Y condition
	InitializeIndices(IndexX, IndexY);
	InitializeTestLocation(TestLocation);
	TestLocation.X = GridUnitSize * 16 + (GridUnitSize >> 1);
	TestLocation.Y = GridUnitSize * -18 + (GridUnitSize >> 1);
	GridLibrary.Static.CalcGridIndexFromLocation(GridUnitSize, TestLocation, IndexX, IndexY);
	if(IndexX != 16 || IndexY != -17)
	{
		GetFailedMessageString(FailedResonString, "fractional +X-Y", 16, -17, IndexX, IndexY);
		return false;
	}

	// Fractional -X+Y condition
	InitializeIndices(IndexX, IndexY);
	InitializeTestLocation(TestLocation);
	TestLocation.X = GridUnitSize * -16 + (GridUnitSize >> 1);
	TestLocation.Y = GridUnitSize * 18 + (GridUnitSize >> 1);
	GridLibrary.Static.CalcGridIndexFromLocation(GridUnitSize, TestLocation, IndexX, IndexY);
	if(IndexX != -15 || IndexY != 18)
	{
		GetFailedMessageString(FailedResonString, "fractional -X+Y", -15, 18, IndexX, IndexY);
		return false;
	}

	// Fractional -X-Y condition
	InitializeIndices(IndexX, IndexY);
	InitializeTestLocation(TestLocation);
	TestLocation.X = GridUnitSize * -16 - (GridUnitSize >> 1);
	TestLocation.Y = GridUnitSize * -18 - (GridUnitSize >> 1);
	GridLibrary.Static.CalcGridIndexFromLocation(GridUnitSize, TestLocation, IndexX, IndexY);
	if(IndexX != -16 || IndexY != -18)
	{
		GetFailedMessageString(FailedResonString, "fractional -X-Y", -16, -18, IndexX, IndexY);
		return false;
	}

	return true;
}

static function InitializeIndices(out int OutIndexX, out int OutIndexY)
{
	OutIndexX = INIT_INDEX_VALUE;
	OutIndexY = INIT_INDEX_VALUE;
}

static function InitializeTestLocation(out Vector OutTestLocation)
{
	OutTestLocation = Vect(0,0,0);
}

static function GetFailedMessageString(out String FailedResonString, String ConditionString, int ExpectedIndexX, int ExpectedIndexY, int ActualIndexX, int ActualIndexY)
{
	FailedResonString = "CalcGridIndexFromLocation returned incorrectly for" @ ConditionString @ "condition -- expected"
		@ ExpectedIndexX $ "," $ ExpectedIndexY $ ", got" @ ActualIndexX $ "," $ ActualIndexY;
}