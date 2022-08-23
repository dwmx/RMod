class RuneGameReplicationInfo extends GameReplicationInfo;

var TeamInfo Teams[4];

var int GoalTeamScore;
var int FragLimit;
var int TimeLimit;


replication
{
	reliable if ( Role == ROLE_Authority )
		FragLimit, TimeLimit, Teams, GoalTeamScore;
}


simulated function Timer()
{
	Super.Timer();

	if ( RuneMultiPlayer(Level.Game) != None )
	{
		FragLimit = RuneMultiPlayer(Level.Game).FragLimit;
		TimeLimit = RuneMultiPlayer(Level.Game).TimeLimit;
	}
}

defaultproperties
{
     bStopCountDown=False
}
