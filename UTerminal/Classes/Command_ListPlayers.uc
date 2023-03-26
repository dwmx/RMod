//=============================================================================
// UTerminal.Command_ListPlayers
// Generate a list of all players in the game
//=============================================================================
class Command_ListPlayers extends UTerminal.Command;

var bool bVerbose; // Build a more comprehensive list of information

var ListNode PlayerList;
var ListNode SpectatorList;

static function String HelpString_Basic()
{
    return "Print a detailed listing of all players in the game";
}

function ExposeParameters()
{
    ExposeBoolParameter("bVerbose");
}

// Collect all players and spectators in-game
function BuildPlayerAndSpectatorLists()
{
    local PlayerPawn P;
    local ListNode TempNode;

    PlayerList = None;
    SpectatorList = None;
    foreach TerminalInstance.AllActors(class'Engine.PlayerPawn', P)
    {
        if(!P.bIsPlayer)
        {
            continue;
        }
        TempNode = new(None) class'UTerminal.ListNode';
        TempNode.Actor = P;

        if(P.PlayerReplicationInfo != None
        && P.PlayerReplicationInfo.bIsSpectator)
        {
            if(SpectatorList == None)
            {
                SpectatorList = TempNode;
            }
            else
            {
                SpectatorList.AddElement(TempNode);
            }
        }
        else
        {
            if(PlayerList == None)
            {
                PlayerList = TempNode;
            }
            else
            {
                PlayerList.AddElement(TempNode);
            }
        }
    }
}

function String GetPlayerString(PlayerPawn P)
{
    local String Result;

    Result = "[ID]:" @ P.PlayerReplicationInfo.PlayerID;
    Result = Result @ "[Name]:" @ P.PlayerReplicationInfo.PlayerName;

    return Result;
}

function String GetSpectatorString(PlayerPawn P)
{
    local String Result;

    Result = "[ID]:" @ P.PlayerReplicationInfo.PlayerID;
    Result = Result @ "[Name]:" @ P.PlayerReplicationInfo.PlayerName;

    return Result;
}

function Execute()
{
    local int PlayerCount;
    local String PlayerString;
    local int SpectatorCount;
    local String SpectatorString;
    local ListNode IteratorNode;
    local String CRLF;

    BuildPlayerAndSpectatorLists();
    CRLF = Utilities.Static.CRLF();

    // Count players and build player string
    PlayerCount = 0;
    PlayerString = "";
    for(IteratorNode = PlayerList;
        IteratorNode != None;
        IteratorNode = IteratorNode.Next)
    {
        PlayerString = PlayerString $
            GetPlayerString(PlayerPawn(IteratorNode.Actor)) $ CRLF;
        ++PlayerCount;
    }
    
    // Count spectators and build spectator string
    SpectatorCount = 0;
    SpectatorString = "";
    for(IteratorNode = SpectatorList;
        IteratorNode != None;
        IteratorNode = IteratorNode.Next)
    {
        SpectatorString = SpectatorString $
            GetSpectatorString(PlayerPawn(IteratorNode.Actor)) $ CRLF;
        ++SpectatorCount;
    }

    // Build response string
    ResponseString = "";
    if(PlayerCount == 0)
    {
        ResponseString = ResponseString $ "[No players]";
    }
    else
    {
        ResponseString = ResponseString $
            "[" $ PlayerCount @ "Players]" $ CRLF $ PlayerString;
    }
    
    if(SpectatorCount == 0)
    {
        ResponseString = ResponseString $ CRLF $ CRLF $ "[No Spectators]";
    }
    else
    {
        ResponseString = ResponseString $ CRLF $ CRLF $
            "[" $ SpectatorCount @ "Spectators]" $ CRLF $ SpectatorString;
    }
}

defaultproperties
{
    ExecString="ListPlayers"
    bVerbose=false;
}