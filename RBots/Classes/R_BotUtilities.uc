class R_BotUtilities extends Object;

const LogCategory = 'RBots';

static function RLog(String LogString, optional Name LogSubCategory)
{
	if(LogSubCategory != '')
	{
		Log("[" $ LogCategory $ "." $ LogSubCategory $ "]:" @ LogString, LogCategory);
	}
	else
	{
		Log("[" $ LogCategory $ "]:" @ LogString, LogCategory);
	}
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