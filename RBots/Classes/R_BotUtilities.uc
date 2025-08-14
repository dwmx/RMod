class R_BotUtilities extends Object;

const LogCategory = 'RBots';

static function RLog(String LogString)
{
	Log("[" $ LogCategory $ "]:" @ LogString, LogCategory);
}