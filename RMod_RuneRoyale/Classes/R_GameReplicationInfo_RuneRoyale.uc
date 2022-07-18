class R_GameReplicationInfo_RuneRoyale extends R_GameReplicationInfo;

var Name RingStateName;
var Name RingStateNameCached;
var float RingStateTimeStampSeconds;

var Vector RingOrigin_Current;
var float RingRadius_Current;
var Vector RingOrigin_Staged;
var float RingRadius_Staged;
var float RingInterpolationTimeSeconds;

replication
{
    reliable if(Role == ROLE_Authority)
        RingStateName,
        RingOrigin_Current,
        RingRadius_Current,
        RingOrigin_Staged,
        RingRadius_Staged,
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