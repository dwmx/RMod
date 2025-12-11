class R_Message_GameAnnouncement extends LocalMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return "";
}

defaultproperties
{
    bIsConsoleMessage=True
    bFadeMessage=True
    LifeTime=5
    DrawColor=(R=255,G=255,B=255)
    bCenter=True
}