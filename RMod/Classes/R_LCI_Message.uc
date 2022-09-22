class R_LCI_Message extends LocalMessage;

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
    DrawColor=(R=130,G=61,B=254)
    bCenter=True
}