//==============================================================================
// R_ActorSelector
// Handles functionality related to actor selection for an R_RunePlayer
//==============================================================================
class R_ActorSelector extends Object;

var Class<R_AUtilities> UtilitiesClass;

var R_RunePlayer OwningPlayer;
var Actor SelectedActor;

/**
*   InitializeActorSelector
*   To be called by the owning player when created
*/
function InitializeActorSelector(R_RunePlayer NewOwningPlayer)
{
    if(NewOwningPlayer == None)
    {
        UtilitiesClass.Static.RModWarn(
            "R_ActorSelector failed to initialize, OwningPlayer is None");
    }
    OwningPlayer = NewOwningPlayer;
    UtilitiesClass.Static.RModLog(
        "R_ActorSelector initialized with owner" @ OwningPlayer);
}

/**
*   NotifyReleasedByOwningPlayer
*   Called when the owning player is releasing its reference to this object,
*   will be garbage collected shortly after
*/
function NotifyReleasedByOwningPlayer()
{
    if(OwningPlayer != None)
    {
        UtilitiesClass.Static.RModWarn(
            "R_ActorSelector received NotifyReleasedByOwningPlayer call when OwningPlayer was None"
            @ "This indicates improper initialization or multiple calls to release");
        return;
    }
    
    OwningPlayer = None;
    
    UtilitiesClass.Static.Log("R_ActorSelector released by owning player");
}

/**
*   ActorSelectorPostRender
*   Called from owning player's PostRender function
*   This is the only function where Canvas instance is valid,
*   so it needs to perform both canvas logic and canvas drawing
*/
function ActorSelectorPostRender(Canvas C)
{
    local R_Mob MobIterator;
    
    if(OwningPlayer != None)
    {
        DrawScreenSpaceBoundingBoxForActor(C, OwningPlayer);
    }
    
    foreach OwningPlayer.AllActors(Class'R_Mob', MobIterator)
    {
        DrawScreenSpaceBoundingBoxForActor(C, MobIterator);
    }
}

/**
*   DrawScreenSpaceBoundingBoxForActor
*   Debug function which draws a screen-space AABB for a given actor
*   This bounding box is used for screen space collision checks to
*   select actors in the world
*/
function DrawScreenSpaceBoundingBoxForActor(Canvas C, Actor InActor)
{
    local Vector Extent1, Extent2;
    
    class'R_ACanvasUtilities'.Static.GetScreenSpaceBoundingBoxForActor(
        C, InActor, OwningPlayer.SavedCameraRot,
        Extent1, Extent2);
    
    //Class'R_ACanvasUtilities'.Static.DrawBoxOutline(
    //    C, Extent1, Extent2, 4.0,
    //    1.0, 0.0, 0.0, 1.0);
    
    DrawAllSelectedActors(C);
}

// NOTE:
// This is slow as fuck
// Do your best to minimize the number of actor checks as much as possible,
// and definitely do not call this every frame
function DrawAllSelectedActors(Canvas C)
{
    local Vector SelectionExtent1, SelectionExtent2;
    local Vector ActorExtent1, ActorExtent2;
    local R_Mob MobIterator;
    local Vector WorldUp;
    local int i;
    
    if(OwningPlayer != None)
    {
        if(OwningPlayer.GameCursor != None)
        {
            if(OwningPlayer.GameCursor.IsEnabled() && OwningPlayer.GameCursor.IsDragSelecting())
            {
                OwningPlayer.GameCursor.GetDragSelectionExtents(SelectionExtent1, SelectionExtent2);
            }
        }
    
        if(SelectionExtent1 == SelectionExtent2)
        {
            return;
        }
        
        //Class'R_ACanvasUtilities'.Static.DrawBoxOutline(
        //    C, SelectionExtent1, SelectionExtent2, 4.0,
        //    1.0, 0.0, 0.0, 1.0);
        
        WorldUp.Z = 1.0;
        
        i = 0;
        foreach OwningPlayer.AllActors(Class'R_Mob', MobIterator)
        {
            Class'R_ACanvasUtilities'.Static.GetScreenSpaceBoundingBoxForActor(
                C, MobIterator, OwningPlayer.SavedCameraRot,
                ActorExtent1, ActorExtent2);
            
            //Class'R_ACanvasUtilities'.Static.DrawBoxOutline(
            //    C, ActorExtent1, ActorExtent2, 4.0,
            //    1.0, 0.0, 0.0, 1.0);
            
            if(CheckBoundingBoxCollision(SelectionExtent1, SelectionExtent2, ActorExtent1, ActorExtent2))
            {
                Class'R_ACanvasUtilities'.Static.DrawCircle3D(
                    C,
                    MobIterator.Location, WorldUp,
                    32.0, 32,
                    0.0, 1.0, 0.0);
                    
                ++i;
            }
        }
        
        //Log(i @ "actors in selection");
    }
}

