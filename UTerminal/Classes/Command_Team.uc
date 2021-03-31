//=============================================================================
// UTerminal.Command_Team
// Modify or set up teams
//=============================================================================
class Command_Team extends UTerminal.Command;

var String Color;
var String Name;

static function bool ShouldEnableCommand(LevelInfo LevelContext)
{
    if(LevelContext == None || LevelContext.Game == None)
    {
        return false;
    }

    return LevelContext.Game.bTeamGame;
}

static function String HelpString_Basic()
{
    return "Modify teams";
}

function ExposeParameters()
{
    ExposeStringParameter("Color");
    ExposeStringParameter("Name");
}

function Execute()
{
    local TeamInfo TRI;

    if(!CheckParameterPassedIn("Color"))
    {
        ErrorString = "Please provide color argument";
        return;
    }

    TRI = GetTeamInfoFromColor(Color);

    if(CheckParameterPassedIn("Name"))
    {
        TRI.TeamName = Name;
    }
}

function TeamInfo GetTeamInfoFromColor(String Color)
{
    local int TeamIndex;
    local TeamInfo TRI;

    switch(Caps(Color))
    {
    case "RED":
        TeamIndex = 0;
        break;
    case "BLUE":
        TeamIndex = 1;
        break;
    case "GREEN":
        TeamIndex = 2;
        break;
    case "GOLD":
        TeamIndex = 3;
        break;
    default:
        TeamIndex = -1;
    }

    if(TeamIndex == -1)
    {
        return None;
    }

    foreach TerminalInstance.AllActors(class'RuneI.TeamInfo', TRI)
    {
        if(TRI.TeamIndex == TeamIndex)
        {
            return TRI;
        }
    }

    return None;
}

defaultproperties
{
    ExecString="Team"
}