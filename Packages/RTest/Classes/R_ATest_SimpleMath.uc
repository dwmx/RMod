class R_ATest_SimpleMath extends R_ATest abstract;

static function String GetTestNameString()
{
	return "Simple Math";
}

static function bool RunTest(out String FailedResonString)
{
	local int SimpleMathResult;

	// Perform some simple math
	SimpleMathResult = 10 + 20;

	if(SimpleMathResult == 30)
	{
		return true;
	}
	else
	{
		return false;
	}
}