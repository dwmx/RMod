
//==============================================================================
//	R_ATest_Utilities_CompressTwoIntsDuplex
//	Tests the validity of two-way compression and decompression via
//	CompressTwoInts and DecompressTwoInts utility functions
//==============================================================================
class R_ATest_Utilities_CompressTwoIntsDuplex extends R_ATest_Utilities abstract;

static function String GetTestNameString()
{
	return "Compress two ints duplex";
}

static function bool RunTest(out String FailedResonString)
{
	local int LowData, HighData;
	local int CompressedData;
	local int HighBits;
	local int LowDataDecompressed, HighDataDecompressed;

	// Simple middle split
	HighBits = 16;
	LowData = 0xAAEE;
	HighData = 0x1234;
	CompressedData = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowDataDecompressed, HighDataDecompressed);
	if(!CheckCompressionResult("Middle split", LowData, HighData, LowDataDecompressed, HighDataDecompressed, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// Clipping
	HighBits = 16;
	LowData = 0xAAEEA;
	HighData = 0x12345;
	CompressedData = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowDataDecompressed, HighDataDecompressed);
	if(!CheckCompressionResult("Clipping", 0xAEEA, 0x2345, LowDataDecompressed, HighDataDecompressed, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// Zero high bits
	HighBits = 0;
	LowData = 0xAAAAAAAA;
	HighData = 0xEEEEEEEE;
	CompressedData = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowDataDecompressed, HighDataDecompressed);
	if(!CheckCompressionResult("Zero high bits", 0xAAAAAAAA, 0x00000000, LowDataDecompressed, HighDataDecompressed, CompressedData, HighBits, FailedResonString))
	{
		return false;
	}

	// 32 high bits
	HighBits = 32;
	LowData = 0xAAAAAAAA;
	HighData = 0xEEEEEEEE;
	CompressedData = UtilityLibrary.Static.CompressTwoInts(HighBits, LowData, HighData);
	UtilityLibrary.Static.DecompressTwoInts(CompressedData, HighBits, LowDataDecompressed, HighDataDecompressed);
	if(!CheckCompressionResult("32 high bits", 0x00000000, 0xEEEEEEEE, LowDataDecompressed, HighDataDecompressed, CompressedData, HighBits, FailedResonString))
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