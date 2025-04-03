class R_ATest_Utilities_BinaryString extends R_ATest_Utilities abstract;

static function String GetTestNameString()
{
	return "Utilities binary as string";
}

static function bool RunTest(out String FailedResonString)
{
	local int Data;
	local String Result;

	// Zero Condition
	Data = 0;
	Result = UtilityLibrary.Static.GetIntAsBinaryString(Data);
	if(!CheckResult("Zero", Data, "0000 0000 0000 0000 0000 0000 0000 0000", Result, FailedResonString))
	{
		return false;
	}

	// Power of two - 1 condition
	Data = 65535;
	Result = UtilityLibrary.Static.GetIntAsBinaryString(Data);
	if(!CheckResult("Power of two -1", Data, "0000 0000 0000 0000 1111 1111 1111 1111", Result, FailedResonString))
	{
		return false;
	}

	// Negative condition
	Data = -500;
	Result = UtilityLibrary.Static.GetIntAsBinaryString(Data);
	if(!CheckResult("Negative", Data, "1111 1111 1111 1111 1111 1110 0000 1100", Result, FailedResonString))
	{
		return false;
	}

	// All ones condition
	Data = 0xFFFFFFFF;
	Result = UtilityLibrary.Static.GetIntAsBinaryString(Data);
	if(!CheckResult("All ones", Data, "1111 1111 1111 1111 1111 1111 1111 1111", Result, FailedResonString))
	{
		return false;
	}

	// Overflow condition
	Data = 0xFFFFFFFF + 1;
	Result = UtilityLibrary.Static.GetIntAsBinaryString(Data);
	if(!CheckResult("Integer overflow", Data, "0000 0000 0000 0000 0000 0000 0000 0000", Result, FailedResonString))
	{
		return false;
	}

	return true;
}

static function bool CheckResult(String ConditionString, int Argument, String Expected, String Actual, out String FailedReasonString)
{
	if(Expected != Actual)
	{
		FailedReasonString =
			"GetIntAsBinaryString failed for" @ ConditionString @
			"condition with argument" @ Argument @ "-- expected" @
			"\"" $ Expected $ "\"" @ "got" @  "\"" $ Actual $ "\"";
		return false;
	}
	return true;
}