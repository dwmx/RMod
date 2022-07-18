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
}