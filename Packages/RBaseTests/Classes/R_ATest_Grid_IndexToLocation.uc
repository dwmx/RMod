class R_ATest_Grid_IndexToLocation extends R_ATest_Grid abstract;

static function String GetTestNameString()
{
	return "Grid X,Y index to world location";
}

static function bool RunTest(out String FailedResonString)
{
	local int GridUnitSize;
	local Vector Result;

	// Zero grid unit size condition
	Result = GridLibrary.Static.CalcLocationFromGridIndex(0, 24, 15);
	if(!CheckResult("Zero grid unit size", Vect(0,0,0), Result, FailedResonString))
	{
		return false;
	}

	GridUnitSize = 64;

	// +X+Y Condition
	Result = GridLibrary.Static.CalcLocationFromGridIndex(GridUnitSize, 24, 15);
	if(!CheckResult("+X+Y", Vect(1536,960,0), Result, FailedResonString))
	{
		return false;
	}

	// +X-Y Condition
	Result = GridLibrary.Static.CalcLocationFromGridIndex(GridUnitSize, 24, -15);
	if(!CheckResult("+X-Y", Vect(1536,-960,0), Result, FailedResonString))
	{
		return false;
	}

	// -X+Y Condition
	Result = GridLibrary.Static.CalcLocationFromGridIndex(GridUnitSize, -24, 15);
	if(!CheckResult("-X+Y", Vect(-1536,960,0), Result, FailedResonString))
	{
		return false;
	}

	// -X-Y Condition
	Result = GridLibrary.Static.CalcLocationFromGridIndex(GridUnitSize, -24, -15);
	if(!CheckResult("-X-Y", Vect(-1536,-960,0), Result, FailedResonString))
	{
		return false;
	}

	return true;
}

static function bool CheckResult(
	String ConditionString, Vector Expected, Vector Actual, out String FailedResonString)
{
	if(Expected == Actual)
	{
		return true;
	}

	FailedResonString = "Location from grid index returned incorrectly for" @ ConditionString @ "condition --" @
		"expected" @ Expected @ "got" @ Actual;
	return false;
}

static function GetFailedMessageString(out String FailedResonString, String ConditionString, int ExpectedIndexX, int ExpectedIndexY, int ActualIndexX, int ActualIndexY)
{
	FailedResonString = "CalcGridIndexFromLocation returned incorrectly for" @ ConditionString @ "condition -- expected"
		@ ExpectedIndexX $ "," $ ExpectedIndexY $ ", got" @ ActualIndexX $ "," $ ActualIndexY;
}