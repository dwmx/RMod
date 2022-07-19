class R_RingManager extends Info;

var float RingIdleTimeSeconds;
var float RingStagedTimeSeconds;
var float RingInterpolationTimeSeconds;
var float TimeStampSeconds;

var Vector RingOrigin_Current;  // Interp t0
var float RingRadius_Current;
var Vector RingOrigin_Staged;   // Interp t1
var float RingRadius_Staged;

// The actual ring
var Vector RingOrigin_Active;
var float RingRadius_Active;

event PostBeginPlay()
{
    // Initial ring parameters
    RingOrigin_Active.X = 0.0;
    RingOrigin_Active.Y = 0.0;
    RingOrigin_Active.Z = 0.0;
    RingRadius_Active = 2048.0;

    RingOrigin_Current = RingOrigin_Active;
    RingOrigin_Staged = RingOrigin_Active;

    RingRadius_Current = RingRadius_Active;
    RingRadius_Staged = RingRadius_Active;
}

function ReplicateRingStateName()
{
    local R_GameReplicationInfo_RuneRoyale GRI;

    GRI = R_GameReplicationInfo_RuneRoyale(Level.Game.GameReplicationInfo);
    if(GRI != None)
    {
        GRI.RingStateName = GetStateName();
    }
}

function ReplicateRingCurrent()
{
    local R_GameReplicationInfo_RuneRoyale GRI;

    GRI = R_GameReplicationInfo_RuneRoyale(Level.Game.GameReplicationInfo);
    if(GRI != None)
    {
        GRI.RingOrigin_Current = RingOrigin_Current;
        GRI.RingRadius_Current = RingRadius_Current;
        GRI.RingInterpolationTimeSeconds = RingInterpolationTimeSeconds;
    }
}

function ReplicateRingStaged()
{
    local R_GameReplicationInfo_RuneRoyale GRI;

    GRI = R_GameReplicationInfo_RuneRoyale(Level.Game.GameReplicationInfo);
    if(GRI != None)
    {
        GRI.RingOrigin_Staged = RingOrigin_Staged;
        GRI.RingRadius_Staged = RingRadius_Staged;
        GRI.RingInterpolationTimeSeconds = RingInterpolationTimeSeconds;
    }
}

function CalcNewRing
(
    Vector InOrigin,
    float InRadius,
    float InScaleFactor,
    out Vector OutOrigin,
    out float OutRadius
)
{
    local float NewRadius;
    local float MaxOffset;
    local float Offset;
    local float RandAngle;

    NewRadius = InRadius * InScaleFactor;
    MaxOffset = InRadius - NewRadius;

    Offset = MaxOffset * Sqrt(FRand());
    RandAngle = FRand() * 2.0 * Pi;
    
    OutOrigin.X = OutOrigin.X + Offset * Cos(RandAngle);
    OutOrigin.Y = OutOrigin.Y + Offset * Sin(RandAngle);
    OutRadius = NewRadius;
}

static function InterpolateRing
(
    Vector T0_Origin, float T0_Radius,
    Vector T1_Origin, float T1_Radius,
    float t,
    out Vector OutOrigin, out float OutRadius
)
{
    OutOrigin.X = Lerp(t, T0_Origin.X, T1_Origin.X);
    OutOrigin.Y = Lerp(t, T0_Origin.Y, T1_Origin.Y);
    OutOrigin.Z = 0.0;
    OutRadius = Lerp(t, T0_Radius, T1_Radius);
}

auto state RingIdle
{
    event BeginState()
    {
        TimeStampSeconds = Level.TimeSeconds;
        ReplicateRingStateName();
        FinalizeCurrentRing();
        ReplicateRingCurrent();
    }

    event Tick(float DeltaSeconds)
    {
        if(Level.TimeSeconds - TimeStampSeconds >= RingIdleTimeSeconds)
        {
            GotoState('RingStaged');
        }
    }

    function FinalizeCurrentRing()
    {
        RingOrigin_Current = RingOrigin_Staged;
        RingRadius_Current = RingRadius_Staged;

        RingOrigin_Active = RingOrigin_Current;
        RingRadius_Active = RingRadius_Current;
    }
}

state RingStaged
{
    event BeginState()
    {
        TimeStampSeconds = Level.TimeSeconds;
        ReplicateRingStateName();
        StageNextRing();
        ReplicateRingStaged();
    }

    event Tick(float DeltaSeconds)
    {
        if(Level.TimeSeconds - TimeStampSeconds >= RingStagedTimeSeconds)
        {
            GotoState('RingInterpolating');
        }
    }

    function StageNextRing()
    {
        CalcNewRing(RingOrigin_Current, RingRadius_Current, 0.5, RingOrigin_Staged, RingRadius_Staged);
    }
}

state RingInterpolating
{
    event BeginState()
    {
        TimeStampSeconds = Level.TimeSeconds;
        ReplicateRingStateName();
    }

    event Tick(float DeltaSeconds)
    {
        local float t;

        if(Level.TimeSeconds - TimeStampSeconds >= RingInterpolationTimeSeconds)
        {
            GotoState('RingIdle');
        }

        t = (Level.TimeSeconds - TimeStampSeconds) / RingInterpolationTimeSeconds;
        t = FClamp(t, 0.0, 1.0);

        InterpolateRing(
            RingOrigin_Current, RingRadius_Current,
            RingOrigin_Staged, RingRadius_Staged,
            t,
            RingOrigin_Active, RingRadius_Active);
    }
}

function bool CheckIsActorInsideRing(Actor A)
{
    local Vector RingOrigin2D;
    local Vector ActorLocation2D;
    local Vector Delta;

    RingOrigin2D = RingOrigin_Active;
    RingOrigin2D.Z = 0.0;

    ActorLocation2D = A.Location;
    ActorLocation2D.Z = 0.0;

    Delta = ActorLocation2D - RingOrigin2D;
    if(VSize(Delta) <= RingRadius_Active)
    {
        return true;
    }
    else
    {
        return false;
    }
}

defaultproperties
{
    RemoteRole=ROLE_None
    RingIdleTimeSeconds=10.0
    RingStagedTimeSeconds=5.0
    RingInterpolationTimeSeconds=3.0
}