class R_GameInfo_Valball extends R_GameInfo_DM;

var float BallSpawnTimeStampSeconds; // Time stamp when the last ball spawn happened
var float BallSpawnGraceTimeSeconds; // How long it takes for the ball to spawn
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
    Log("Ball spawned at" @ SpawnLocation @ SpawnedBall);
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

    Super.Tick(DeltaSeconds);

    // Spawn ball if necessary
    if(!bBallSpawned)
    {
        if(Level.TimeSeconds - BallSpawnTimeStampSeconds > BallSpawnGraceTimeSeconds)
        {
            bBallSpawned = SpawnBall();
            if(bBallSpawned)
            {
                BallSpawnTimeStampSeconds = Level.TimeSeconds;
            }
        }
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
    BallSpawnGraceTimeSeconds=15.0
    bBallSpawned=False
}