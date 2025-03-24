//==============================================================================
// R_MobPathNode
// Abstract base class for navigation points used by mobs in tower defense
// game mode
//
// Map editor should places these points and link them together in editor
//==============================================================================
class R_MobPathNode extends NavigationPoint;

// Static utilities
var Class<R_AUtilities> UtilitiesClass;

// User-defined tag given to this node
// This should be unique per node
var(RModTowerDefense) Name ThisNodeTag;

// Should be set to the name of the 'ThisNodeTag' of the next node in this path
var(RModTowerDefense) Name NextNodeTag;

// Cached reference to the node identified by NextNodeTag
var R_MobPathNode NextPathNode;
var R_MobPathNode PrevPathNode;

/**
*   PostBeginPlay (override)
*   Overridden to call ResolvePathReferences
*/
event PostBeginPlay()
{
    Super.PostBeginPlay();
    ResolvePathReferences();
}

/**
*   ResolvePathReferences
*   Find the node identified by NextNodeTag and update cached references
*   If no node can be found, log a warning
*/
function ResolvePathReferences()
{
    local R_MobPathNode MobPathNode;
    
    if(NextNodeTag == '')
    {
        return;
    }
    
    foreach AllActors(Class'R_MobPathNode', MobPathNode)
    {
        if(MobPathNode.ThisNodeTag == NextNodeTag)
        {
            if(MobPathNode.PrevPathNode != None)
            {
                UtilitiesClass.Static.RModWarn(
                    "R_MobPathNode overwriting previous path node -- path node linked list is configured incorrectly and may not work as expected"
                    @ "ThisNodeTag =" @ ThisNodeTag @ "NextNodeTag =" @ NextNodeTag);
            }
            
            NextPathNode = MobPathNode;
            MobPathNode.PrevPathNode = Self;
            return;
        }
    }
    
    UtilitiesClass.Static.RModWarn(
        "R_MobPathNode failed to resolve path references"
        @ "ThisNodeTag =" @ ThisNodeTag @ "NextNodeTag =" @ NextNodeTag);
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
}