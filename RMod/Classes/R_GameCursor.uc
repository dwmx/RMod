//==============================================================================
// R_GameCursor
// A cursor meant specifically for use in-game, and not in Rune UI
// Owning R_RunePlayer must spawn this locally and pass mouse movement to it
//==============================================================================
class R_GameCursor extends Object;

var Class<R_AUtilities> UtilitiesClass;

var R_RunePlayer CursorOwner;

var float CursorX, CursorY;
var Texture CursorTexture;

var bool bRecenterMouse;

var bool bCursorEnabled;
var bool bConsumeMouseInput;

/**
*   PlayerInputMouseMove
*   Input X and Y mouse movement
*   To be called by owner's PlayerInput function
*/
function PlayerInputMouseMove(float MoveX, float MoveY, float DeltaSeconds)
{
    CursorX += MoveX * DeltaSeconds;
    CursorY += MoveY * DeltaSeconds * -1.0;
}

/**
*   NotifyEnabled
*   Called by owner when this cursor has been enabled
*/
function NotifyEnabled(R_RunePlayer Caller)
{
    // Tells cursor to recenter itself
    bRecenterMouse = true;
    
    CursorOwner = Caller;
    
    bCursorEnabled = true;
}

function NotifyDisabled()
{
    bCursorEnabled = false;
}

function bool IsEnabled()
{
    return bCursorEnabled;
}

function bool IsConsumingMouseInputWhenEnabled()
{
    return bConsumeMouseInput;
}

/**
*   TraceUnderCursor
*   Performs a trace from screen space to world space for this cursor screen location
*/
function Actor TraceUnderCursor(
    float TraceDistance,
    out Vector HitLocation,
    out Vector HitNormal,
    optional bool bTraceActors,
    optional Vector Extent)
{
    local float ScreenWidth, ScreenHeight;
    local Vector WorldRay;
    local Vector ScreenPosition;
    local Actor HitActor;
    
    if(CursorOwner == None)
    {
        return None;
    }
    
    UtilitiesClass.Static.GetScreenResolutionFromPlayerPawnInPixels(CursorOwner, ScreenWidth, ScreenHeight);
    
    // Get screen space -> world space ray
    ScreenPosition.X = CursorX;
    ScreenPosition.Y = CursorY;
    WorldRay = UtilitiesClass.Static.GetWorldRayFromScreen(
        ScreenPosition,
        ScreenWidth, ScreenHeight,
        CursorOwner.FOVAngle,
        CursorOwner.SavedCameraLoc,
        CursorOwner.SavedCameraRot);
    
    // Trace from the screen space -> world space ray
    HitActor = CursorOwner.Trace(
        HitLocation,
        HitNormal,
        WorldRay * TraceDistance,
        CursorOwner.SavedCameraLoc);

    return HitActor;
}

/**
*   DrawGameCursor
*   Draws this game cursor
*   Should be called from the owner's PostRender function
*/
function DrawGameCursor(Canvas C)
{
    if(!bCursorEnabled)
    {
        return;
    }
    
    if(bRecenterMouse)
    {
        CursorX = C.ClipX * 0.5;
        CursorY = C.ClipY * 0.5;
        bRecenterMouse = false;
    }
    
    CursorX = FClamp(CursorX, 0.0, C.ClipX);
    CursorY = FClamp(CursorY, 0.0, C.ClipY);
    
    C.SetPos(CursorX, CursorY);
    C.DrawTile(
        CursorTexture,
        16.0, 16.0,
        0.0, 0.0,
        CursorTexture.USize * 0.5, CursorTexture.VSize * 0.5);
}

defaultproperties
{
    UtilitiesClass=Class'R_AUtilities'
    CursorTexture=Texture'UWindow.Icons.MouseCursor'
    bConsumeMouseInput=True
}