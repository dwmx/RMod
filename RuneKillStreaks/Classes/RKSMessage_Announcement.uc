class RKSMessage_Announcement extends RKSMessage;

static function int GetSwitch_None()            { return -1; }
static function int GetSwitch_DoubleKill()      { return 0; }
static function int GetSwitch_TripleKill()      { return 1; }
static function int GetSwitch_MultiKill()       { return 2; }
static function int GetSwitch_MegaKill()        { return 3; }
static function int GetSwitch_UltraKill()       { return 4; }
static function int GetSwitch_MonsterKill()     { return 5; }
static function int GetSwitch_HolyShit()        { return 6; }
static function int GetSwitch_KillingSpree()    { return 7; }
static function int GetSwitch_Rampage()         { return 8; }
static function int GetSwitch_Dominating()      { return 9; }
static function int GetSwitch_Unstoppable()     { return 10; }
static function int GetSwitch_Godlike()         { return 11; }

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
    case GetSwitch_KillingSpree():  return GetString_KillingSpree(PRI1, PRI2, OptionalObject);
    case GetSwitch_Rampage():       return GetString_Rampage(PRI1, PRI2, OptionalObject);
    case GetSwitch_Dominating():    return GetString_Dominating(PRI1, PRI2, OptionalObject);
    case GetSwitch_Unstoppable():   return GetString_Unstoppable(PRI1, PRI2, OptionalObject);
    case GetSwitch_Godlike():       return GetString_Godlike(PRI1, PRI2, OptionalObject);
    }

    return "";
}

static function string GetString_DoubleKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "double kill!";
}

static function string GetString_TripleKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "triple kill!";
}

static function string GetString_MultiKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "multi kill!";
}

static function string GetString_MegaKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "mega kill!";
}

static function string GetString_UltraKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "ultra kill!";
}

static function string GetString_MonsterKill(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "monster kill!";
}

static function string GetString_KillingSpree(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "is on a killing spree";
}

static function string GetString_Rampage(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "is on a rampage";
}

static function string GetString_Dominating(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "is DOMINATING";
}

static function string GetString_Unstoppable(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "is UNSTOPPABLE";
}

static function string GetString_Godlike(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, Object OptionalObject)
{
    return "is GODLIKE";
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
    case GetSwitch_MultiKill():     return Sound'multikill';
    case GetSwitch_MegaKill():      return Sound'megakill';
    case GetSwitch_UltraKill():     return Sound'ultrakill';
    case GetSwitch_MonsterKill():   return Sound'monsterkill';
    case GetSwitch_KillingSpree():  return Sound'killingspree';
    case GetSwitch_Rampage():       return Sound'rampage';
    case GetSwitch_Dominating():    return Sound'dominating';
    case GetSwitch_Unstoppable():   return Sound'unstoppable';
    case GetSwitch_Godlike():       return Sound'godlike';
    }

    return None;
}

//==============================================================================
//  Colors
static function Color GetDrawColor1(
    int Switch,
    PlayerReplicationInfo PRI1,
    PlayerReplicationInfo PRI2,
    Object OptionalObject)
{
    local Color Result;

    Result.R = 255;
    Result.G = 255;
    Result.B = 255;
    return Result;
}

static function Color GetDrawColor2(
    int Switch,
    PlayerReplicationInfo PRI1,
    PlayerReplicationInfo PRI2,
    Object OptionalObject)
{
    local Color Result;
    local Pawn P;

    P = Pawn(OptionalObject);
    if(P != None)
    {
        Result.R = byte(P.DesiredColorAdjust.X);
        Result.G = byte(P.DesiredColorAdjust.Y);
        Result.B = byte(P.DesiredColorAdjust.Z);
    }
    else
    {
        Result.R = 255;
        Result.G = 255;
        Result.B = 255;
    }

    return Result;
}