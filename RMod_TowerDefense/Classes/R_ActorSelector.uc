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

defaultproperties
{
    UtilitiesClass=Class'R_AUtilities'
}