//=============================================================================
// SparkSystemVertical.
//=============================================================================

//USAGE: SparkSystemVertical
//Simply place in desired location (non-directional system -- automatically falls downwards)

class SparkSystemVertical expands SparkSystem;

defaultproperties
{
     bInitiallyActive=True
     RandomDelay=1.500000
     VelocityMin=(X=-50.000000,Y=-50.000000,Z=-25.000000)
     VelocityMax=(X=50.000000,Y=50.000000,Z=-100.000000)
     bHidden=False
     bDirectional=False
}
