//==============================================================================
//  R_AUtilityLibrary
//  Library class
//
//  General utility functions
//==============================================================================
class R_AUtilityLibrary extends R_ALibrary;

/**
*	GetIntAsBinaryString
*	Returns the binary representation of an integer as string
*	e.g. 256 returns "0000 0001 0000 0000"
*/
static function String GetIntAsBinaryString(int Data)
{
	local String BinaryString;
	local int i;

	for(i = 0; i < 32; ++i)
	{
		BinaryString = (Data & 0x1) $ BinaryString;
		Data = Data >> 1;
		if((i + 1) % 4 == 0 && (i + 1) < 32)
		{
			BinaryString = " " $ BinaryString;
		}
	}

	return BinaryString;
}

/**
*	CompressTwoInts
*	Pack two integers into a single integer, using the number of HighBits specified
*	for packing HighData, and the remaining to pack LowData
*/
static function int CompressTwoInts(int HighBits, int LowData, int HighData)
{
	local int HighMask;

	// Boundaries
	if(HighBits <= 0)
	{
		return LowData;
	}
	if(HighBits >= 32)
	{
		return HighData;
	}

	HighMask = 0xFFFFFFFF << HighBits;
	HighData = (HighData << (32 - HighBits)) & HighMask;
	LowData = LowData & ~HighMask;

	return HighData | LowData;
}
