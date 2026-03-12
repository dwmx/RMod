//==============================================================================
//	R_ArpgGameLibrary
//==============================================================================
class R_ArpgGameLibrary extends R_ArpgObject abstract;

const TEAM_INDEX_NONE = 255;
const TEAM_INDEX_HUMAN = 0;
const TEAM_INDEX_MONSTER = 1;

static function byte GetTeamIndex(Name TeamName)
{
	switch(TeamName)
	{
	case 'Human':	return TEAM_INDEX_HUMAN;
	case 'Monster':	return TEAM_INDEX_MONSTER;
	}

	return TEAM_INDEX_NONE;
}