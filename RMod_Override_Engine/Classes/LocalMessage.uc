//
// Represents a schematic for a client localized message.
//
class LocalMessage expands Info;

var bool	bComplexString;									// Indicates a multicolor string message class.
var bool	bIsSpecial;										// If true, don't add to normal queue.
var bool	bIsUnique;										// If true and special, only one can be in the HUD queue at a time.
var bool	bIsConsoleMessage;								// If true, put a GetString on the console.
var bool	bFadeMessage;									// If true, use fade out effect on message.
var bool	bBeep;											// If true, beep!
var bool	bOffsetYPos;									// If the YPos indicated isn't where the message appears.
var int		Lifetime;										// # of seconds to stay in HUD message queue.
var color	GreenColor, WhiteColor, GoldColor, RedColor, BlueColor;

var class<LocalMessage> ChildMessage;						// In some cases, we need to refer to a child message.

// Canvas Variables
var bool	bFromBottom;									// Subtract YPos.
var color	DrawColor;										// Color to display message with.
var float	XPos, YPos;										// Coordinates to print message at.
var bool	bCenter;										// Whether or not to center the message.

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional String MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	);

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return "";
}

static function MangleString(out string MessageText,
	optional PlayerReplicationInfo PRI1,
	optional PlayerReplicationInfo PRI2,
	optional Object obj)
{
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	return "";
}

static function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( P.myHUD != None )
		P.myHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

	if ( Default.bBeep && P.bMessageBeep )
		P.PlayBeepSound();

	if ( Default.bIsConsoleMessage )
	{
		if ((P.Player != None) && (P.Player.Console != None))
			P.Player.Console.AddString(Static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject ));
	}
}

// Handle beeps and console entry for normal text message types
static function ClientReceiveMessage(
	PlayerPawn P,
	String Msg,
	optional PlayerReplicationInfo PRI
	)
{
	if ( Default.bBeep && P.bMessageBeep )
		P.PlayBeepSound();

	if ( Default.bIsConsoleMessage )
	{
		if ((P.Player != None) && (P.Player.Console != None))
			P.Player.Console.AddString(Msg);
	}

	if ( P.myHUD != None )
		P.myHUD.LocalizedMessage( Default.Class, 0, PRI, None, None, Msg );
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.DrawColor;
}

static function float GetLifeTime(String MessageString)
{
	return Default.LifeTime;
}

static function bool KillMessage()
{
	return false;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return Default.YPos;
}

static function int GetFontSize( int Switch );

static function color GetTeamColor(int team)
{
	switch(team)
	{
		case 0:
			return Default.RedColor;
		case 1:
			return Default.BlueColor;
		case 2:
			return Default.GreenColor;
		case 3:
			return Default.GoldColor;
	}
	return Default.WhiteColor;
}

defaultproperties
{
     LifeTime=3
     GreenColor=(G=255)
     WhiteColor=(R=255,G=255,B=255)
     GoldColor=(R=255,G=255)
     RedColor=(R=255)
     BlueColor=(B=255)
     DrawColor=(R=255,G=255,B=255)
}
