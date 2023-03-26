//=============================================================================
// UTerminal.Command_Player_Kick
// Command for kicking a player from the server
//=============================================================================
class Command_Player_Kick extends UTerminal.Command_Player;

static function String HelpString_Basic()
{
    return "Kick a player from the game";
}

function Execute()
{
    Super.Execute();
    if(ErrorString != "")
    {
        return;
    }

    if(ReferencedPlayerPawn == None)
    {
        return;
    }

    ReferencedPlayerPawn.Destroy();
    ResponseString = "Kicked player:" @ Name;
}

defaultproperties
{
    ExecString="Kick"
}