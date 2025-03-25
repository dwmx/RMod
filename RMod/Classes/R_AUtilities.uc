class R_AUtilities extends Object abstract;

////////////////////////////////////////////////////////////////////////////////
//	Logging functions
//	Appends RMod to differentiate between Rune and RMod log calls
static function RModLog(String S)
{
	Log("[RMod]: " $ S);
}

static function RModWarn(String S)
{
	Warn("[RMod]: " $ S);
}

/**
*   GetPlayerIdentityLogString
*   Returns a uniform identifiable string for a player meant for logging
*/
static function String GetPlayerIdentityLogString(Pawn P)
{
    local String Result;
    local PlayerReplicationInfo PRI;

    Result = "{Actor:" @ P $ "}";

    if(P.PlayerReplicationInfo != None)
    {
        Result = Result @ "{Name:" @ P.PlayerReplicationInfo.PlayerName $ "}";
    }

    if(PlayerPawn(P) != None)
    {
        Result = Result @ "{IP:" @ PlayerPawn(P).GetPlayerNetworkAddress() $ "}";
    }

    return Result;
}

////////////////////////////////////////////////////////////////////////////////
//  Interpolation functions
//  t: Current time
//  b: Starting value
//  e: End value
//  d: Duration
static function float InterpLinear(float t, float b, float e, float d)
{
    if(t <= 0.0)    return b;
    if(t >= d)      return e;
    t = t / d;
    return ((1.0 - t) * b) + (t * e);
}

static function float InterpQuadratic(float t, float b, float e, float d)
{
    local float c;
    c = e - b;
    
    if(t <= 0.0)    return b;
    if (t >= d)     return e;
    t = t / d;
    return c * t * t + b;
}

static function Color InterpLinear_Color(float t, Color b, Color e, float d)
{
    local Color Result;

    Result.R = byte(InterpLinear(t, float(b.R), float(e.R), d));
    Result.G = byte(InterpLinear(t, float(b.G), float(e.G), d));
    Result.B = byte(InterpLinear(t, float(b.B), float(e.B), d));

    return Result;
}

static function Color InterpQuadratic_Color(float t, Color b, Color e, float d)
{
    local Color Result;

    Result.R = byte(InterpQuadratic(t, float(b.R), float(e.R), d));
    Result.G = byte(InterpQuadratic(t, float(b.G), float(e.G), d));
    Result.B = byte(InterpQuadratic(t, float(b.B), float(e.B), d));

    return Result;
}

/////////////////////////////////////////////////////////////////////////////////
//  GetTimeString functions
//
//  Take time in seconds as a float and convert it to a string indicating the
//  desired display time.
/////////////////////////////////////////////////////////////////////////////////

// Return a string in format HH:MM:SS, valid until 99:59:59
static function String GetTimeStringHoursMinutesSeconds(float TimeSeconds)
{
    local float TSeconds;
    local float TMinutes;
    local float THours;
    local String TimeString;

    // If a negative time was passed in, append the negative symbol to the front
    // of the string and take Abs(TimeSeconds)
    if(TimeSeconds < 0.0)
    {
        TimeString = "-";
        TimeSeconds *= -1.0;
    }
    else
    {
        TimeString = "";
    }

    // Hours
    THours = TimeSeconds / 3600.0;
    if(THours < 10.0)
        TimeString = TimeString $ "0";
    if(THours > 99.0)
        THours = 99.0;
    TimeString = TimeString $ int(THours) $ ":";

    // Minutes
    TMinutes = (TimeSeconds % 3600.0) / 60.0;
    if(TMinutes < 10.0)
        TimeString = TimeString $ "0";
    TimeString = TimeString $ int(TMinutes) $ ":";

    // Seconds
    TSeconds = TimeSeconds % 60.0;
    if(TSeconds < 10.0)
        TimeString = TimeString $ "0";
    TimeString = TimeString $ int(TSeconds);

    return TimeString;
}

