class R_GamePresets extends Info;

struct FGamePreset
{
	var() String Tag;
	var() String Options;
};
const GAME_PRESET_COUNT = 32;
var() config FGamePreset GamePresets[32];

function String FindOptions(String Tag)
{
	local int i;
	
	for(i = 0; i < GAME_PRESET_COUNT; ++i)
	{
		if(GamePresets[i].Tag == ""
		|| Caps(GamePresets[i].Tag) != Caps(Tag))
		{
			continue;
		}
		break;
	}
	
	if(i == GAME_PRESET_COUNT)
	{
		return "";
	}
	
	return GamePresets[i].Options;
}

defaultproperties
{
}
