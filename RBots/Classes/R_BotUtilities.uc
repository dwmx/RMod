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