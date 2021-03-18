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

defaultproperties
{
}
