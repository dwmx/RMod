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
    local Vector InitialRingOrigin;
    local float InitialRingRadius;

    GetInitialRingProperties(InitialRingOrigin, InitialRingRadius);

    // Initial ring parameters
    RingOrigin_Active = InitialRingOrigin;
    RingRadius_Active = InitialRingRadius;

    RingOrigin_Current = RingOrigin_Active;
    RingOrigin_Staged = RingOrigin_Active;

    RingRadius_Current = RingRadius_Active;
    RingRadius_Staged = RingRadius_Active;
}

//==============================================================================
// GetInitialRingProperties
// Build the initial ring radius and origin based on a bounding box surrounding
// all available player starts
function GetInitialRingProperties(out Vector OutRingOrigin, out float OutRingRadius)
{
    local Vector AABBMin, AABBMax, AABBMid;
    local PlayerStart PS;
    local int NumSamples;
    local Vector CurrentLocation;
    local float WorkingRadius, CurrentDistance;

    AABBMin.X = 10000000.0;
    AABBMin.Y = 10000000.0;
    AABBMin.Z = 0.0;
    AABBMax.X = -10000000.0;
    AABBMax.Y = -10000000.0;
    AABBMax.Z = 0.0;

    // Build AABB around all player starts
    NumSamples = 0;
    foreach AllActors(Class'Engine.PlayerStart', PS)
    {
        if(PS.Location.X < AABBMin.X)    AABBMin.X = PS.Location.X;
        if(PS.Location.Y < AABBMin.Y)    AABBMin.Y = PS.Location.Y;
        if(PS.Location.X > AABBMax.X)    AABBMax.X = PS.Location.X;
        if(PS.Location.Y > AABBMax.Y)    AABBMax.Y = PS.Location.Y;
        ++NumSamples;
    }

    // In some event where there are no player starts, return a default ring
    if(NumSamples == 0)
    {
        OutRingOrigin.X = 0.0;
        OutRingOrigin.Y = 0.0;
        OutRingOrigin.Z = 0.0;
        OutRingRadius = 4096.0;
    }

    // Mid point of the AABB
    AABBMid = AABBMin + ((AABBMax - AABBMin) * 0.5);
    AABBMid.Z = 0.0;

    // Starting radius will be based on the point furthest from the mid point
    WorkingRadius = 0.0;
    foreach AllActors(Class'Engine.PlayerStart', PS)
    {
        CurrentLocation = PS.Location;
        CurrentLocation.Z = 0.0;
        CurrentDistance = VSize(CurrentLocation - AABBMid);
        if(CurrentDistance > WorkingRadius)
        {
            WorkingRadius = CurrentDistance;
        }
    }

    // Return
    OutRingOrigin = AABBMid;
    OutRingRadius = WorkingRadius * 1.25; // 25% larger than farthest point
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

function ReplicateRingStateTimers()
{
    local R_GameReplicationInfo_RuneRoyale GRI;

    GRI = R_GameReplicationInfo_RuneRoyale(Level.Game.GameReplicationInfo);
    if(GRI != None)
    {
        GRI.RingIdleTimeSeconds = RingIdleTimeSeconds;
        GRI.RingStagedTimeSeconds = RingStagedTimeSeconds;
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
        ReplicateRingStateTimers();
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
        ReplicateRingStateTimers();
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
        CalcNewRing(RingOrigin_Current, RingRadius_Current, 0.75, RingOrigin_Staged, RingRadius_Staged);
    }
}

state RingInterpolating
{
    event BeginState()
    {
        TimeStampSeconds = Level.TimeSeconds;
        ReplicateRingStateName();
        ReplicateRingStateTimers();
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
    RingStagedTimeSeconds=15.0
    RingInterpolationTimeSeconds=15.0
}