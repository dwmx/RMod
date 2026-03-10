//==============================================================================
//  R_AUtilityLibrary
//  Library class
//
//  General utility functions
//==============================================================================
class R_AUtilityLibrary extends R_ALibrary;

static function RLog(String LogString, Name LogCategory, optional Name LogSubcategory)
{
	if(LogSubCategory != '')
	{
		Log("RLog[" $ LogCategory $ "." $ LogSubCategory $ "]:" @ LogString, LogCategory);
	}
	else
	{
		Log("RLog[" $ LogCategory $ "]:" @ LogString, LogCategory);
	}
}

/**
*	GetIntAsBinaryString
*	Returns the binary representation of an integer as string
*	e.g. 256 returns "0000 0000 0000 0000 0000 0001 0000 0000"
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
*	GetIntAsHexString
*	Given an integer, return it as a Hexadecimal string
*	e.g. 256 return 0000 0100
*/
static function String GetIntAsHexString(int Data)
{
	local String HexChars;
	local String Result;
	local int i;
	local int Nibble;

	HexChars = "0123456789ABCDEF";
	Result = "";

	for (i = 7; i >= 0; i--)
	{
		Nibble = (Data >>> (i * 4)) & 0xF;
		Result = Result $ Mid(HexChars, Nibble, 1);
		if(i % 4 == 0)
		{
			Result = Result $ " ";
		}
	}

	return Result;
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

/**
*	DecompressTwoInts
*	Decompresses an integer packed via CompressTwoInts
*/
static function DecompressTwoInts(int CompressedData, int HighBits, out int OutLowData, out int OutHighData)
{
	local int HighMask;

	// Boundaries
	if(HighBits <= 0)
	{
		OutLowData = CompressedData;
		OutHighData = 0;
		return;
	}
	if(HighBits >= 32)
	{
		OutLowData = 0;
		OutHighData = CompressedData;
		return;
	}

	HighMask = 0xFFFFFFFF << (32 -HighBits);
	OutHighData = (CompressedData & HighMask) >>> (32 -HighBits);
	OutLowData = CompressedData & ~HighMask;
}

static function bool IsValidActor(Actor ActorRef)
{
	return ActorRef != None && !ActorRef.bDeleteMe;
}

static function ColorToFloats(Color InColor, out float R, out float G, out float B)
{
	R = float(InColor.R) / 255.0;
	G = float(InColor.G) / 255.0;
	B = float(InColor.B) / 255.0;
}

static function String FloatToString(float F, int NumDecimalPlaces)
{
	local String S, IntPart, DecPart;
	local int DotPos;

	S = String(F);
	DotPos = InStr(S, ".");

	if(DotPos == -1 || NumDecimalPlaces <= 0)
	{
		return S;
	}

	IntPart = Left(S, DotPos);
	DecPart = Mid(S, DotPos + 1);

	if(Len(DecPart) > NumDecimalPlaces)
	{
		DecPart = Left(DecPart, NumDecimalPlaces);
	}

	while(Len(DecPart) < NumDecimalPlaces)
	{
		DecPart = DecPart $ "0";
	}

	return IntPart $ "." $ DecPart;
}

static function Color LerpColor(Color InColorA, Color InColorB, float t)
{
	local Color Result;

	t = FClamp(t, 0.0, 1.0);

	Result.R = byte((1.0-t) * float(InColorA.R) + t * float(InColorB.R));
	Result.G = byte((1.0-t) * float(InColorA.G) + t * float(InColorB.G));
	Result.B = byte((1.0-t) * float(InColorA.B) + t * float(InColorB.B));

	return Result;
}

static function Vector LerpVector(Vector InVectorA, Vector InVectorB, float t)
{
	local Vector Result;

	t = FClamp(t, 0.0, 1.0);
	Result = (1.0-t) * InVectorA + t * InVectorB;
	return Result;
}

static function float RemapFloatToRange(float Value, float InRangeA, float InRangeB, float OutRangeA, float OutRangeB)
{
	local float Result;
	local float t;

	Value = FClamp(Value, FMin(InRangeA, InRangeB), FMax(InRangeA, InRangeB));
	t = (Value - InRangeA) / (InRangeB - InRangeA);
	
	Result = (1.0-t) * OutRangeA + t * OutRangeB;
	return Result;
}

static function CopyActorVisualFeatures(Actor Source, Actor Dest)
{
	local int i;

	if(Source == None || Dest == None)
	{
		return;
	}

	Dest.DrawType			= Source.DrawType;
	Dest.Skeletal 			= Source.Skeletal;
	Dest.SkelMesh 			= Source.SkelMesh;
	Dest.SubstituteMesh 	= Source.SubstituteMesh;
	Dest.DrawScale			= Source.DrawScale;
	Dest.ScaleGlow			= Source.ScaleGlow;
	Dest.Fatness			= Source.Fatness;
	Dest.DesiredFatness		= Source.DesiredFatness;
	Dest.DesiredColorAdjust	= Source.DesiredColorAdjust;

	Dest.AnimSequence		= Source.AnimSequence;
	Dest.AnimFrame			= Source.AnimFrame;
	Dest.AnimRate			= Source.AnimRate;
	Dest.TweenRate			= Source.TweenRate;
	Dest.AnimMinRate		= Source.AnimMinRate;
	Dest.AnimLast			= Source.AnimLast;
	Dest.bAnimLoop			= Source.bAnimLoop;
	Dest.bAnimFinished		= Source.bAnimFinished;
	Dest.bMirrored			= Source.bMirrored;
	Dest.PrePivot			= Source.PrePivot;

	for(i = 0; i < ArrayCount(Source.SkelGroupSkins); ++i)
	{
		Dest.SkelGroupSkins[i] = Source.SkelGroupSkins[i];
	}
	for(i = 0; i < ArrayCount(Source.SkelGroupFlags); ++i)
	{
		Dest.SkelGroupFlags[i] = Source.SkelGroupFlags[i];
	}
}