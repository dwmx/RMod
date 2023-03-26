class R_GameInfo_RuneRoyale extends R_GameInfo;

var R_RingManager RingManager;

event PostBeginPlay()
{
    RingManager = Spawn(Class'RMod_RuneRoyale.R_RingManager', Self);
    SetTimer(1.0, true); // Pain timer
}

event Timer()
{
    local PlayerPawn P;

    foreach AllActors(Class'Engine.PlayerPawn', P)
    {
        if(!RingManager.CheckIsActorInsideRing(P))
        {
            P.JointDamaged(5, None, P.Location, P.Velocity, 'None', 0);
        }
    }
}

defaultproperties
{
    GameReplicationInfoClass=Class'RMod_RuneRoyale.R_GameReplicationInfo_RuneRoyale'
    HUDType=Class'RMod_RuneRoyale.R_RunePlayerHUD_RuneRoyale'
}