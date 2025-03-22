class R_GameInfo_TD extends R_GameInfo;

/**
*   PlayerRequestBuild
*   Called server-side by R_RunePlayer_TD when the owning player wants to build something with the specified class
*   at the specified location
*   This is where any authoritative transaction handling should take place
*/
function PlayerRequestBuild(R_RunePlayer_TD RunePlayerTD, Class<R_ABuildableActor> BuildableClass, Vector BuildLocation)
{
    local String PlayerLogString;
    local Rotator SpawnRotation;
    
    if(RunePlayerTD == None)
    {
        return;
    }
    
    PlayerLogString = UtilitiesClass.Static.GetPlayerIdentityLogString(RunePlayerTD);
    UtilitiesClass.Static.RModLog("PlayerRequestBuild called from player {" $ PlayerLogString $ "} CLASS: {" $ BuildableClass $ "} LOCATION: {" $ BuildLocation $ "}");
    
    // For now, just perform the spawn
    if(BuildableClass != None)
    {
        SpawnRotation.Yaw = 0;
        SpawnRotation.Pitch = 0;
        SpawnRotation.Roll = 0;
        Spawn(BuildableClass, RunePlayerTD, /*SpawnTag*/, BuildLocation, SpawnRotation);
    }
}

defaultproperties
{
    RunePlayerClass=Class'RMod_TowerDefense.R_RunePlayer_TD'
}