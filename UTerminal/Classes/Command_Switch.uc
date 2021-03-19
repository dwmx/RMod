//=============================================================================
// UTerminal.Command_Switch
// Primary command for changing map, game type, etc
//=============================================================================
class Command_Switch extends UTerminal.Command;

var String Level;
var String Game;
var String Password;

static function String HelpString_Basic()
{
    return "Switch the current level or game mode";
}

function ExposeParameters()
{
    ExposeStringParameter("Level");
    ExposeStringParameter("Game");
    ExposeStringParameter("Password");
}

function Execute()
{
    local String TravelURL;

    // Handle password parameter
    if(CheckParameterPassedIn("Password"))
    {
        HandlePasswordParameter();
    }

    // Handle level or argument args
    if(CheckParameterPassedIn("Level") || CheckParameterPassedIn("Game"))
    {
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
}

function HandlePasswordParameter()
{
    local String ConsoleCommand;
    local String GamePasswordResult;

    ConsoleCommand = "Set Engine.GameInfo GamePassword" @ Password;
    TerminalInstance.Level.Game.ConsoleCommand(ConsoleCommand);

    ConsoleCommand = "Get Engine.GameInfo GamePassword";
    GamePasswordResult = TerminalInstance.Level.Game.ConsoleCommand(ConsoleCommand);
    TerminalInstance.BroadcastMessage("Game has been passworded:" @ GamePasswordResult);
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
    Password=""
}