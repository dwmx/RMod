class R_ATest_Utilities_DecompressTwoInts extends R_ATest_Utilities abstract;

static function String GetTestNameString()
{
	return "Decompress two integers";
}

static function bool RunTest(out String FailedResonString)
{
	local int LowData, HighData;
	local int HighBits, CompressedData;

	// Zero condition
	HighBits = 16;
	CompressedData = 0x00000000;
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowData, HighData);
	if(!CheckCompressionResult("Zero", 0, 0, LowData, HighData, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// Middle split condition
	HighBits = 16;
	CompressedData = 0xEEEEAAAA;
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowData, HighData);
	if(!CheckCompressionResult("Middle split", 0xAAAA, 0xEEEE, LowData, HighData, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// Low high bits
	HighBits = 4;
	CompressedData = 0xBEEEAAAA;
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowData, HighData);
	if(!CheckCompressionResult("Low number of high bits", 0xEEEAAAA, 0xB, LowData, HighData, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// High high bits
	HighBits = 28;
	CompressedData = 0xBEEEAAAA;
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowData, HighData);
	if(!CheckCompressionResult("High number of high bits", 0xA, 0xBEEEAAA, LowData, HighData, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// Zero high bits
	HighBits = 0;
	CompressedData = 0xBEEEAAAA;
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowData, HighData);
	if(!CheckCompressionResult("Zero high bits", 0xBEEEAAAA, 0x0, LowData, HighData, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// Negative high bits
	HighBits = -2;
	CompressedData = 0xBEEEAAAA;
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowData, HighData);
	if(!CheckCompressionResult("Negative high bits", 0xBEEEAAAA, 0x0, LowData, HighData, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// 32 high bits
	HighBits = 32;
	CompressedData = 0xBEEEAAAA;
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowData, HighData);
	if(!CheckCompressionResult("32 high bits", 0x0, 0xBEEEAAAA, LowData, HighData, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// More than 32 high bits
	HighBits = 36;
	CompressedData = 0xBEEEAAAA;
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowData, HighData);
	if(!CheckCompressionResult("More than 32 high bits", 0x0, 0xBEEEAAAA, LowData, HighData, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	return true;
}

static function bool CheckCompressionResult(
	String ConditionString,
	int ExpectedLowData, int ExpectedHighData,
	int ActualLowData, int ActualHighData,
	int ArgCompressedData, int ArgHighBits,
	out String FailedResonString)
{
	if(ExpectedLowData != ActualLowData || ExpectedHighData != ActualHighData)
	{
		FailedResonString = "Decompress two ints failed for" @ ConditionString @ "condition, args" @
			"CompressedData:" @ UtilityLibrary.Static.GetIntAsHexString(ArgCompressedData) @ "HighBits:" @ ArgHighBits @
			"-- expected" @ UtilityLibrary.Static.GetIntAsHexString(ExpectedLowData) @ UtilityLibrary.Static.GetIntAsHexString(ExpectedHighData) @
			"got" @ UtilityLibrary.Static.GetIntAsHexString(ActualLowData) @ UtilityLibrary.Static.GetIntAsHexString(ActualHighData);
		return false;
	}

	return true;
}