// Return a string in format MM:SS, valid until 99:59
static function String GetTimeStringMinutesSeconds(float TimeSeconds)
{
    local float TSeconds;
    local float TMinutes;
    local String TimeString;
 
    // If a negative time was passed in, append the negative symbol to the front
    // of the string and take Abs(TimeSeconds)
    if(TimeSeconds < 0.0)
    {
        TimeString = "-";
        TimeSeconds *= -1.0;
    }
    else
    {
        TimeString = "";
    }

    // Minutes
    TMinutes = TimeSeconds / 60.0;
    if(TMinutes < 10.0)
        TimeString = TimeString $ "0";
    else if(TMinutes > 99.0)
        TMinutes = 99.0;
    TimeString = TimeString $ int(TMinutes) $ ":";

    // Seconds
    TSeconds = TimeSeconds % 60.0;
    if(TSeconds < 10.0)
        TimeString = TimeString $ "0";
    TimeString = TimeString $ int(TSeconds);

    return TimeString;
}

// Return a string in format SS
static function String GetTimeStringSeconds(float TimeSeconds)
{
	local String TimeString;
	
	TimeString = "" $ int(TimeSeconds);
	return TimeString;
}

/////////////////////////////////////////////////////////////////////////////////
//	String Utilities
/////////////////////////////////////////////////////////////////////////////////
static function bool StringIsNumeric(string S)
{
	local int i;
	local string Char;
	
	for(i = 0; i < Len(S); ++i)
	{
		Char = Mid(S, i, 1);
		if(Asc(Char) < Asc("0")
		|| Asc(Char) > Asc("9"))
		{
			return false;
		}
	}
	return true;
}

static function string GetTokenUsingDelimiter(out string s, string Delimiter)
{
	local int i,length;
	local string tok;

	if( instr(s,Delimiter) != -1 )
	{
		length = Len(s);
		for (i=0; i<length; i++)
		{
			if (Mid(s, i, 1) == Delimiter)
			{
				tok = left(s, i);
				s = right(s, length-i-1);
				break;
			}
		}
	}
	else
	{
		if (tok=="")
		{
			tok = s;
			s = "";
		}
	}

	return tok;
}

/////////////////////////////////////////////////////////////////////////////////
//  Other Utilities
/////////////////////////////////////////////////////////////////////////////////
static function float FInfinityNegative()
{
	return -999999.0;
}

static function String GetMenuNameForInventoryClass(Class<Inventory> InventoryClass)
{
    switch(InventoryClass)
    {
    // Axes
    case Class'RuneI.Handaxe':
    case Class'RMod.R_Weapon_Handaxe':              return "Hand Axe";

    case Class'RuneI.GoblinAxe':    
    case Class'RMod.R_Weapon_GoblinAxe':            return "Goblin Axe";

    case Class'RuneI.VikingAxe':    
    case Class'RMod.R_Weapon_VikingAxe':            return "Viking Axe";

    case Class'RuneI.SigurdAxe':    
    case Class'RMod.R_Weapon_SigurdAxe':            return "Sigurd Axe";

    case Class'RuneI.DwarfBattleAxe':   
    case Class'RMod.R_Weapon_DwarfBattleAxe':       return "Battle Axe";

    // Swords   
    case Class'RuneI.VikingShortSword': 
    case Class'RMod.R_Weapon_VikingShortSword':     return "Short Sword";

    case Class'RuneI.RomanSword':   
    case Class'RMod.R_Weapon_RomanSword':           return "Roman Sword";

    case Class'RuneI.VikingBroadSword': 
    case Class'RMod.R_Weapon_VikingBroadSword':     return "Broad Sword";

    case Class'RuneI.DwarfWorkSword':   
    case Class'RMod.R_Weapon_DwarfWorkSword':       return "Work Sword";

    case Class'RuneI.DwarfBattleSword': 
    case Class'RMod.R_Weapon_DwarfBattleSword':     return "Battle Sword";

    // Hammers  
    case Class'RuneI.RustyMace':    
    case Class'RMod.R_Weapon_RustyMace':            return "Rusty Mace";

    case Class'RuneI.BoneClub': 
    case Class'RMod.R_Weapon_BoneClub':             return "Bone Club";

    case Class'RuneI.TrialPitMace': 
    case Class'RMod.R_Weapon_TrialPitMace':         return "Pit Mace";

    case Class'RuneI.DwarfWorkHammer':  
    case Class'RMod.R_Weapon_DwarfWorkHammer':      return "Work Hammer";

    case Class'RuneI.DwarfBattleHammer':
    case Class'RMod.R_Weapon_DwarfBattleHammer':    return "Battle Hammer";

    // Shields
    case Class'RuneI.GoblinShield':
    case Class'RMod.R_Shield_GoblinShield':         return "Goblin Shield";

    case Class'RuneI.VikingShield':
    case Class'RuneI.VikingShield2':
    case Class'RuneI.VikingShieldCross':
    case Class'RMod.R_Shield_VikingShield':         return "Viking Shield";

    case Class'RuneI.DarkShield':
    case Class'RMod.R_Shield_DarkShield':           return "Dark Shield";

    case Class'RuneI.DwarfWoodShield':
    case Class'RMod.R_Shield_DwarfWoodShield':      return "Wood Shield";

    case Class'RuneI.DwarfBattleShield':
    case Class'RMod.R_Shield_DwarfBattleShield':    return "Battle Shield";
    }

    return String(InventoryClass);
}

