//=============================================================================
// UTerminal.ConsoleInterfaceDaemon
// Spawned by Terminal when bEnableConsoleInterface is set to true
// Background Actor which is responsible for attaching the console interface
// to all PlayerPawns that have administration access
//=============================================================================
class ConsoleInterfaceDaemon extends Engine.Actor;

var class<ConsoleInterface> ConsoleInterfaceClass;

event PostBeginPlay()
{
    Log(Self @ "spawned, listening for in-game admins");
}

// Each Tick, verify all admin pawns have a console interface and
// non-admin pawns have no interface
event Tick(float DeltaSeconds)
{
    local PlayerPawn P;

    foreach AllActors(class'Engine.PlayerPawn', P)
    {
        // Skip non-players
        if(!P.bIsPlayer)
        {
            continue;
        }

        // Make sure admins have an interface and non-admins don't
        if(P.bAdmin)
        {
            EnsurePlayerPawnHasInterface(P);
        }
        else
        {
            EnsurePlayerPawnHasNoInterface(P);
        }
    }
}

// If P doesn't have an interface, give them one
function EnsurePlayerPawnHasInterface(PlayerPawn P)
{
    local ConsoleInterface Interface;

    Interface = GetPlayerPawnsConsoleInterface(P);
    if(Interface != None)
    {
        return;
    }
    
    Interface = Spawn(ConsoleInterfaceClass, P);
    Interface.TerminalInterface = Terminal(Owner);
    P.AddInventory(Interface);
    Log(Self @ "attached console interface to" @ P);
}

// If P has an interface, get rid of it
function EnsurePlayerPawnHasNoInterface(PlayerPawn P)
{
    local ConsoleInterface Interface;

    Interface = GetPlayerPawnsConsoleInterface(P);
    if(Interface == None)
    {
        return;
    }
    
    P.DeleteInventory(Interface);
    Interface.TerminalInterface = None;
    Interface.Destroy();
    Log(Self @ "removed console interface from" @ P);
}

// Get the interface belonging to P if there is one, None otherwise
function ConsoleInterface GetPlayerPawnsConsoleInterface(PlayerPawn P)
{
    local Inventory Inv;

    for(Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        if(ConsoleInterface(Inv) != None)
        {
            return ConsoleInterface(Inv);
        }
    }

    return None;
}

defaultproperties
{
    RemoteRole=ROLE_None
    ConsoleInterfaceClass=class'UTerminal.ConsoleInterface'
}