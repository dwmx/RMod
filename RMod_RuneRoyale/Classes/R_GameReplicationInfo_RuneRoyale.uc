class R_GameReplicationInfo_RuneRoyale extends R_GameReplicationInfo;

var Vector RingOrigin;
var float RingRadius;
var Name RingState; // RingState_Idle, RingState_Staged, RingState_Interpolating
var float RingInterpolationTimeSeconds;

replication
{
    reliable if(Role == ROLE_Authority)
        RingState,
        RingOrigin,
        RingRadius;
}