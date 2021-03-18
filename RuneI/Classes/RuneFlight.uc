//=============================================================================
// RuneFlight.
//=============================================================================
class RuneFlight expands RuneGameInfo;

var PlayerPawn NewPlayer;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	NewPlayer = Super.Login(Portal, Options, Error, class'RagnarFlight');
		
	return(NewPlayer);
}

defaultproperties
{
     DefaultPlayerClass=Class'RuneI.RagnarFlight'
}