// Returns true if one box is at least half way inside the other
function bool CheckBoundingBoxCollision(
    Vector ExtentA1, Vector ExtentA2,
    Vector ExtentB1, Vector ExtentB2)
{
    local Vector MinA, MaxA, MidA;
    local Vector MinB, MaxB, MidB;
    
    MinA.X = FMin(ExtentA1.X, ExtentA2.X);
    MinA.Y = FMin(ExtentA1.Y, ExtentA2.Y);
    MaxA.X = FMax(ExtentA1.X, ExtentA2.X);
    MaxA.Y = FMax(ExtentA1.Y, ExtentA2.Y);
    MidA.X = (MinA.X + MaxA.X) / 2.0;
    MidA.Y = (MinA.Y + MaxA.Y) / 2.0;
    
    MinB.X = FMin(ExtentB1.X, ExtentB2.X);
    MinB.Y = FMin(ExtentB1.Y, ExtentB2.Y);
    MaxB.X = FMax(ExtentB1.X, ExtentB2.X);
    MaxB.Y = FMax(ExtentB1.Y, ExtentB2.Y);
    MidB.X = (MinB.X + MaxB.X) / 2.0;
    MidB.Y = (MinB.Y + MaxB.Y) / 2.0;
    
    if(MidA.X >= MinB.X && MidA.X <= MaxB.X)
    {
        if(MidA.Y >= MinB.Y && MidA.Y <= MaxB.Y)
        {
            return true;
        }
    }
    
    if(MidB.X >= MinA.X && MidB.X <= MaxA.X)
    {
        if(MidB.Y >= MinA.Y && MidB.Y <= MaxA.Y)
        {
            return true;
        }
    }
    
    return false;
}

//function bool CheckBoundingBoxCollision(
//    Vector ExtentA1, Vector ExtentA2,
//    Vector ExtentB1, Vector ExtentB2)
//{
//    local float widthA, heightA, widthB, heightB;
//    local float overlapX, overlapY;
//    
//    // Calculate the width and height of both boxes
//    widthA = ExtentA2.X - ExtentA1.X;
//    heightA = ExtentA2.Y - ExtentA1.Y;
//    widthB = ExtentB2.X - ExtentB1.X;
//    heightB = ExtentB2.Y - ExtentB1.Y;
//
//    // Check for overlap along the X axis
//    overlapX = FMin(ExtentA2.X, ExtentB2.X) - FMax(ExtentA1.X, ExtentB1.X);
//    if (overlapX >= widthA / 2 || overlapX >= widthB / 2)
//    {
//        // Check for overlap along the Y axis
//        overlapY = FMin(ExtentA2.Y, ExtentB2.Y) - FMax(ExtentA1.Y, ExtentB1.Y);
//        if (overlapY >= heightA / 2 || overlapY >= heightB / 2)
//        {
//            return true; // At least halfway inside the other box
//        }
//    }
//
//    return false; // No collision or not halfway inside
//}



defaultproperties
{
    UtilitiesClass=Class'R_AUtilities'
}