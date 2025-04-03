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