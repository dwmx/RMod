//=============================================================================
// UTerminal.Command_Player
// The base class for all commands that deal with player arguments
//=============================================================================
class Command_Player extends UTerminal.Command abstract;

var String Name;
var int ID;

var PlayerPawn ReferencedPlayerPawn;

function ExposeParameters()
{
    ExposeStringParameter("Name");
    ExposeIntParameter("ID");
}

// Verify that caller has provided args for only one player
// Cache reference to the playerpawn if found
function Execute()
{
    local int PlayerArgumentCount;

    PlayerArgumentCount = 0;
    if(Name != Class.Default.Name)
    {
        ++PlayerArgumentCount;
    }
    if(ID != Class.Default.ID)
    {
        ++PlayerArgumentCount;
    }
    
    ErrorString = "";

    // Validate argument count
    if(PlayerArgumentCount == 0)
    {
        ErrorString = "Please provide player argument";
        return;
    }
    if(PlayerArgumentCount > 1)
    {
        ErrorString = "Please provide only one player argument";
        return;
    }

    // Get player pawn reference
    ReferencedPlayerPawn = GetReferencedPlayerPawn();
    if(ReferencedPlayerPawn == None)
    {
        ErrorString = "No matching player found";
        return;
    }
    
    // Fill out vars
    if(ReferencedPlayerPawn.PlayerReplicationInfo != None)
    {
        Name = ReferencedPlayerPawn.PlayerReplicationInfo.PlayerName;
        ID = ReferencedPlayerPawn.PlayerReplicationInfo.PlayerID;
    }
}

// Return the PlayerPawn referenced by the caller args
function PlayerPawn GetReferencedPlayerPawn()
{
    if(Name != Class.Default.Name)
    {
        return GetPlayerPawnByName(Name);
    }
    if(ID != Class.Default.ID)
    {
        return GetPlayerPawnByID(ID);
    }
    return None;
}

function PlayerPawn GetPlayerPawnByName(String PlayerName)
{
    local PlayerPawn P;

    foreach TerminalInstance.AllActors(class'Engine.PlayerPawn', P)
    {
        if(!P.bIsPlayer
        || P.PlayerReplicationInfo == None
        || Caps(P.PlayerReplicationInfo.PlayerName) != Caps(PlayerName))
        {
            continue;
        }
        return P;
    }
    return None;
}

function PlayerPawn GetPlayerPawnByID(int PlayerID)
{
    local PlayerPawn P;

    foreach TerminalInstance.AllActors(class'Engine.PlayerPawn', P)
    {
        if(!P.bIsPlayer
        || P.PlayerReplicationInfo == None
        || P.PlayerReplicationInfo.PlayerID != PlayerID)
        {
            continue;
        }
        return P;
    }
    return None;
}

defaultproperties
{
    Name=""
    ID=-1
}