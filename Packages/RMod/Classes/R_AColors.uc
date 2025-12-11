class R_AColors extends Object abstract;

enum ETeamColor
{
	TC_Red,
	TC_Blue,
	TC_Green,
	TC_Gold,
	TC_White
};

static function Color ColorWhite()
{
    local Color C;
    C.R = 255;
    C.G = 255;
    C.B = 255;
    return C;
}

static function Color ColorBlack()
{
    local Color C;
    C.R = 0;
    C.G = 0;
    C.B = 0;
    return C;
}

static function Color ColorRed()
{
    local Color C;
    C.R = 255;
    C.G = 60;
    C.B = 60;
    return C;
}

static function Color ColorGreen()
{
    local Color C;
    C.R = 60;
    C.G = 255;
    C.B = 60;
    return C;
}

static function Color ColorBlue()
{
    local Color C;
    C.R = 60;
    C.G = 60;
    C.B = 255;
    return C;
}

static function Color ColorGold()
{
    local Color C;
    C.R = 255;
    C.G = 255;
    C.B = 60;
    return C;
}

static function Color ColorOrange()
{
    local Color C;
    C.R = 255;
    C.G = 102;
    C.B = 51;
    return C;
}

////////////////////////////////////////////////////////////////////////////////
//  Team Colors
//
//	These are the end-all functions for determining team colors
//	To change a game type's team colors, extend this class and set
//	the Vmod_GameInfo.ColorsClass property
static function ETeamColor GetTeamColorEnumForTeamIndex(int TeamIndex)
{
	switch(TeamIndex)
	{
		case 0:		return TC_Red;
		case 1: 	return TC_Blue;
		case 2: 	return TC_Green;
		case 3: 	return TC_Gold;
		default: 	return TC_White;
	}
}

static function Color GetTeamColor(int TeamIndex)
{
	switch(GetTeamColorEnumForTeamIndex(TeamIndex))
	{
		case ETeamColor.TC_Red:
			return ColorRed();
			
		case ETeamColor.TC_Blue:
			return ColorBlue();
			
		case ETeamColor.TC_Green:
			return ColorGreen();
			
		case ETeamColor.TC_Gold:
			return ColorGold();
			
		case TC_White:
		default:
			return ColorWhite();
	}
}

static function Vector GetTeamColorVector(int TeamIndex)
{
	local Color C;
	local Vector V;
	
	C = GetTeamColor(TeamIndex);
	V.X = C.R;
	V.Y = C.G;
	V.Z = C.B;
	
	return V;
}

static function Color GetSpectatorColor()
{
    local Color C;
    C.R = 120;
    C.G = 120;
    C.B = 120;
    return C;
}

static function GetTeamColorBytes(
    int TeamIndex,
    optional out byte R,
    optional out byte G,
    optional out byte B)
{
	local Color C;
	
	C = GetTeamColor(TeamIndex);
    R = C.R;
    G = C.G;
    B = C.B;
}

defaultproperties
{
}
