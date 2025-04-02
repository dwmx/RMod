class R_ATest_Math_Round extends R_ATest_Math abstract;

static function String GetTestNameString()
{
	return "Round math function";
}

static function bool RunTest(out String FailedResonString)
{
	local float TestFloat;
	local float ResultFloat;

	// Unchanged condition
	if(!DoRoundTest(1.0, 1.0, FailedResonString))
	{
		return false;
	}

	// Round down condition
	if(!DoRoundTest(1.3, 1.0, FailedResonString))
	{
		return false;
	}

	// Round up condition
	if(!DoRoundTest(1.8, 2.0, FailedResonString))
	{
		return false;
	}

	// x.5 condition -- should round up
	if(!DoRoundTest(1.5, 2.0, FailedResonString))
	{
		return false;
	}

	return true;
}

static function bool DoRoundTest(float TestFloat, float ExpectedResultFloat, out String FailedReasonString)
{
	local float ActualResultFloat;

	ActualResultFloat = MathLibrary.Static.Round(TestFloat);
	if(ActualResultFloat != ExpectedResultFloat)
	{
		FailedReasonString = "Round did not return the expected result for Round(" $ TestFloat $ ") -- expected" @ ExpectedResultFloat @ "got" @ ActualResultFloat;
		return false;
	}
	return true;
}