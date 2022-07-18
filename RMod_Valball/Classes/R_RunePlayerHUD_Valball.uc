class R_RunePlayerHUD_Valball extends R_RunePlayerHUD;

simulated function DrawBallHUD(Canvas C, R_Ball Ball, String StringText)
{
    local Actor DrawActor;
    local float DrawX, DrawY, DrawScale;
    local float StrW, StrH;
    local Font SavedFont;
    local Color SilhouetteColor;
    local String DrawString;
    local Texture BackdropTexture;

    if(Pawn(Ball.Owner) != None)
    {
        DrawActor = Ball.Owner;
        DrawString = Pawn(Ball.Owner).PlayerReplicationInfo.PlayerName @ "holding";
    }
    else
    {
        DrawActor = Ball;
        if(Ball.GetCurrentBallStateName() == 'Active')
        {
            DrawString = "Ball here";
        }
        else if(Ball.GetCurrentBallStateName() == 'PreSpawn')
        {
            DrawString = "Ball up in" @ int(Ball.GetBallPreSpawnTimeRemainingSeconds() + 1) $ "...";
        }
    }

    if(CheckActorObscured(DrawActor))
    {
        SilhouetteColor.R = 255;
        SilhouetteColor.G = 255;
        SilhouetteColor.B = 255;
        DrawActorSilhouette(C, DrawActor, SilhouetteColor, true);
    }

    SavedFont = C.Font;
    C.Font = C.MedFont;
    C.StrLen(StringText, StrW, StrH);
    GetActorTransformedDrawPointAndScale(C, DrawActor, DrawX, DrawY, DrawScale);

    DrawX = int(DrawX - (StrW * 0.5));
    DrawY = int(DrawY - (StrH * 0.5));
    
    // Draw a backdrop for added contrast
    BackdropTexture = Texture'RuneFX.swipe_gray';
    C.Style = ERenderStyle.STY_AlphaBlend;
    C.AlphaScale = 0.5;
    C.DrawColor = ColorsClass.Static.ColorWhite();
    C.SetPos(DrawX, DrawY);
    C.DrawTile(BackdropTexture, StrW, StrH, 0.0, 0.0, StrW, StrH);

    C.Style = ERenderStyle.STY_Normal;
    C.SetPos(DrawX, DrawY);
    C.DrawText(DrawString);

    C.Font = SavedFont;
}

simulated function DrawRing(Canvas C)
{
    local Vector RingOrigin;
    local float RingRadius;
    local int RingSegments;
    local int i;
    local float t;

    local Vector P0, P1;

    RingRadius = 512.0;
    RingSegments = 64;

    RingOrigin.X = 0.0;
    RingOrigin.Y = 0.0;
    RingOrigin.Z = 0.0;

    P0.X = 1.0;
    P0.Y = 0.0;
    P0.Z = 0.0;
    P0 = P0 * RingRadius;

    for(i = 1; i <= RingSegments; ++i)
    {
        t = float(i) / float(RingSegments);
        t = t * 2.0 * Pi;
        P1.X = Cos(t) * RingRadius;
        P1.Y = Sin(t) * RingRadius;
        P1.Z = 0.0;

        C.DrawLine3D(P0, P1, 1.0,1.0,1.0);

        P0 = P1;
    }
}

simulated event PostRender(Canvas C)
{
    local R_Ball Ball;
    local Name BallStateName;
    local String StringText;

    Super.PostRender(C);

    foreach AllActors(Class'RMod_Valball.R_Ball', Ball)
    {
        if(Ball.Owner == Self.Owner)
        {
            continue;
        }

        BallStateName = Ball.GetCurrentBallStateName();
        if(BallStateName == 'PreSpawn')
        {
            StringText = "Ball spawning...";
        }
        else if(BallStateName == 'Active')
        {
            StringText = "Ball here";
        }
        DrawBallHUD(C, Ball, StringText);
    }

    DrawRing(C);
}