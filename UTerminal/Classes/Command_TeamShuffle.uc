//=============================================================================
// UTerminal.Command_TeamShuffle
// In team games, shuffle players around to new teams
//=============================================================================
class Command_TeamShuffle extends UTerminal.Command;

var int MaxTeams;
var String Colors;

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
    return "Shuffle and balance teams";
}

function ExposeParameters()
{
    ExposeIntParameter("MaxTeams");
    ExposeStringParameter("Colors");
}

function Execute()
{
    local PlayerPawn P;
    local PlayerPawn PArray[64];
    local int PCount;
    local int Random;
    local int i;

    // Get player array
    PCount = 0;
    foreach TerminalInstance.AllActors(class'Engine.PlayerPawn', P)
    {
        if(P.PlayerReplicationInfo == None
        || P.PlayerReplicationInfo.bIsSpectator
        || P.GetStateName() == 'PlayerSpectating'
        || !P.bIsPlayer)
        {
            continue;
        }

        PArray[PCount] = P;
        ++PCount;
        if(PCount >= 64)
        {
            break;
        }
    }

    // Randomize array
    for(i = 0; i < PCount; ++i)
    {
        Random = Rand(PCount - i);
        P = PArray[i];
        PArray[i] = PArray[i + Random];
        PArray[i + Random] = P;
    }

    // Determine if balancing will be done by color or max teams
    if(Colors != "")
    {
        ShuffleByColorsParameter(PArray, PCount);
    }
    else
    {
        ShuffleByMaxTeamsParameter(PArray, PCount);
        //MaxTeams = Clamp(MaxTeams, 2, 4);
    }
}

// Convert color string to a team index
// Returns -1 if bad color string
function int GetTeamIndexFromColorString(String ColorString)
{
    ColorString = Caps(ColorString);
    if(ColorString == "RED")
    {
        return 0;
    }
    if(ColorString == "BLUE")
    {
        return 1;
    }
    if(ColorString == "GREEN")
    {
        return 2;
    }
    if(ColorString == "GOLD")
    {
        return 3;
    }
    return -1;
}

function ShuffleByColorsParameter(out PlayerPawn PArray[64], int PCount)
{
    local String Args;
    local String Token;
    local int TeamIndices[4];
    local int TeamCount;
    local int i;

    // Build team index array
    TeamCount = 0;
    Args = Colors;
    while(Args != "")
    {
        Token = Utilities.Static.GetTokenUsingDelimiter(Args, ",");
        TeamIndices[TeamCount] = GetTeamIndexFromColorString(Token);
        if(TeamIndices[TeamCount] == -1)
        {
            Warn("bad color argument:" @ Token);
            return;
        }
        ++TeamCount;
        if(TeamCount >= 4)
        {
            break;
        }
    }

    // Distribute to teams
    for(i = 0; i < PCount; ++i)
    {
        TerminalInstance.Level.Game.ChangeTeam(
            PArray[i],
            TeamIndices[i % TeamCount]);
    }
}

function ShuffleByMaxTeamsParameter(out PlayerPawn PArray[64], int PCount)
{
    local int i;

    MaxTeams = Clamp(MaxTeams, 2, 4);

    // Distribute to teams
    for(i = 0; i < PCount; ++i)
    {
        TerminalInstance.Level.Game.ChangeTeam(
            PArray[i],
            ((i % MaxTeams) + 2) % 4); // Use gold and green for first teams
    }
}

defaultproperties
{
    MaxTeams=2
    Colors=""
    ExecString="Shuffle"
}