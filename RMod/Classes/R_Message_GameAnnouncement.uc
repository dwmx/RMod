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
    LifeTime=10
    DrawColor=(R=25,G=180,B=25)
    bCenter=True
}