class R_BallState extends Info;

var R_Ball OwnerBall;
var Name CurrentBallState;
var float PreSpawnTimeStampSeconds;
var float PreSpawnDurationSeconds;

replication
{
    reliable if(Role == ROLE_Authority)
        CurrentBallState;
}

simulated event PostBeginPlay()
{
    OwnerBall = R_Ball(Self.Owner);
    if(OwnerBall == None)
    {
        Destroy();
    }
}

simulated event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);

    if(Role == ROLE_Authority)
    {
        CurrentBallState = GetStateName();
    }
    else
    {
        if(GetStateName() != CurrentBallState)
        {
            GotoState(CurrentBallState);
        }
    }
}

auto state PreSpawn
{
    event BeginState()
    {
        PreSpawnTimeStampSeconds = Level.TimeSeconds;

        OwnerBall.bAmbientGlow = true;
        OwnerBall.AmbientGlow = 255;
        OwnerBall.Style = STY_Translucent;
    }

    event EndState()
    {
        OwnerBall.bAmbientGlow = OwnerBall.Class.Default.bAmbientGlow;
        OwnerBall.AmbientGlow = OwnerBall.Class.Default.AmbientGlow;
        OwnerBall.Style = OwnerBall.Class.Default.Style;
    }

    event Tick(float DeltaSeconds)
    {
        Global.Tick(DeltaSeconds);

        if(Level.TimeSeconds - PreSpawnTimeStampSeconds >= PreSpawnDurationSeconds)
        {
            GotoState('Active');
        }
    }
}

state Active
{}

defaultproperties
{
    InitialState=PreSpawn
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
    PreSpawnDurationSeconds=10.0
}