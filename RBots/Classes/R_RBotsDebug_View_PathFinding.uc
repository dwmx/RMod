//==============================================================================
//	R_RbotsDebug_View_PathFinding
//	Debug View for path finding
//==============================================================================
class R_RbotsDebug_View_PathFinding extends R_RbotsDebug_View;

const Utilities = Class'RBots.R_BotUtilities';
const DebugPathFindingCategory = 'PathFinding';

var Color PathPointColor;
var Color PathEdgeColor;

function DebugTargetChanged(R_Bot OldDebugTarget, R_Bot NewDebugTarget)
{
	Super.DebugTargetChanged(OldDebugTarget, NewDebugTarget);
}

simulated function DrawDebugView(Canvas C, R_RBotsDebug_StringManager StringManager)
{
	local float PathPointR, PathPointG, PathPointB;
	local R_RBotsDebug DebugMutator;
	local R_BotNavMesh NavMesh;
	local R_Bot DebugTarget;
	local int NumPathPoints;

	DebugMutator = GetDebugMutator();
	if(DebugMutator != None)
	{
		DebugTarget = DebugMutator.DebugTarget;
	}

	if(DebugTarget != None)
	{
		NumPathPoints = DebugTarget.GetNumPathPoints();
	}

	// Add Debug strings
	StringManager.AddActor(DebugPathFindingCategory, "DebugTarget", DebugTarget);

	NavMesh = GetNavMesh();
	if(NavMesh != None)
	{
		StringManager.AddClass(DebugPathFindingCategory, "PathFinderClass", NavMesh.PathFinderClass);
		StringManager.AddClass(DebugPathFindingCategory, "PathPostProcessorClass", NavMesh.PathPostProcessorClass);
	}

	StringManager.AddInt(DebugPathFindingCategory, "NumPathPoints", NumPathPoints);

	// Draw visuals
	DrawPathPoints(C, DebugTarget);
}

simulated function DrawPathPoints(Canvas C, R_Bot DebugTarget)
{
	local int i;
	local int NumPathPoints;
	local Vector VertexExtents;
	local Vector PathPoint, PrevPathPoint;

	if(DebugTarget == None)
	{
		return;
	}

	VertexExtents.X = 32.0;
	VertexExtents.Y = 32.0;
	VertexExtents.Z = 32.0;
	NumPathPoints = DebugTarget.GetNumPathPoints();

	for(i = 0; i < NumPathPoints; ++i)
	{
		PrevPathPoint = PathPoint;
		if(DebugTarget.GetPathPoint(i, PathPoint))
		{
			C.DrawBox3D(PathPoint, VertexExtents, 0, 1, 0);
		}

		if(i > 0)
		{
			C.DrawLine3D(PrevPathPoint, PathPoint, 1.0, 1.0, 0.0);
		}
	}
}

defaultproperties
{
	PathPointColor=(R=255,G=0,B=0)
	PathEdgeColor=(R=0,G=255,B=255)
}