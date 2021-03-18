//=============================================================================
// SubtitleMessage.
//=============================================================================
class SubtitleMessage extends LocalMessage;

var config float CharactersPerSecond;

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	return MessageString;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	if (Default.bFromBottom)
		return ClipY - Default.YPos;
	else
		return Default.YPos;
}

static function float GetLifeTime(String MessageString)
{
	return Max(Default.LifeTime, Len(MessageString)/Default.CharactersPerSecond);
}

static function bool KillMessage()
{
	return !class'GameInfo'.default.bSubtitles;
}

defaultproperties
{
     CharactersPerSecond=5.000000
     bIsUnique=True
     bIsConsoleMessage=True
     bFadeMessage=True
     LifeTime=5
     bFromBottom=True
     YPos=65.000000
     bCenter=True
}
