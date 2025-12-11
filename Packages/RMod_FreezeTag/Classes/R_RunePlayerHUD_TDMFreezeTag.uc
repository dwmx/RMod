class R_RunePlayerHUD_TDMFreezeTag extends R_RunePlayerHUD;

var Texture TeammateIconTexture;

simulated function DrawTeammateIcons(Canvas C)
{
    local R_RunePlayer RRP;
    local R_PlayerReplicationInfo_FreezeTag RPRIFT;
    local byte OwnerTeamIndex;
    local float DrawX, DrawY, DrawScale;
    local float DrawWidth, DrawHeight;

    OwnerTeamIndex = 255;
    if(R_RunePlayer(Owner) != None)
    {
        if(R_PlayerReplicationInfo(R_RunePlayer(Owner).PlayerReplicationInfo) != None)
        {
            OwnerTeamIndex = R_PlayerReplicationInfo(R_RunePlayer(Owner).PlayerReplicationInfo).Team;
        }
    }

    foreach AllActors(Class'RMod.R_RunePlayer', RRP)
    {
        if(RRP == Owner || RRP.bHidden)
        {
            continue;
        }

        RPRIFT = R_PlayerReplicationInfo_FreezeTag(RRP.PlayerReplicationInfo);
        if(RPRIFT != None && RPRIFT.Team == OwnerTeamIndex)
        {
            if(RPRIFT.bIsFrozen)
            {
                C.DrawColor = ColorsClass.Static.ColorBlue();
            }
            else
            {
                C.DrawColor = ColorsClass.Static.ColorWhite();
            }

            GetActorTransformedDrawPointAndScale(C, RRP, DrawX, DrawY, DrawScale);
            DrawWidth = 32 * DrawScale;
            DrawHeight = 32 * DrawScale;
            C.SetPos(DrawX - (DrawWidth * 0.5), DrawY - (DrawHeight * 0.5));
            C.DrawTile(TeammateIconTexture, DrawWidth, DrawHeight, 0, 0, TeammateIconTexture.USize, TeammateIconTexture.VSize);
        }
    }
}

simulated event PostRender(Canvas C)
{
    Super.PostRender(C);
    DrawTeammateIcons(C);
}

defaultproperties
{
    TeammateIconTexture=Texture'Engine.S_TreePoint'
}