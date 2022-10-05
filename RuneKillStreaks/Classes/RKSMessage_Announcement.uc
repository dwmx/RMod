class RKSMessage_Announcement extends RKSMessage;

static function int GetSwitch_None()        { return -1; }
static function int GetSwitch_DoubleKill()  { return 0; }
static function int GetSwitch_TripleKill()  { return 1; }
static function int GetSwitch_MultiKill()   { return 2; }
static function int GetSwitch_MegaKill()    { return 3; }
static function int GetSwitch_UltraKill()   { return 4; }
static function int GetSwitch_MonsterKill() { return 5; }
static function int GetSwitch_HolyShit()    { return 6; }

//==============================================================================
//  Strings
static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo PRI1, 
    optional PlayerReplicationInfo PRI2,
    optional Object OptionalObject)
{
    switch(Switch)
    {
    case GetSwitch_DoubleKill():    return GetString_DoubleKill(PRI1, PRI2, OptionalObject);
    case GetSwitch_TripleKill():    return GetString_TripleKill(PRI1, PRI2, OptionalObject);
    case GetSwitch_MultiKill():     return GetString_MultiKill(PRI1, PRI2, OptionalObject);
    case GetSwitch_MegaKill():      return GetString_MegaKill(PRI1, PRI2, OptionalObject);
    case GetSwitch_UltraKill():     return GetString_UltraKill(PRI1, PRI2, OptionalObject);
    case GetSwitch_MonsterKill():   return GetString_MonsterKill(PRI1, PRI2, OptionalObject);
    }

    return "";
}

static function string GetString_DoubleKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    local string PlayerNameString;

    PlayerNameString = "";
    if(PRI1 != None)
    {
        PlayerNameString = PRI1.PlayerName;
    }

    return PlayerNameString @ "double kill!";
}

static function string GetString_TripleKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    local string PlayerNameString;

    PlayerNameString = "";
    if(PRI1 != None)
    {
        PlayerNameString = PRI1.PlayerName;
    }

    return PlayerNameString @ "triple kill!";
}

static function string GetString_MultiKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    local string PlayerNameString;

    PlayerNameString = "";
    if(PRI1 != None)
    {
        PlayerNameString = PRI1.PlayerName;
    }

    return PlayerNameString @ "multi kill!";
}

static function string GetString_MegaKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    local string PlayerNameString;

    PlayerNameString = "";
    if(PRI1 != None)
    {
        PlayerNameString = PRI1.PlayerName;
    }

    return PlayerNameString @ "mega kill!";
}

static function string GetString_UltraKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    local string PlayerNameString;

    PlayerNameString = "";
    if(PRI1 != None)
    {
        PlayerNameString = PRI1.PlayerName;
    }

    return PlayerNameString @ "ultra kill!";
}

static function string GetString_MonsterKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    local string PlayerNameString;

    PlayerNameString = "";
    if(PRI1 != None)
    {
        PlayerNameString = PRI1.PlayerName;
    }

    return PlayerNameString @ "monster kill!";
}

//==============================================================================
//  Sounds
static function Sound GetMessageSound(
    int Switch,
    PlayerReplicationInfo PRI1,
    PlayerReplicationInfo PRI2,
    Object OptionalObject)
{
    switch(Switch)
    {
    case GetSwitch_DoubleKill():    return Sound'doublekill';
    case GetSwitch_TripleKill():    return Sound'triplekill';
    case GetSwitch_MultiKill():     return Sound'multikill';;
    case GetSwitch_MegaKill():      return Sound'megakill';;
    case GetSwitch_UltraKill():     return Sound'ultrakill';;
    case GetSwitch_MonsterKill():   return Sound'monsterkill';;
    }

    return None;
}