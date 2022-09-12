class R_RunePlayerHUD_LastManStanding extends R_RunePlayerHUD;

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

simulated function RenderGameStateMessage(Canvas C)
{
    local R_GameReplicationInfo_LastManStanding GRI;

    if(PlayerPawn(Owner) != None)
    {
        GRI = R_GameReplicationInfo_LastManStanding(PlayerPawn(Owner).GameReplicationInfo);
        if(GRI != None)
        {
            RenderGameMessage(C, String(GRI.GameStateName));
        }
    }
}

simulated event PostRender(Canvas C)
{
    Super.PostRender(C);
    RenderGameStateMessage(C);
}