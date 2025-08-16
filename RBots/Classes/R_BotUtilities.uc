class R_BotUtilities extends Object;

const LogCategory = 'RBots';

static function RLog(String LogString)
{
	Log("[" $ LogCategory $ "]:" @ LogString, LogCategory);
}

static function ColorToFloats(Color InColor, out float R, out float G, out float B)
{
	R = float(InColor.R) / 255.0;
	G = float(InColor.G) / 255.0;
	B = float(InColor.B) / 255.0;
}