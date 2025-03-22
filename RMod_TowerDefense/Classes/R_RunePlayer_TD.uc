class R_RunePlayer_TD extends R_RunePlayer;

var Class<R_BuilderBrush> BuilderBrushClass;
var R_BuilderBrush BuilderBrush;

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

exec function TestBuilderBrush()
{
    UtilitiesClass.Static.RModLog("Builder Brush called");
    SpawnBuilderBrush();
}

defaultproperties
{
    BuilderBrushClass=Class'RMod_TowerDefense.R_BuilderBrush'
}