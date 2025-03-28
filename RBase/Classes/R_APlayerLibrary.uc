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