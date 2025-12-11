class R_ATest_Math_Floor extends R_ATest_Math abstract;

static function String GetTestNameString()
{
	return "Floor math function";
}

static function bool RunTest(out String FailedResonString)
{
	local float TestFloat;
	local float ResultFloat;

	// No fractional condition
	if(!DoFloorTest(1.0, 1.0, FailedResonString))
	{
		return false;
	}

	// Less than 0.5 condition
	if(!DoFloorTest(1.3, 1.0, FailedResonString))
	{
		return false;
	}

	// Greater than 0.5 condition
	if(!DoFloorTest(1.8, 1.0, FailedResonString))
	{
		return false;
	}

	// Very near 1.0 fractional
	if(!DoFloorTest(1.99999, 1.0, FailedResonString))
	{
		return false;
	}

	// Negative no fractional condition
	if(!DoFloorTest(-1.0, -1.0, FailedResonString))
	{
		return false;
	}

	// Negative fractional greater than -0.5 condition
	if(!DoFloorTest(-1.3, -2.0, FailedResonString))
	{
		return false;
	}

	// Negative fractional less than -0.5 condition
	if(!DoFloorTest(-1.8, -2.0, FailedResonString))
	{
		return false;
	}

	// Very near negative whole condition
	if(!DoFloorTest(-1.99999, -2.0, FailedResonString))
	{
		return false;
	}

	// Zero condition
	if(!DoFloorTest(0.0, 0.0, FailedResonString))
	{
		return false;
	}

	return true;
}

static function bool DoFloorTest(float TestFloat, float ExpectedResultFloat, out String FailedReasonString)
{
	local float ActualResultFloat;

	ActualResultFloat = MathLibrary.Static.Floor(TestFloat);
	if(ActualResultFloat != ExpectedResultFloat)
	{
		FailedReasonString = "Floor did not return the expected result for Floor(" $ TestFloat $ ") -- expected" @ ExpectedResultFloat @ "got" @ ActualResultFloat;
		return false;
	}
	return true;
}