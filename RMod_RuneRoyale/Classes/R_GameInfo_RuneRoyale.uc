class R_GameInfo_RuneRoyale extends R_GameInfo;

var R_RingManager RingManager;

event PostBeginPlay()
{
    RingManager = Spawn(Class'RMod_RuneRoyale.R_RingManager', Self);
}

defaultproperties
{
    GameReplicationInfoClass=Class'RMod_RuneRoyale.R_GameReplicationInfo_RuneRoyale'
    HUDType=Class'RMod_RuneRoyale.R_RunePlayerHUD_RuneRoyale'
}