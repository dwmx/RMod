//=============================================================================
// UTerminal.Command_Switch
// Primary command for changing map, game type, etc
//=============================================================================
class Command_Switch extends UTerminal.Command;

var String Level;
var String Game;

static function String HelpString_Basic()
{
    return "Switch the current level or game mode";
}

function ExposeParameters()
{
    ExposeStringParameter("Level");
    ExposeStringParameter("Game");
}

function Execute()
{
    local String TravelURL;

    // Do nothing if no arguments
    if(Level == Class.Default.Level && Game == Class.Default.Game)
    {
        ErrorString = "No level or game specified.";
        return;
    }

    // Verify the level argument is installed
    if(Level == Class.Default.Level)
    {
        Level = TerminalInstance.Level.GetURLMap();
    }
    else
    {
        if(!CheckMapExists(Level))
        {
            ErrorString = Level @ "is not installed on this server";
            return;
        }
    }

    TravelURL = Level;
    if(Game != Class.Default.Game)
    {
        TravelURL = TravelURL $ "?game=" $ Game;
    }
    
    TerminalInstance.Level.ServerTravel(TravelURL, false);
}

// Check whether or not a map is installed on this server
function bool CheckMapExists(String MapString)
{
    if(MapString == ""
    || LevelInfo(DynamicLoadObject(
        MapString$".LevelInfo0", class'LevelInfo')) == None)
    {
        return false;
    }
    return true;
}

defaultproperties
{
    ExecString="Switch"
    Level=""
    Game=""
}