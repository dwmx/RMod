//==============================================================================
// R_ActorSelector
// Handles functionality related to actor selection for an R_RunePlayer
//==============================================================================
class R_ActorSelector extends Object;

// Libraries
const MathLibrary = Class'RBase.R_AMathLibrary';
const CanvasLibrary = Class'RBase.R_ACanvasLibrary';
const TowerDefenseLibrary = Class'RMod_TowerDefense.R_ATowerDefenseLibrary';

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
        Warn(Class @ "failed to initialize, NewOwningPlayer == None");
    }
    OwningPlayer = NewOwningPlayer;
    Log(Class @ "initialized with OwningPlayer ==" @ OwningPlayer, TowerDefenseLibrary.Static.LogCategory());
}

/**
*   NotifyReleasedByOwningPlayer
*   Called when the owning player is releasing its reference to this object,
*   will be garbage collected shortly after
*/
function NotifyReleasedByOwningPlayer()
{
    if(OwningPlayer == None)
    {
        Warn(Class @ "received NotifyReleasedByOwningPlayer call when OwningPlayer ==" @ None);
        return;
    }
    
    OwningPlayer = None;
    
    Log(Class @ "released by owning player", TowerDefenseLibrary.Static.LogCategory());
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
        
        foreach OwningPlayer.AllActors(Class'R_Mob', MobIterator)
        {
            DrawScreenSpaceBoundingBoxForActor(C, MobIterator);
        }
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
    
    CanvasLibrary.Static.GetScreenSpaceBoundingBoxForActor(
        C, InActor, OwningPlayer.SavedCameraRot,
        Extent1, Extent2);
    
    DrawAllSelectedActors(C);
}

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
        
        //Class'R_ACanvasLibrary'.Static.DrawBoxOutline(
        //    C, SelectionExtent1, SelectionExtent2, 4.0,
        //    1.0, 0.0, 0.0, 1.0);
        
        WorldUp.Z = 1.0;
        
        i = 0;
        foreach OwningPlayer.AllActors(Class'R_Mob', MobIterator)
        {
            CanvasLibrary.Static.GetScreenSpaceBoundingBoxForActor(
                C, MobIterator, OwningPlayer.SavedCameraRot,
                ActorExtent1, ActorExtent2);
            
            //Class'R_ACanvasLibrary'.Static.DrawBoxOutline(
            //    C, ActorExtent1, ActorExtent2, 4.0,
            //    1.0, 0.0, 0.0, 1.0);
            
            //if(CheckBoundingBoxCollision(SelectionExtent1, SelectionExtent2, ActorExtent1, ActorExtent2))
             if(MathLibrary.Static.CheckBoundingBoxCollisionMidPointBased(
                SelectionExtent1, SelectionExtent2,
                ActorExtent1, ActorExtent2))
            {
                CanvasLibrary.Static.DrawCircle3D(
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