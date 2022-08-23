//=============================================================================
// RuneSinglePlayer.
//=============================================================================
class RuneSinglePlayer extends RuneGameInfo;


event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	if ( DefaultPlayerClass != None )
	{	// Force playerclass for this gametype
		SpawnClass=DefaultPlayerClass;
	}

	return Super.Login(Portal, Options, Error, SpawnClass);
}

defaultproperties
{
     DefaultPlayerClass=Class'RuneI.Ragnar'
     BotMenuType="None"
     RulesMenuType="None"
     SettingsMenuType="None"
     MutatorMenuType="None"
     MaplistMenuType="None"
     GameName="Single Player"
}
