class R_GameReplicationInfo_RuneRoyale extends R_GameReplicationInfo;

var Name RingStateName;
var Name RingStateNameCached;

var float RingIdleTimeSeconds;
var float RingStagedTimeSeconds;
var float RingInterpolationTimeSeconds;
var float RingStateTimeStampSeconds;

var Vector RingOrigin_Current;
var float RingRadius_Current;
var Vector RingOrigin_Staged;
var float RingRadius_Staged;

replication
{
    reliable if(Role == ROLE_Authority)
        RingStateName,
        RingOrigin_Current,
        RingRadius_Current,
        RingOrigin_Staged,
        RingRadius_Staged,
        RingIdleTimeSeconds,
        RingStagedTimeSeconds,
        RingInterpolationTimeSeconds;
}

simulated event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);

    if(RingStateNameCached != RingStateName)
    {
        RingStateNameCached = RingStateName;
        RingStateTimeStampSeconds = Level.TimeSeconds;
    }
}

simulated function float GetRemainingStateTimeSeconds()
{
    local float TimeDelta;
    local float Result;

    TimeDelta = Level.TimeSeconds - RingStateTimeStampSeconds;

    if(RingStateName == 'RingIdle')
    {
        Result = RingIdleTimeSeconds - TimeDelta;
    }
    else if(RingStateName == 'RingStaged')
    {
        Result = RingStagedTimeSeconds - TimeDelta;
    }
    else if(RingStateName == 'RingInterpolating')
    {
        Result = RingInterpolationTimeSeconds - TimeDelta;
    }

    Result = Max(Result, 0.0);
    return Result;
}