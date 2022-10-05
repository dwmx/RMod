class RKSMessage extends LocalMessage;

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