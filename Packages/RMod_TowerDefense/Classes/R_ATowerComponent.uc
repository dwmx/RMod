//==============================================================================
// R_ATowerComponent
// Abstract base class for all tower components
// Towers are considered base container classes for various components
// Examples of components are weapons and auras
//
// Note that these are intended to be server-side only classes, since regular
// Objects do not have replication functionality
//==============================================================================
class R_ATowerComponent extends Object abstract;

// Static utilities
var Class<R_AUtilities> UtilitiesClass;

var R_ATowerComponent NextComponent;
var R_ATower OwningTower;

/**
*   AddComponentToLinkedList
*   Attaches the given component instance to the tail of the linked list that
*   this component is a part of
*/
function AddComponentToLinkedList(R_ATowerComponent ComponentInstance)
{
    local R_ATowerComponent ListNode;
    
    ListNode = Self;
    while(ListNode.NextComponent != None)
    {
        ListNode = ListNode.NextComponent;
    }
    ListNode.NextComponent = ComponentInstance;
}

/**
*   TickComponent
*   Called from owning tower's Tick function
*/
function TickComponent(float DeltaSeconds)
{}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
}