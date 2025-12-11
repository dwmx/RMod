class R_Message_TeamAnnouncement extends R_Message_GameAnnouncement;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch(Switch)
    {
    case GetSwitch_TeamWinsMessage():           return "wins";
    case GetSwitch_TeamWinsTheRoundMessage():   return "wins the round";
    }
    return "";
}

static function string GetTeamNameString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
)
{
    local TeamInfo TI;

    Log(OptionalObject);

    // OptionalObject should be a TeamInfo
    TI = TeamInfo(OptionalObject);
    if(TI != None)
    {
        return TI.TeamName;
    }
    else
    {
        return "";
    }
}

static function Color GetTeamMessageColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
)
{
    local TeamInfo TI;

    TI = TeamInfo(OptionalObject);

    if(TI != None)
    {
        switch(Switch)
        {
        case GetSwitch_TeamWinsMessage():
        case GetSwitch_TeamWinsTheRoundMessage():   return Class'RMod.R_AColors'.Static.GetTeamColor(TI.TeamIndex);
        }
    }

    return Class'RMod.R_AColors'.Static.ColorWhite();
}

static function int GetSwitch_TeamWinsMessage()         { return 0; }
static function int GetSwitch_TeamWinsTheRoundMessage() { return 1; }

defaultproperties
{
    bIsConsoleMessage=True
    bFadeMessage=True
    LifeTime=5
    DrawColor=(R=255,G=255,B=255)
    bCenter=True
}