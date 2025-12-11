//==============================================================================
//  R_APlayerLibrary
//  Library class
//
//  Utility functions that generally require reference to a PlayerPawn
//==============================================================================
class R_APlayerLibrary extends R_ALibrary abstract;

/**
*   GetScreenResolutionFromPlayerPawnInPixels
*   Returns the resolution of the player's viewport in pixels
*   Returns true if resolution successfully retrieved
*/
static function bool GetScreenResolutionFromPlayerPawnInPixels(
    PlayerPawn InPlayerPawn,
    out float OutScreenWidth,
    out float OutScreenHeight)
{
    local String ConsoleCommandResult;
    local String LeftSplit, RightSplit;
    local int SplitIndex;
    
    if(InPlayerPawn == None)
    {
        OutScreenWidth = 0.0;
        OutScreenHeight = 0.0;
        return false;
    }
    
    ConsoleCommandResult = InPlayerPawn.ConsoleCommand("GetCurrentRes");
    SplitIndex = InStr(ConsoleCommandResult, "x");
    
    LeftSplit = Mid(ConsoleCommandResult, 0, SplitIndex);
    RightSplit = Mid(ConsoleCommandResult, SplitIndex + 1);
    
    OutScreenWidth = float(LeftSplit);
    OutScreenHeight = float(RightSplit);
    
    return true;
}

/**
*   IsPlayerLocallyControlled
*   Returns true if InPlayerPawn is locally controlled in the context of
*   the game instance this was called from
*
*   Note:
*   - This function should only be called after initial Possess events have occurred
*   - Some scenarios will return false negatives otheriwise (i.e. Listen server as host)
*/
static function bool IsPlayerLocallyControlled(PlayerPawn InPlayerPawn)
{
    local int InNetMode;
    
    if(InPlayerPawn == None)
    {
        return false;
    }
    
    InNetMode = InPlayerPawn.Level.NetMode;
    
    switch(InNetMode)
    {
        case 0: // NM_Standalone
        case 2: // NM_ListenServer
            return InPlayerPawn.Player != None && Viewport(InPlayerPawn.Player) != None;
        
        case 1: // NM_DedicatedServer
            return false;
        
        case 3: // NM_Client
            return InPlayerPawn.Role == ROLE_AutonomousProxy;
    }
}