//==============================================================================
// R_GameCursor
// A cursor meant specifically for use in-game, and not in Rune UI
// Owning R_RunePlayer must spawn this locally and pass mouse movement to it
//==============================================================================
class R_GameCursor extends Object;

// Static utilities
var Class<R_AUtilities> UtilitiesClass;

var R_RunePlayer CursorOwner;

var private float CursorX, CursorY;
var Texture CursorTexture;

var private bool bRecenterGameCursor;
var private bool bCursorEnabled;
var private bool bConsumeMouseInput;

var private bool bIsDragSelecting;
var private Vector DragSelectionStart;
var private Vector DragSelectionEnd;

/**
*   PlayerInputMouseMove
*   Input X and Y mouse movement
*   To be called by owner's PlayerInput function
*/
function PlayerInputMouseMove(float MoveX, float MoveY, float DeltaSeconds)
{
    CursorX += MoveX * DeltaSeconds;
    CursorY += MoveY * DeltaSeconds * -1.0;
    
    if(bIsDragSelecting)
    {
        DragSelectionEnd.X = CursorX;
        DragSelectionEnd.Y = CursorY;
    }
}

/**
*   NotifyEnabled
*   Called by owner when this cursor has been enabled
*/
function NotifyEnabled(R_RunePlayer Caller)
{
    CursorOwner = Caller;
    bCursorEnabled = true;
}

/**
*   NotifyDisabled
*   Called by owner when disabling the game cursor
*   Note that this does not delete the cursor, only hides it and stops
*   passing input to it
*/
function NotifyDisabled()
{
    bCursorEnabled = false;
}

/**
*   IsEnabled
*   Called by owner
*/
function bool IsEnabled()
{
    return bCursorEnabled;
}

/**
*   IsConsumingMouseInputWhenEnabled
*   Called by owner
*   Modify bConsumeMouseInput bool instead of overriding this function
*/
function bool IsConsumingMouseInputWhenEnabled()
{
    return bConsumeMouseInput;
}

/**
*   RecenterGameCursor
*   Calling this will recenter the cursor
*   Canvas is required for re-centering, so the actual recentering occurs in Draw
*/
function RecenterGameCursor()
{
    bRecenterGameCursor = true;
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
        CursorOwner.SavedCameraLoc,
        /*bTraceActors*/,
        Extent);
        
    // If looking for actors, trace again from camera loc to last hit point
    // Note: For some reason the first trace always collides with LevelInfo, even
    // if it passes through an Actor
    // So this is more of a hack to perform the trace without hitting environment
    if(bTraceActors && HitActor != None && LevelInfo(HitActor) != None)
    {
        return CursorOwner.Trace(
            HitLocation,
            HitNormal,
            HitLocation,
            CursorOwner.SavedCameraLoc,
            true,
            Extent);
    }

    return HitActor;
}

function BeginDragSelection()
{
    bIsDragSelecting = true;
    DragSelectionStart.X = CursorX;
    DragSelectionStart.Y = CursorY;
}

function EndDragSelection()
{
    bIsDragSelecting = false;
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
    
    
    
    // Recenter here because Canvas is needed
    if(bRecenterGameCursor)
    {
        CursorX = C.ClipX * 0.5;
        CursorY = C.ClipY * 0.5;
        bRecenterGameCursor = false;
    }
    
    // Don't let cursor leave viewport extents
    CursorX = FClamp(CursorX, 0.0, C.ClipX);
    CursorY = FClamp(CursorY, 0.0, C.ClipY);
    
    // If drag selecting, draw selection box
    if(bIsDragSelecting)
    {
        Class'R_ACanvasUtilities'.Static.DrawBoxOutline(
            C, DragSelectionStart, DragSelectionEnd, 2.0, 1.0, 1.0, 1.0, 0.5);
    }
    
    // Draw cursor
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
    bRecenterGameCursor=True
    bIsDragSelecting=False
}