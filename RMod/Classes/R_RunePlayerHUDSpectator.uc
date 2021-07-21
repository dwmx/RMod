class R_RunePlayerHUDSpectator extends R_RunePlayerHUD;

var bool bRenderPlayersThroughWalls;
var bool bRenderPlayerNames;

// For drawing players through walls
struct FSavedActorDrawData
{
    var Vector          DesiredColorAdjust;
    var Vector          ColorAdjust;
    var bool            bUnlit;
    var bool            bHidden;
    var float           AlphaScale;
    var ERenderStyle    Style;
    var float           DrawScale;
    var byte            Fatness;
    var byte            DesiredFatness;
    var Texture         SkelGroupSkins[16];
};

//==============================================================================
//  CheckPawnObscured
//  Returns true if Pawn P is visually obscured.
simulated function bool CheckPawnObscured(Pawn P)
{
    local Vector TraceStart;
    local Vector TraceEnd;

    TraceStart  = Pawn(Owner).ViewLocation;
    TraceEnd    = P.Location;

    if(FastTrace(TraceEnd, TraceStart))
    {
        return false;
    }    
    return true;
}

//==============================================================================
simulated function private SaveActorDrawData(
    Actor A, out FSavedActorDrawData DrawData)
{
    local int i;
    DrawData.DesiredColorAdjust    = A.DesiredColorAdjust;
    DrawData.ColorAdjust           = A.ColorAdjust;
    DrawData.bUnlit                = A.bUnlit;
    DrawData.bHidden               = A.bHidden;
    DrawData.AlphaScale            = A.AlphaScale;
    DrawData.Style                 = A.Style;
    DrawData.DrawScale             = A.DrawScale;
    DrawData.DesiredFatness        = A.DesiredFatness;
    DrawData.Fatness               = A.Fatness;
    for(i = 0; i < 16; ++i)
    {
        DrawData.SkelGroupSkins[i] = A.SkelGroupSkins[i];
    }
}

simulated function private RestoreActorDrawData(
    Actor A, out FSavedActorDrawData DrawData)
{
    local int i;
    A.DesiredColorAdjust    = DrawData.DesiredColorAdjust;
    A.ColorAdjust           = DrawData.ColorAdjust;
    A.bUnlit                = DrawData.bUnlit;
    A.bHidden               = DrawData.bHidden;
    A.AlphaScale            = DrawData.AlphaScale;
    A.Style                 = DrawData.Style;
    A.DrawScale             = DrawData.DrawScale;
    A.DesiredFatness        = DrawData.DesiredFatness;
    A.Fatness               = DrawData.Fatness;
    for(i = 0; i < 16; ++i)
    {
        A.SkelGroupSkins[i] = DrawData.SkelGroupSkins[i];
    }
}

//==============================================================================
//  DrawActorSilhouette
//  Draw a colored silhouette in place of the Actor.
simulated function DrawActorSilhouette(
    Canvas C, Actor A, Color DrawColor, bool bClearZ, optional byte Fatness)
{
    local Vector                VectorColor;
    local Actor                 ActorArray[3];
    local FSavedActorDrawData   ActorArraySaved[3];
    local int                   ActorCount;
    local int                   i, j;

    if(Fatness == 0)
    {
        Fatness = A.Fatness;
    }

    VectorColor.X = DrawColor.R;
    VectorColor.Y = DrawColor.G;
    VectorColor.Z = DrawColor.B;

    ActorCount = 0;
    ActorArray[ActorCount++] = A;
    if(Pawn(A) != None)
    {
        if(Pawn(A).Weapon != None)
        {
            ActorArray[ActorCount++] = Pawn(A).Weapon;
        }
        if(Pawn(A).Shield != None)
        {
            ActorArray[ActorCount++] = Pawn(A).Shield;
        }
    }

    // Saved Actor properties and apply silhouette properties
    // TODO: Perform this for stowed but visible inventories as well
    for(i = 0; i < ActorCount; ++i)
    {
        SaveActorDrawData(ActorArray[i], ActorArraySaved[i]);
        for(j = 0; j < 16; ++j)
        {
            ActorArray[i].SkelGroupSkins[j] = Texture'RMenu.icons.stonemenub';
        }
        
        ActorArray[i].DesiredColorAdjust    = VectorColor;
        ActorArray[i].ColorAdjust           = VectorColor;
        ActorArray[i].bUnlit                = true;
        ActorArray[i].bHidden               = false;
        ActorArray[i].AlphaScale            = 1.0;
        ActorArray[i].Style                 = STY_AlphaBlend;
        ActorArray[i].DesiredFatness        = Fatness;
        ActorArray[i].Fatness               = Fatness;
    }

    // Draw only the recieved Actor. If Actor is a Pawn, its Weapon and Shield 
    // will also be drawn.
    C.DrawActor(A, false, bClearZ);

    // Restore Actor properties
    for(i = 0; i < ActorCount; ++i)
    {
        RestoreActorDrawData(ActorArray[i], ActorArraySaved[i]);
    }
}

//==============================================================================
//  GetPawnTransformedDrawPoint
//
//  Get the point directly above a pawn's head, used for drawing things like
//  team indicator and chat bubble.
simulated function GetPawnTransformedDrawPointAndScale(
    Canvas C, Pawn P,
    out float PosX,
    out float PosY,
    out float Scale)
{
    local Vector    WorldLocation;
    local float     ViewDistance;
    local int       CPosX, CPosY;

    WorldLocation = P.Location;
    WorldLocation.Z += P.CollisionHeight;
    WorldLocation.Z += 16.0;

    C.TransformPoint(WorldLocation, CPosX, CPosY);
    PosX = float(CPosX);
    PosY = float(CPosY);

    ViewDistance = VSize(WorldLocation - Pawn(Owner).ViewLocation);
    Scale = 256.0 / ViewDistance;
    Scale = FClamp(Scale, 0.3, 1.0);
}

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
    GetPawnTransformedDrawPointAndScale(C, P, DrawX, DrawY, DrawScale);

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
        if(bRenderPlayersThroughWalls && CheckPawnObscured(P))
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