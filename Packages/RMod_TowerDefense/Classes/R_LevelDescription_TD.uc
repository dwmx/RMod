//==============================================================================
// R_LevelDescription_TD
//
// Level description info class for RMod Tower Defense game mode
//
// Every Tower Defense level should have one, and only one of these actors
// placed in it
//
// The game mode looks for this actor at game initialization and reads all
// important configuration information from it
//==============================================================================
class R_LevelDescription_TD extends Info;

// Should be set to the 'ThisNodeTag' of the very first R_MobPathNode in the
// level's main mob path
var(RModTowerDefense) Name InitialPathNodeTag;