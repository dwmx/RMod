class R_RingManager extends Info;

var float RingIdleTimeSeconds;
var float RingStagedTimeSeconds;
var float RingInterpolatingTimeSeconds;

var float TimeStampSeconds;

auto state RingIdle
{
    event BeginState()
    {
        TimeStampSeconds = Level.TimeSeconds;
    }

    event Tick(float DeltaSeconds)
    {
        if(Level.TimeSeconds - TimeStampSeconds >= RingIdleTimeSeconds)
        {
            GotoState('RingStaged');
        }
    }
}

state RingStaged
{
    event BeginState()
    {
        TimeStampSeconds = Level.TimeSeconds;
    }

    event Tick(float DeltaSeconds)
    {
        if(Level.TimeSeconds - TimeStampSeconds >= RingStagedTimeSeconds)
        {
            GotoState('RingInterpolating');
        }
    }
}

state RingInterpolating
{
    event BeginState()
    {
        TimeStampSeconds = Level.TimeSeconds;
    }

    event Tick(float DeltaSeconds)
    {
        if(Level.TimeSeconds - TimeStampSeconds >= RingInterpolatingTimeSeconds)
        {
            GotoState('RingIdle');
        }
    }
}

defaultproperties
{
    RemoteRole=ROLE_None
    RingIdleTimeSeconds=10.0
    RingStagedTimeSeconds=5.0
    RingInterpolatingTimeSeconds=3.0
}