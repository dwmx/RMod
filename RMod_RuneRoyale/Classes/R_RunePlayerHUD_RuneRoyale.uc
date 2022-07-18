class R_RunePlayerHUD_RuneRoyale extends R_RunePlayerHUD;

simulated function RenderRing(Canvas C, Vector RingOrigin, float RingRadius, Color RingColor)
{
    local int RingSegments;
    local int i;
    local float t;
    local Vector P0, P1;

    RingSegments = 64;

    P0.X = 1.0;
    P0.Y = 0.0;
    P0.Z = 32.0;
    P0 = RingOrigin + (P0 * RingRadius);

    for(i = 1; i <= RingSegments; ++i)
    {
        t = float(i) / float(RingSegments);
        t = t * 2.0 * Pi;
        P1.X = Cos(t) * RingRadius;
        P1.Y = Sin(t) * RingRadius;
        P1.Z = 32.0;

        C.DrawLine3D(P0, P1, 1.0,1.0,1.0);

        P0 = P1;
    }
}

simulated function StateBasedRingRender(Canvas C)
{
    local R_GameReplicationInfo_RuneRoyale GRI;
    GRI = R_GameReplicationInfo_RuneRoyale(PlayerPawn(Owner).GameReplicationInfo);
    if(GRI != None)
    {
        if(GRI.RingStateName == 'RingIdle')
        {
            StateBasedRingRender_RingIdle(C);
        }
        else if(GRI.RingStateName == 'RingStaged')
        {
            StateBasedRingRender_RingStaged(C);
        }
        else if(GRI.RingStateName == 'RingInterpolating')
        {
            StateBasedRingRender_RingInterpolating(C);
        }
    }
}

simulated function StateBasedRingRender_RingIdle(Canvas C)
{
    local R_GameReplicationInfo_RuneRoyale GRI;
    local Color RingColor_Current;

    GRI = R_GameReplicationInfo_RuneRoyale(PlayerPawn(Owner).GameReplicationInfo);
    if(GRI != None)
    {
        RingColor_Current.R = 255;
        RingColor_Current.G = 255;
        RingColor_Current.B = 255;

        RenderRing(C, GRI.RingOrigin_Current, GRI.RingRadius_Current, RingColor_Current);
    }
}

simulated function StateBasedRingRender_RingStaged(Canvas C)
{
    local R_GameReplicationInfo_RuneRoyale GRI;
    local Color RingColor_Current;
    local Color RingColor_Staged;

    GRI = R_GameReplicationInfo_RuneRoyale(PlayerPawn(Owner).GameReplicationInfo);
    if(GRI != None)
    {
        RingColor_Current.R = 255;
        RingColor_Current.G = 255;
        RingColor_Current.B = 255;

        RingColor_Staged.R = 255;
        RingColor_Staged.G = 255;
        RingColor_Staged.B = 0;

        RenderRing(C, GRI.RingOrigin_Current, GRI.RingRadius_Current, RingColor_Current);
        RenderRing(C, GRI.RingOrigin_Staged, GRI.RingRadius_Staged, RingColor_Staged);
    }
}

simulated function StateBasedRingRender_RingInterpolating(Canvas C)
{
    local R_GameReplicationInfo_RuneRoyale GRI;
    local float t;
    local Color RingColor_Current;
    local Color RingColor_Staged;
    local Vector RingOrigin_Interpolating;
    local float RingRadius_Interpolating;

    GRI = R_GameReplicationInfo_RuneRoyale(PlayerPawn(Owner).GameReplicationInfo);
    if(GRI != None)
    {
        t = (Level.TimeSeconds - GRI.RingStateTimeStampSeconds) / GRI.RingInterpolationTimeSeconds;
        t = FClamp(t, 0.0, 1.0);

        Class'RMod_RuneRoyale.R_RingManager'.Static.InterpolateRing
        (
            GRI.RingOrigin_Current, GRI.RingRadius_Current,
            GRI.RingOrigin_Staged, GRI.RingRadius_Staged,
            t,
            RingOrigin_Interpolating, RingRadius_Interpolating
        );

        RingColor_Current.R = 255;
        RingColor_Current.G = 255;
        RingColor_Current.B = 255;

        RingColor_Staged.R = 255;
        RingColor_Staged.G = 255;
        RingColor_Staged.B = 0;

        RenderRing(C, RingOrigin_Interpolating, RingRadius_Interpolating, RingColor_Current);
        RenderRing(C, GRI.RingOrigin_Staged, GRI.RingRadius_Staged, RingColor_Staged);
    }
}

simulated event PostRender(Canvas C)
{
    Super.PostRender(C);

    StateBasedRingRender(C);
}