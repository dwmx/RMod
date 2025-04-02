class R_ATest_Math_Ceil extends R_ATest_Math abstract;

static function String GetTestNameString()
{
	return "Ceil math function";
}

static function bool RunTest(out String FailedResonString)
{
	local float TestFloat;
	local float ResultFloat;

	// No fractional condition
	if(!DoCeilTest(1.0, 1.0, FailedResonString))
	{
		return false;
	}

	// Less than 0.5 condition
	if(!DoCeilTest(1.3, 2.0, FailedResonString))
	{
		return false;
	}

	// Greater than 0.5 condition
	if(!DoCeilTest(1.8, 2.0, FailedResonString))
	{
		return false;
	}

	// Very near 1.0 fractional
	if(!DoCeilTest(1.99999, 2.0, FailedResonString))
	{
		return false;
	}

	return true;
}

static function bool DoCeilTest(float TestFloat, float ExpectedResultFloat, out String FailedReasonString)
{
	local float ActualResultFloat;

	ActualResultFloat = MathLibrary.Static.Ceil(TestFloat);
	if(ActualResultFloat != ExpectedResultFloat)
	{
		FailedReasonString = "Ceil did not return the expected result for Ceil(" $ TestFloat $ ") -- expected" @ ExpectedResultFloat @ "got" @ ActualResultFloat;
		return false;
	}
	return true;
}