/////////////////////////////////////////////////////////////////////////////////
//  Screen / World Utilities
/////////////////////////////////////////////////////////////////////////////////

/**
*   GetScreenResolutionFromPlayerPawnInPixels
*   Returns the resolution of the player's viewport in pixels
*   Returns true if resolution successfully retrieved
*/
static function bool GetScreenResolutionFromPlayerPawnInPixels(PlayerPawn InPlayerPawn, out float OutScreenWidth, out float OutScreenHeight)
{
    local String ConsoleCommandResult;
    local String LeftSplit, RightSplit;
    local int SplitIndex;
    
    if(InPlayerPawn == None)
    {
        OutScreenWidth = 0.0;
        OutScreenHeight = 0.0;
        return false;
    }
    
    ConsoleCommandResult = InPlayerPawn.ConsoleCommand("GetCurrentRes");
    SplitIndex = InStr(ConsoleCommandResult, "x");
    
    LeftSplit = Mid(ConsoleCommandResult, 0, SplitIndex);
    RightSplit = Mid(ConsoleCommandResult, SplitIndex + 1);
    
    OutScreenWidth = float(LeftSplit);
    OutScreenHeight = float(RightSplit);
    
    return true;
}

/**
*   GetWorldRayFromScreen
*   Given some screen space location, returns a ray that can be used to trace for world collisions
*/
static function Vector GetWorldRayFromScreen(Vector ScreenPos, float ScreenWidth, float ScreenHeight, float FOV, Vector CameraLocation, Rotator CameraRotation)
{
   local float HalfWidth, HalfHeight, TanFOV, AspectRatio;
   local Vector ScreenRay, WorldDirection, AxisX, AxisY, AxisZ, WorldRay;
   
   // Calculate half-dimensions and aspect ratio
   HalfWidth = ScreenWidth / 2.0;
   HalfHeight = ScreenHeight / 2.0;
   TanFOV = Tan((FOV * 3.141593) / 360.0);
   AspectRatio = TanFOV / HalfWidth;
   
   // Compute ray direction in screen space
   ScreenRay.Y = ((ScreenPos.X - HalfWidth) * AspectRatio);
   ScreenRay.Z = ((HalfHeight - ScreenPos.Y) * AspectRatio);
   ScreenRay.X = 1.0;
   
   // Convert screen space ray to world space
   GetAxes(CameraRotation, AxisX, AxisY, AxisZ);
   WorldDirection = ((ScreenRay.X * AxisX) + (ScreenRay.Y * AxisY)) + (ScreenRay.Z * AxisZ);
   WorldDirection = Normal(WorldDirection);
   
   // Compute world-space ray endpoint
   WorldRay = WorldDirection / AspectRatio;
   return WorldRay;
}

defaultproperties
{
}
