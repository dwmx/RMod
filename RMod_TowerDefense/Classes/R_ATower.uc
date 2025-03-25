//==============================================================================
// R_ATower
// Abstract base class for all towers
//
// Towers are base actors made up of multiple components, R_ATowerComponent
// Components can include things like weapons, auras, currency generators, etc
//
// Child classes should override InitializeTowerComponents and make calls to
// CreateTowerComponent to create each tower component
//
// Components emit events back to the owning Tower through calls to functions
// prefixed with "CE_" short for "Component Event"
//
// All component event functions receive a reference to the calling component
// as their first argument
//==============================================================================
class R_ATower extends R_ABuildableActor abstract;

// Linked list of all components contained by this tower
var R_ATowerComponent RootComponent;

/**
*   CreateTowerComponent
*   All tower components should be instantiated via this function
*   This is a base function and should not be overridden
*/
function R_ATowerComponent CreateTowerComponent(Class<R_ATowerComponent> ComponentClass)
{
    local R_ATowerComponent ComponentInstance;
    
    UtilitiesClass.Static.RModLog("Creating tower component from class" @ ComponentClass);
    
    if(ComponentClass == None)
    {
        UtilitiesClass.Static.RModWarn("Attempted to instantiate invalid tower component");
        return None;
    }
    
    ComponentInstance = new(None) ComponentClass;
    if(ComponentInstance == None)
    {
        UtilitiesClass.Static.RModWarn("Failed to create tower component for class" @ ComponentClass);
        return None;
    }
    
    ComponentInstance.OwningTower = Self;
    
    // Insert the new component instance into the list of components
    if(RootComponent == None)
    {
        RootComponent = ComponentInstance;
    }
    else
    {
        RootComponent.AddComponentToLinkedList(ComponentInstance);
    }
    
    return ComponentInstance;
}

/**
*   InitializeTowerComponents
*   Each tower class should override this function and instantiate its own
*   unique components
*/
function InitializeTowerComponents()
{
    // To be overridden in child classes
    // An example of what this function would look like:
    //
    // CreateTowerComponent(Class'MyDamageAuraClass'); // Adds a damage aura component
    // DamageAuraComponent = CreateTowerComponent(Class'MyDamageAura'); // Adds a damage aura and saves reference
    // MyPrimaryTowerWeapon = CreateTowerComponent(Class'MyLaserWeapon'); // Adds a laser weapon and saves reference
}

/**
*   PreBeginPlay (override)
*   Overridden to instantiate all components before BeginPlay
*/
event PreBeginPlay()
{
    Super.PreBeginPlay();
    InitializeTowerComponents();
}

/**
*   Tick (override)
*   Overridden to tick all tower components via TickComponents function
*   Child classes are expect to override Tick, but they should always call super
*/
event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);
    TickComponents(DeltaSeconds);
}

/**
*   TickComponents
*   Tick all components contained in this tower
*   It is unlikely that you will need to override this function, just override Tick and call super
*/
function TickComponents(float DeltaSeconds)
{
    local R_ATowerComponent ListNode;
    
    ListNode = RootComponent;
    while(ListNode != None)
    {
        ListNode.TickComponent(DeltaSeconds);
        ListNode = ListNode.NextComponent;
    }
}

/**
*   CE_GenericEvent
*   Generic event callback for component instances
*/
function CE_GenericEvent(R_ATowerComponent CallerComponent, Name ComponentEvent, Object OptionalPayload)
{}

/**
*   CE_TargetChanged
*   For components which implement targeting logic (i.e. weapons), they should call this function
*   when their target has changed
*/
function CE_TargetChanged(R_ATowerComponent CallerComponent, Actor NewTarget)
{
    //UtilitiesClass.Static.RModLog("Tower just got a target update!" @ "TOWER" @ "{" $ Self $ "}" @ "TARGET" @ "{" $ NewTarget $ "}");
}