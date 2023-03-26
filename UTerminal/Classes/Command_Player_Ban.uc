//=============================================================================
// UTerminal.Command_Player_Ban
// Command for banning a player from the server
//=============================================================================
class Command_Player_Ban extends UTerminal.Command_Player;

static function String HelpString_Basic()
{
    return "Ban a player from this server";
}

function Execute()
{
    Super.Execute();
    if(ErrorString != "")
    {
        return;
    }

    ResponseString = "You want to ban" @ Name;
}

defaultproperties
{
    ExecString="Ban"
}