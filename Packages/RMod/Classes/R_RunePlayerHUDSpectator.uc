class R_RunePlayerHUDSpectator extends R_RunePlayerHUD;

var bool bRenderPlayersThroughWalls;
var bool bRenderPlayerNames;

//==============================================================================
simulated function DrawPlayerName(Canvas C, Pawn P)
{
    local float DrawX, DrawY, DrawScale;
    local float StrW, StrH;
    local String DrawString;
    local Texture BackdropTexture;

    if(P.PlayerReplicationInfo == None)
    {
        return;
    }

    if(MyFonts != None)
    {
		C.Font = MyFonts.GetStaticBigFont();
    }
    else
    {
		C.Font = C.BigFont;
    }

    DrawString = P.PlayerReplicationInfo.PlayerName;
    C.StrLen(DrawString, StrW, StrH);
    GetActorTransformedDrawPointAndScale(C, P, DrawX, DrawY, DrawScale);

    DrawX = int(DrawX - (StrW * 0.5));
    DrawY = int(DrawY - (StrH * 0.5));

    // Draw a backdrop for added contrast
    BackdropTexture = Texture'RuneFX.swipe_gray';
    C.Style = ERenderStyle.STY_AlphaBlend;
    C.AlphaScale = 0.5;
    C.DrawColor = ColorsClass.Static.ColorWhite();
    C.SetPos(DrawX, DrawY);
    C.DrawTile(BackdropTexture, StrW, StrH, 0.0, 0.0, BackdropTexture.USize, BackdropTexture.VSize);

    C.Style = ERenderStyle.STY_Normal;
    C.SetPos(DrawX, DrawY);
    C.DrawText(DrawString);
}

//==============================================================================
simulated event PostRender(Canvas C)
{
    local Pawn P;

    Super.PostRender(C);

    foreach AllActors(Class'Engine.Pawn', P)
    {
        if(P.PlayerReplicationInfo == None)         continue;
        if(P.PlayerReplicationInfo.bIsSpectator)    continue;
        if(P.bHidden)                               continue;
        if(P == Pawn(Owner))                        continue;

        // Draw player names
        if(bRenderPlayerNames)
        {
            DrawPlayerName(C, P);
        }

        // Draw through walls
        if(bRenderPlayersThroughWalls && CheckActorObscured(P))
        {
            DrawActorSilhouette(
                C, P,
                ColorsClass.Static.GetTeamColor(P.PlayerReplicationInfo.Team),
                true,           // bClearZ = true = Draw through walls
                P.Fatness);     // Silhouette thicknes
        }
    }
}

defaultproperties
{
    bRenderPlayersThroughWalls=true
    bRenderPlayerNames=true
}