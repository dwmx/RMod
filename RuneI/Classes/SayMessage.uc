//=============================================================================
// SayMessage.
//=============================================================================
class SayMessage extends LocalMessage;


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
	if (PRI1 != None)
		MessageText = PRI1.PlayerName $ ":" @ MessageText;
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	if (RelatedPRI_1 != None)
		return Static.GetTeamColor(RelatedPRI_1.Team);
}

defaultproperties
{
     bIsConsoleMessage=True
     bFadeMessage=True
     bBeep=True
     LifeTime=10
     bCenter=True
}
