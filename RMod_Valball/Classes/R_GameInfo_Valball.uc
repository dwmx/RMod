class R_GameInfo_Valball extends R_GameInfo_DM;

var float BallSpawnTimeStampSeconds; // Time stamp when the last ball spawn happened
var bool bBallSpawned;

function Vector SelectBallSpawnLocation()
{
    local NavigationPoint RandomNavPoint;
    local Vector Result;

    Result.X = 0.0f;
    Result.Y = 0.0f;
    Result.Z = 0.0;

    foreach AllActors(Class'Engine.NavigationPoint', RandomNavPoint)
    {
        Result = RandomNavPoint.Location;
        break;
    }

    return Result;
}

function bool SpawnBall()
{
    local Vector SpawnLocation;
    local R_Ball SpawnedBall;

    SpawnLocation = SelectBallSpawnLocation();
    SpawnedBall = Spawn(Class'RMod_Valball.R_Ball',,,SpawnLocation);
    return true;
}

event PostBeginPlay()
{
    Super.PostBeginPlay();

    BallSpawnTimeStampSeconds = Level.TimeSeconds;
    bBallSpawned = false;
}

event Tick(float DeltaSeconds)
{
    local R_Ball Ball;
    local R_Runeplayer Holder;
    local R_PlayerReplicationInfo_Valball PRI;
    local bool bBallNeedsSpawn;

    Super.Tick(DeltaSeconds);

    // Respawn ball if necessary
    bBallNeedsSpawn = true;
    foreach AllActors(Class'RMod_Valball.R_Ball', Ball)
    {
        bBallNeedsSpawn = false;
        break;
    }
    if(bBallNeedsSpawn)
    {
        SpawnBall();
    }

    // Tick hold time for players
    foreach AllActors(Class'RMod_Valball.R_Ball', Ball)
    {
        Holder = R_RunePlayer(Ball.Owner);
        if(Holder != None)
        {
            PRI = R_PlayerReplicationInfo_Valball(Holder.PlayerReplicationInfo);
            if(PRI != None)
            {
                PRI.HoldTimeSeconds += DeltaSeconds;
            }
        }
    }
}

defaultproperties
{
    RunePlayerClass=Class'RMod_Valball.R_RunePlayer_Valball'
    HUDType=Class'RMod_Valball.R_RunePlayerHUD_Valball'
    ScoreBoardType=Class'RMod_Valball.R_Scoreboard_Valball'
    PlayerReplicationInfoClass=Class'RMod_Valball.R_PlayerReplicationInfo_Valball'
    bBallSpawned=False
}