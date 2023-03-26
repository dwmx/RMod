class R_RunePlayerHUD_RuneRoyale extends R_RunePlayerHUD;

simulated function RenderRing(Canvas C, Vector RingOrigin, float RingRadius, Color RingColor)
{
    local int RingSegments;
    local int i;
    local float t;
    local Vector P0, P1;

    RingSegments = 64;

    P0.X = Cos(0.0) * RingRadius;
    P0.Y = Sin(0.0) * RingRadius;
    P0.Z = 0.0;
    P0 = RingOrigin + P0;

    for(i = 1; i <= RingSegments; ++i)
    {
        t = float(i) / float(RingSegments);
        t = t * 2.0 * Pi;
        P1.X = Cos(t) * RingRadius;
        P1.Y = Sin(t) * RingRadius;
        P1.Z = 0.0;
        P1 = RingOrigin + P1;

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
        //RenderRing(C, GRI.RingOrigin_Staged, GRI.RingRadius_Staged, RingColor_Staged);
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

simulated function RenderGameMessage(Canvas C, String DrawString)
{
    local float DrawX, DrawY;
    local float StrW, StrH;
    local Font SavedFont;
    local Texture BackdropTexture;
    local float BackdropPadding;

    SavedFont = C.Font;
    C.Font = C.BigFont;
    C.StrLen(DrawString, StrW, StrH);

    DrawX = (C.ClipX * 0.5) - (StrW * 0.5);
    DrawY = (C.ClipY * 0.9) - (StrH * 0.5);

    // Draw a backdrop for added contrast
    BackdropTexture = Texture'RuneFX.swipe_gray';
    BackdropPadding = 4.0;
    C.Style = ERenderStyle.STY_AlphaBlend;
    C.AlphaScale = 0.5;
    C.DrawColor = ColorsClass.Static.ColorWhite();
    C.SetPos(DrawX - BackdropPadding, DrawY - BackdropPadding);
    C.DrawTile
    (
        BackdropTexture,
        StrW + (BackdropPadding * 2.0),
        StrH + (BackdropPadding * 2.0),
        0.0, 0.0,
        StrW + (BackdropPadding * 2.0),
        StrH + (BackdropPadding * 2.0)
    );

    C.Style = ERenderStyle.STY_Normal;
    C.SetPos(DrawX, DrawY);
    C.DrawText(DrawString);

    C.Font = SavedFont;
}

simulated function RenderGameWarningMessage(Canvas C, String DrawString)
{
    local float DrawX, DrawY;
    local float StrW, StrH;
    local Font SavedFont;
    local Texture BackdropTexture;
    local float BackdropPadding;
    local Color BackdropColorT0, BackdropColorT1;
    local float GlowT;
    local Color BackdropColor;

    SavedFont = C.Font;
    C.Font = C.BigFont;
    C.StrLen(DrawString, StrW, StrH);

    DrawX = (C.ClipX * 0.5) - (StrW * 0.5);
    DrawY = (C.ClipY * 0.9) - (StrH * 0.5);

    // Backdrop color Interp
    GlowT = (Sin(Level.TimeSeconds * 2.0 * Pi) + 1.0) / 2.0;
    BackdropColorT0 = ColorsClass.Static.ColorRed();
    BackdropColorT1 = ColorsClass.Static.ColorWhite();
    BackdropColor.R = byte((1.0 - GlowT) * float(BackdropColorT0.R) + GlowT * float(BackdropColorT1.R));
    BackdropColor.G = byte((1.0 - GlowT) * float(BackdropColorT0.G) + GlowT * float(BackdropColorT1.G));
    BackdropColor.B = byte((1.0 - GlowT) * float(BackdropColorT0.B) + GlowT * float(BackdropColorT1.B));

    // Draw a backdrop for added contrast
    BackdropTexture = Texture'RuneFX.swipe_gray';
    BackdropPadding = 4.0;
    C.Style = ERenderStyle.STY_AlphaBlend;
    C.AlphaScale = 0.5;
    C.DrawColor = BackdropColor;
    C.SetPos(DrawX - BackdropPadding, DrawY - BackdropPadding);
    C.DrawTile
    (
        BackdropTexture,
        StrW + (BackdropPadding * 2.0),
        StrH + (BackdropPadding * 2.0),
        0.0, 0.0,
        StrW + (BackdropPadding * 2.0),
        StrH + (BackdropPadding * 2.0)
    );

    C.Style = ERenderStyle.STY_Normal;
    C.SetPos(DrawX, DrawY);
    C.DrawText(DrawString);

    C.DrawColor = ColorsClass.Static.ColorWhite();
    C.Font = SavedFont;
}

simulated function StateBasedMessageRender(Canvas C)
{
    local R_GameReplicationInfo_RuneRoyale GRI;
    GRI = R_GameReplicationInfo_RuneRoyale(PlayerPawn(Owner).GameReplicationInfo);
    if(GRI != None)
    {
        if(GRI.RingStateName == 'RingIdle')
        {
        }
        else if(GRI.RingStateName == 'RingStaged')
        {
            StateBasedMessageRender_RingStaged(C);
        }
        else if(GRI.RingStateName == 'RingInterpolating')
        {
        }
    }
}

simulated event StateBasedMessageRender_RingStaged(Canvas C)
{
    local R_GameReplicationInfo_RuneRoyale GRI;
    local float TimeRemainingSeconds;
    local String DrawString;

    GRI = R_GameReplicationInfo_RuneRoyale(PlayerPawn(Owner).GameReplicationInfo);
    TimeRemainingSeconds = GRI.GetRemainingStateTimeSeconds();
    DrawString = "Ring closing in" @ int(TimeRemainingSeconds + 1.0) $ "...";

    RenderGameWarningMessage(C, DrawString);
}

simulated event PostRender(Canvas C)
{
    Super.PostRender(C);

    StateBasedRingRender(C);
    StateBasedMessageRender(C);
}