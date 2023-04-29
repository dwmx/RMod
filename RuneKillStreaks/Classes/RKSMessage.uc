class RKSMessage extends LocalMessage;

static function string GetPlayerNameString(
    int Switch,
    PlayerReplicationInfo PRI1,
    PlayerReplicationInfo PRI2,
    Object OptionalObject)
{
    if(PRI1 != None)
    {
        return PRI1.PlayerName;
    }
    return "";
}

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

    Result.R = 255;
    Result.G = 255;
    Result.B = 255;
    return Result;
}

static function Sound GetMessageSound(
    int Switch,
    PlayerReplicationInfo PRI1,
    PlayerReplicationInfo PRI2,
    Object OptionalObject)
{
    return None;
}

static function float GetLifeTimeSecondsMaximum(
    int Switch,
    string CriticalString)
{
    return 3.0;
}

static function float GetLifeTimeSecondsMinimum(
    int Switch,
    string CriticalString)
{
    return 0.5;
}