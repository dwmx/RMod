class R_ATest_SuperHardMath extends R_ATest abstract;

static function String GetTestNameString()
{
	return "Super Hard Math";
}

static function bool RunTest(out String FailedResonString)
{
	local int SuperHardMathResult;

	// Perform some mind-blowingly difficult math
	SuperHardMathResult = Sqrt(16);

	if(SuperHardMathResult == 4)
	{
		return true;
	}
	else
	{
		return false;
	}
}