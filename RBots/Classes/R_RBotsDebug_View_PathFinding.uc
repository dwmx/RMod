//==============================================================================
//	R_RbotsDebug_View_PathFinding
//	Debug View for path finding
//==============================================================================
class R_RbotsDebug_View_PathFinding extends R_RbotsDebug_View;

const Utilities = Class'RBots.R_BotUtilities';
const DebugPathFindingCategory = 'PathFinding';

var Color PathPointColor;
var Color PathEdgeColor;

simulated function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager)
{
	local float PathPointR, PathPointG, PathPointB;

	StringManager.AddString(DebugPathFindingCategory, "NumPathPoints:" @ 0);

	Utilities.Static.ColorToFloats(PathPointColor, PathPointR, PathPointG, PathPointB);
}

simulated function DrawPathPoints(Canvas C)
{

}

defaultproperties
{
	PathPointColor=(R=255,G=0,B=0)
	PathEdgeColor=(R=0,G=255,B=255)
}