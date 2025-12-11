class R_ATest_IntentionalFail extends R_ATest abstract;

static function String GetTestNameString()
{
	return "Intentional Fail";
}

static function bool RunTest(out String FailedResonString)
{
	local int Result;

	Result = 5 + 5;

	if(Result == 11)
	{
		return true;
	}
	else
	{
		return false;
	}
}