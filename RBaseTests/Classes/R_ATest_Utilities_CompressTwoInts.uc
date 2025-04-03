class R_ATest_Utilities_CompressTwoInts extends R_ATest_Utilities abstract;

static function String GetTestNameString()
{
	return "Compress two integers";
}

static function bool RunTest(out String FailedResonString)
{
	local int LowData, HighData, HighBits;
	local int Result;

	// Zero condition
	Result = UtilityLibrary.Static.CompressTwoInts(4, 0, 0);
	if(!CheckCompressionResult("Zeros", 0x0, Result, 4, 0, 0, FailedResonString))
	{
		return false;
	}

	// Simple data split evenly
	LowData = 0x1234;
	HighData = 0xABCD;
	HighBits = 16;
	Result = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	if(!CheckCompressionResult("Simple data", 0xABCD1234, Result, HighBits, LowData, HighData, FailedResonString))
	{
		return false;
	}

	// High clipping
	LowData = 0x00000000;
	HighData = 0xFFFFFFFF;
	HighBits = 16;
	Result = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	if(!CheckCompressionResult("High clipping", 0xFFFF0000, Result, HighBits, LowData, HighData, FailedResonString))
	{
		return false;
	}

	// Low clipping
	LowData = 0xFFFFFFFF;
	HighData = 0x00000000;
	HighBits = 16;
	Result = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	if(!CheckCompressionResult("Low clipping", 0x0000FFFF, Result, HighBits, LowData, HighData, FailedResonString))
	{
		return false;
	}

	// Zero high bits
	LowData = 0xAAAAAAAA;
	HighData = 0xEEEEEEEE;
	HighBits = 0;
	Result = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	if(!CheckCompressionResult("Zero high bits", LowData, Result, HighBits, LowData, HighData, FailedResonString))
	{
		return false;
	}

	// Negative high bits
	LowData = 0xAAAAAAAA;
	HighData = 0xEEEEEEEE;
	HighBits = -3;
	Result = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	if(!CheckCompressionResult("Negative high bits", LowData, Result, HighBits, LowData, HighData, FailedResonString))
	{
		return false;
	}

	// 32 high bits
	LowData = 0xAAAAAAAA;
	HighData = 0xEEEEEEEE;
	HighBits = 32;
	Result = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	if(!CheckCompressionResult("32 high bits", HighData, Result, HighBits, LowData, HighData, FailedResonString))
	{
		return false;
	}

	// >32 high bits
	LowData = 0xAAAAAAAA;
	HighData = 0xEEEEEEEE;
	HighBits = 35;
	Result = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	if(!CheckCompressionResult("More than 32 high bits", HighData, Result, HighBits, LowData, HighData, FailedResonString))
	{
		return false;
	}

	return true;
}

static function bool CheckCompressionResult(
	String ConditionString,
	int Expected, int Actual,
	int ArgHighBits, int LowData, int HighData,
	out String FailedResonString)
{
	if(Expected != Actual)
	{
		FailedResonString = "Compress two integers failed for condition" @ ConditionString @ "args {" @
			"HighBits:" @ ArgHighBits @ "LowData:" @ LowData @ "HighData:" @ HighData $
			"} -- expected" @ Expected @ "got" @ Actual;
		return false;
	}
	return true;
}