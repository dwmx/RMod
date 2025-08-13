// Tests the robustness of indexing within the grid library
class R_ATest_Grid_DuplexIndexing extends R_ATest_Grid abstract;

static function String GetTestNameString()
{
	return "Grid duplex indexing";
}

static function bool RunTest(out String FailedResonString)
{
	local int GridUnitSize;
	local int IndexX, IndexY;



	return true;
}

static function GetFailedMessageString(out String FailedResonString, String ConditionString, int ExpectedIndexX, int ExpectedIndexY, int ActualIndexX, int ActualIndexY)
{
	FailedResonString = "CalcGridIndexFromLocation returned incorrectly for" @ ConditionString @ "condition -- expected"
		@ ExpectedIndexX $ "," $ ExpectedIndexY $ ", got" @ ActualIndexX $ "," $ ActualIndexY;
}