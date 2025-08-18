//==============================================================================
//	R_RbotsDebug_View_PathFinding
//	Debug View for path finding
//==============================================================================
class R_RbotsDebug_View_PathFinding extends R_RbotsDebug_View;

const Utilities = Class'RBots.R_BotUtilities';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const DebugPathFindingCategory = 'PathFinding';

var private R_PathFindData PathFindData;
const PathFindDataClass = Class'RBots.R_PathFindData';

var Color PathNodeColor;	// Color of each NavMesh node
var Color PathPointColor;	// Color of each world location path point
var Color PathEdgeColor;	// Color of edges between path points

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
		// Make sure PathFindData is attached
		if(PathFindData == None)
		{
			PathFindData = new(None) PathFindDataClass;
		}
		DebugTarget.AttachPathFindData(PathFindData);

		NumPathPoints = DebugTarget.GetNumPathPoints();
	}

	//--------------------------------------------------------------------------
	// Add Debug strings
	StringManager.AddActor(DebugPathFindingCategory, "DebugTarget", DebugTarget);

	// NavMesh
	NavMesh = GetNavMesh();
	if(NavMesh != None)
	{
		StringManager.AddClass(DebugPathFindingCategory, "PathFinderClass", NavMesh.PathFinderClass);
		StringManager.AddClass(DebugPathFindingCategory, "PathPostProcessorClass", NavMesh.PathPostProcessorClass);
	}

	// PathFindData
	StringManager.AddClass(DebugPathFindingCategory, "PathFindDataClass", PathFindDataClass);
	StringManager.AddObject(DebugPathFindingCategory, "PathFindData", PathFindData);
	if(PathFindData != None)
	{
		StringManager.AddInt(DebugPathFindingCategory, "PathNodesCount", PathFindData.GetPathNodesCount());
		StringManager.AddInt(DebugPathFindingCategory, "PortalsCount", PathFindData.GetPortalsCount());
	}

	// Path
	StringManager.AddInt(DebugPathFindingCategory, "NumPathPoints", NumPathPoints);

	//--------------------------------------------------------------------------
	// Draw debug visuals
	DrawPathNodes(C, DebugTarget);
	DrawPathPoints(C, DebugTarget);
	DrawPathPortals(C, DebugTarget);
}

simulated function DrawPathNodes(Canvas C, R_Bot DebugTarget)
{
	local R_BotNavMesh NavMesh;
	local int VertexIndices[3];
	local Vector VertexLocations[3];
	local int PathNodesCount;
	local int PathNodeIndex;
	local int i, j;
	local float NodeR, NodeG, NodeB;

	if(PathFindData == None)
	{
		return;
	}

	NavMesh = GetNavMesh();
	if(NavMesh == None)
	{
		return;
	}

	// Draw all nodes
	Utilities.Static.ColorToFloats(PathNodeColor, NodeR, NodeG, NodeB);
	PathNodesCount = PathFindData.GetPathNodesCount();
	for(i = 0; i < PathNodesCount; ++i)
	{
		if(PathFindData.GetPathNode(i, PathNodeIndex))
		{
			NavMesh.GetTriangleUnchecked(PathNodeIndex, VertexIndices[0], VertexIndices[1], VertexIndices[2]);
			for(j = 0; j < 3; ++j)
			{
				NavMesh.GetVertexUnchecked(VertexIndices[j], VertexLocations[j]);
			}

			for(j = 0; j < 3; ++j)
			{
				C.DrawLine3D(VertexLocations[0], VertexLocations[1], NodeR, NodeG, NodeB);
				C.DrawLine3D(VertexLocations[1], VertexLocations[2], NodeR, NodeG, NodeB);
				C.DrawLine3D(VertexLocations[2], VertexLocations[0], NodeR, NodeG, NodeB);
			}
		}
	}
}

simulated function DrawPathPoints(Canvas C, R_Bot DebugTarget)
{
	local int i;
	local int NumPathPoints;
	local Vector VertexExtents;
	local Vector PathPoint, PrevPathPoint;
	local float PointR, PointG, PointB;
	local float EdgeR, EdgeG, EdgeB;

	if(DebugTarget == None)
	{
		return;
	}

	Utilities.Static.ColorToFloats(PathPointColor, PointR, PointG, PointB);
	Utilities.Static.ColorToFloats(PathEdgeColor, EdgeR, EdgeG, EdgeB);

	VertexExtents.X = 12.0;
	VertexExtents.Y = 12.0;
	VertexExtents.Z = 6.0;
	NumPathPoints = DebugTarget.GetNumPathPoints();

	for(i = 0; i < NumPathPoints; ++i)
	{
		PrevPathPoint = PathPoint;
		if(DebugTarget.GetPathPoint(i, PathPoint))
		{
			CanvasLib.Static.DrawBox3D(C, PathPoint, VertexExtents, PointR, PointG, PointB);
		}

		if(i > 0)
		{
			CanvasLib.Static.DrawLine3D(C, PrevPathPoint, PathPoint, EdgeR, EdgeG, EdgeB);
		}
	}
}

simulated function DrawPathPortals(Canvas C, R_Bot DebugTarget)
{
}

defaultproperties
{
	PathNodeColor=(R=21,G=91,B=243)
	PathPointColor=(R=25,G=228,B=86)
	PathEdgeColor=(R=240,G=226,B=41)
}