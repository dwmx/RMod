//==============================================================================
// R_GameInfo_TD
// Main GameInfo class for RMod Tower Defense game mode
//
// Important Notes:
// - All levels must include one (and only one) R_LevelDescription_TD actor
//      - This actor configures all level-specific stuff that this class needs
//==============================================================================
class R_GameInfo_TD extends R_GameInfo;

// Initialized at startup, each level should contain one and only one
var R_LevelDescription_TD LevelDescriptionActor;

// The following properties are initialized from LevelDescriptionActor
var R_MobPathNode InitialMobPathNode; // The first path node mobs run to

// The current game round
var Class<R_GameRound_TD> GameRoundClass;
var R_GameRound_TD GameRoundInstance;

/**
*   PreBeginPlay (override)
*   Overridden to initialize level-specific game configuration
*/
event PreBeginPlay()
{
    Super.PreBeginPlay();
    InitializeLevelDescriptionActor();
}

/**
*   InitializeLevelDescriptionActor
*   Finds the level's R_LevelDescription_TD actor and saves it
*   Logs successful initialization or warns failure
*/
function InitializeLevelDescriptionActor()
{
    local R_LevelDescription_TD LevelDescriptionIt;
    
    foreach AllActors(Class'R_LevelDescription_TD', LevelDescriptionIt)
    {
        if(LevelDescriptionActor != None)
        {
            // Multiple level description actors found
            LevelDescriptionActor = None;
            UtilitiesClass.Static.RModWarn(
                "R_GameInfo_TD.InitializeLevelDescriptionActor found multiple R_LevelDescription_TD actors in level"
                @ "Levels should contain one and only one R_LevelDescription_TD actor");
            return;
        }
        
        LevelDescriptionActor = LevelDescriptionIt;
    }
    
    if(LevelDescriptionActor == None)
    {
        UtilitiesClass.Static.RModWarn(
            "R_GameInfo_TD.InitializeLevelDescriptionActor failed to find R_LevelDescription_TD actor in level"
            @ "Levels should contain one and only one R_LevelDescription_TD actor");
        return;
    }
    
    UtilitiesClass.Static.RModLog("R_GameInfo_TD initialized LevelDescriptionActor using" @ LevelDescriptionActor);
    
    // Resolve the initial path node
    InitialMobPathNode = Class'R_MobPathNode'.Static.ResolveNodeFromTag(LevelDescriptionActor.InitialPathNodeTag, Self);
    if(InitialMobPathNode == None)
    {
        UtilitiesClass.Static.RModWarn(
            "R_GameInfo_TD failed to resolve InitialMobPathNode from tag" @ LevelDescriptionActor.InitialPathNodeTag);
    }
    else
    {
        UtilitiesClass.Static.RModLog(
            "R_GameInfo_TD initialized InitialMobPathNode from tag"
            @ LevelDescriptionActor.InitialPathNodeTag
            @ "Actor: {" $ InitialMobPathNode $ "}");
    }
}

/**
*   PostBeginPlay (override)
*   Overridden to test game rounds
*/
event PostBeginPlay()
{
    Super.PostBeginPlay();
    StartGameRound();
}

function StartGameRound()
{
    if(GameRoundClass == None)
    {
        UtilitiesClass.Static.RModWarn("StartGameRound failed due to improperly configured GameRoundClass" @ GameRoundClass);
        return;
    }
    
    GameRoundInstance = new(None) GameRoundClass;
    if(GameRoundInstance == None)
    {
        UtilitiesClass.Static.RModWarn("StartGameRound failed to spawn GameRound from class" @ GameRoundClass);
        return;
    }
    
    GameRoundInstance.InitializeGameRound(Self);
}

/**
*   Tick (override)
*   Overridden to pass tick to GameRound when it's active
*/
event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);
    
    if(GameRoundInstance != None)
    {
        GameRoundInstance.TickGameRound(DeltaSeconds);
    }
}

/**
*   Killed (override)
*/
function Killed(Pawn Killer, Pawn Victim, Name DamageType)
{
    if(Victim.IsA('R_Mob'))
    {
        // Nothing for now
        return;
    }
    else
    {
        Super.Killed(Killer, Victim, DamageType);
    }
}

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
    GameRoundClass=Class'RMod_TowerDefense.R_GameRound_TD'
}