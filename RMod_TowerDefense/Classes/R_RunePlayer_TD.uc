class R_RunePlayer_TD extends R_RunePlayer;

var Class<R_BuilderBrush> BuilderBrushClass;
var R_BuilderBrush BuilderBrush;

replication
{
    // Client --> Server functions
    reliable if(Role < ROLE_Authority)
        ServerTryExecuteBuild;
}

/**
*   PostRender (override)
*   Overridden to send PostRender calls to the BuilderBrush when it's active
*/
event PostRender(Canvas C)
{
    Super.PostRender(C);
    if(BuilderBrush != None)
    {
        BuilderBrush.BuilderBrushPostRender(C);
    }
}

/**
*   SpawnBuilderBrush
*   Primary function for spawning the BuilderBrush local actor when player enters build mode
*   BuilderBrush will only be spawned on the locally controlled player (client or server)
*/
function SpawnBuilderBrush()
{
    local Class<R_BuilderBrush> LocalBuilderBrushClass;
    local Rotator SpawnRotation;

    if(BuilderBrush != None)
    {
        BuilderBrush.Destroy();
    }
    
    LocalBuilderBrushClass = BuilderBrushClass;
    if(LocalBuilderBrushClass == None)
    {
        LocalBuilderBrushClass = Class'RMod_TowerDefense.R_BuilderBrush';
    }
    
    if(LocalBuilderBrushClass != None)
    {
        SpawnRotation.Yaw = 0;
        SpawnRotation.Pitch = 0;
        SpawnRotation.Roll = 0;
        BuilderBrush = Spawn(LocalBuilderBrushClass, Self, /*SpawnTag*/, Location, SpawnRotation);
    }
    
    // Log failed spawns -- class may be configured incorrectly
    if(LocalBuilderBrushClass == None || BuilderBrush == None)
    {
        UtilitiesClass.Static.RModWarn("Failed to spawn BuilderBrush from class" @ LocalBuilderBrushClass);
    }
}

/**
*   ServerTryExecuteBuild
*   Client --> Server
*   Tells the current game info that this player wants to build the specified class at the specified location
*   Owning R_GameInfo_TD will perform the transaction, spawn the building and notify the player
*/
function ServerTryExecuteBuild(Class<R_ABuildableActor> BuildableClass, Vector BuildLocation)
{
    local R_GameInfo_TD GameInfoTD;
    
    GameInfoTD = R_GameInfo_TD(Level.Game);
    if(GameInfoTD != None)
    {
        if(BuildableClass != None)
        {
            GameInfoTD.PlayerRequestBuild(Self, BuildableClass, BuildLocation);
        }
        else
        {
            UtilitiesClass.Static.RModWarn("R_RunePlayer_TD.ServerTryExecuteBuild called with BuildableClass == None");
            return;
        }
    }
}

/**
*   TryExecuteBuilderBrush
*   Called locally
*   Verifies builder brush location and class locally, and then sends RPC to server
*/
function TryExecuteBuilderBrush()
{
    local Class<R_ABuildableActor> BuildableClass;
    
    if(BuilderBrush != None)
    {
        BuildableClass = BuilderBrush.GetBuildableActorClass();
        if(BuildableClass != None)
        {
            ServerTryExecuteBuild(BuildableClass, BuilderBrush.Location);
        }
    }
}

//==============================================================================
// Test exec functions
exec function TestExecuteBuilderBrush()
{
    UtilitiesClass.Static.RModLog("TestExecuteBuilderBrush called");
    if(BuilderBrush != None)
    {
        TryExecuteBuilderBrush();
    }
}

exec function TestBuilderBrush()
{
    UtilitiesClass.Static.RModLog("Builder Brush called");
    SpawnBuilderBrush();
}

exec function TestBuildableIndex(int BuildableIndex)
{
    local Class<R_ABuildableActor> BuildableClass;
    
    UtilitiesClass.Static.RModLog("TestBuildableIndex called");
    
    if(BuilderBrush != None)
    {
        switch(BuildableIndex)
        {
            case 0: BuildableClass = Class'R_Buildable_Skin'; break;
            case 1: BuildableClass = Class'R_Buildable_Table'; break;
            case 2: BuildableClass = Class'R_Buildable_Keg'; break;
            default: BuildableClass = None;
        }
        
        BuilderBrush.SetBuildableActorClass(BuildableClass);
    }
}
//==============================================================================

defaultproperties
{
    BuilderBrushClass=Class'RMod_TowerDefense.R_BuilderBrush'
}