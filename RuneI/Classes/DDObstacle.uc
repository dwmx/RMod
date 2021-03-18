//=============================================================================
// DDObstacle.
//=============================================================================
class DDObstacle extends RunePolyobj;

/*
	Description:
		Obstacle in Dark Dwarf area for temporary cover, but destructible by DD.
*/

defaultproperties
{
     DamageThreshold=15.000000
     DebrisType=Class'RuneI.DebrisStone'
     InitialState=Destructible
}
