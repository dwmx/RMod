//==============================================================================
//	R_RbotsDebug_View_PathFinding
//	Debug View for path finding
//==============================================================================
class R_RbotsDebug_View_PathFinding extends R_RbotsDebug_View config(RBotsDebug);

const Utilities = Class'RBots.R_BotUtilities';
const DebugLib = Class'RBots.R_RBots_DebugLibrary';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const DebugPathFindingCategory = 'PathFinding';

var private R_NavContextObserver NavContextObserver;
const NavContextObserverClass = Class'RBots.R_NavContextObserver';

const NODE_DRAW_ELEVATION = 4.0;		// Pushes node drawing up on the Z axis
const PATH_DRAW_ELEVATION = 32.0;		// Pushes path drawing up on the Z axis
const PORTAL_DRAW_ELEVATION = 4.0;		// Pushes portal drawing up on the Z axis
const BOUNDARY_PUSH_ELEVATION = 4.0;	// Pushes boundary push drawing up on the Z axis

const GOAL_POINT_DRAW_SIZE = 16.0;
const PATH_POINT_DRAW_SIZE = 8.0;
const PORTAL_DRAW_SIZE = 4.0;
const BOUNDARY_PUSH_DRAW_LENGTH = 24.0;

var Color PathNodeColor;		// Color of each NavMesh node
var Color PathPointColor;		// Color of each world location path point
var Color PathStartColor;		// Color of the path start location
var Color PathEndColor;			// Color of the path goal
var Color PathEdgeColor;		// Color of edges between path points
var Color LeftPortalColor;		// Color of left portal points
var Color RightPortalColor;		// Color of right portal points
var Color BoundaryPushDirColor;	// Color of boundary-push vectors

var config bool bDrawPathNodes;
var config bool bDrawPathNodeIndexNumeric;
var config bool bDrawPathPoints;
var config bool bDrawPathPortals;
var config bool bDrawBoundaryPushDirs;

function TogglePathPoints()
{
	bDrawPathPoints = !bDrawPathPoints;
	SaveConfig();
}

function TogglePathNodes()
{
	bDrawPathNodes = !bDrawPathNodes;
	SaveConfig();
}

function TogglePathPortals()
{
	bDrawPathPortals = !bDrawPathPortals;
	SaveConfig();
}

function ToggleBoundaryPushDirs()
{
	bDrawBoundaryPushDirs = !bDrawBoundaryPushDirs;
	SaveConfig();
}

function InitNavContextObserver()
{
	if((NavContextObserver == None))
	{
		NavContextObserver = new(None) NavContextObserverClass;
	}
}

function DebugTargetChanged(R_Bot OldDebugTarget, R_Bot NewDebugTarget)
{
	InitNavContextObserver();

	if(NavContextObserver != None)
	{
		if(OldDebugTarget != None)
		{
			if(OldDebugTarget.GetNavContextObserver() == NavContextObserver)
			{
				OldDebugTarget.DetachNavContextObserver();
			}
		}

		NavContextObserver.ClearPath();
		if(Utilities.Static.IsValidActor(NewDebugTarget))
		{
			NewDebugTarget.AttachNavContextObserver(NavContextObserver);
		}
	}
}

simulated function DrawDebugView(Canvas C, R_RBotsDebug_StringManager StringManager)
{
	local R_RBotsDebug DebugMutator;
	local R_Bot DebugTarget;
	local int NumPathPoints;
	local Vector TempVector;

	DebugMutator = GetDebugMutator();
	if(DebugMutator != None)
	{
		DebugTarget = DebugMutator.DebugTarget;
	}

	if(DebugTarget != None)
	{
		// Make sure NavContextObserver is attached
		if(NavContextObserver == None)
		{
			InitNavContextObserver();
		}

		DebugTarget.AttachNavContextObserver(NavContextObserver);
	}

	//--------------------------------------------------------------------------
	// Add Debug strings
	StringManager.AddActor(DebugPathFindingCategory, "DebugTarget", DebugTarget);

	//--------------------------------------------------------------------------
	// Add data retrieved by NavContextObserver
	StringManager.AddClass(DebugPathFindingCategory, "NavContextObserverClass", NavContextObserverClass);
	StringManager.AddObject(DebugPathFindingCategory, "NavContextObserver", NavContextObserver);
	if(NavContextObserver != None)
	{
		StringManager.AddClass(DebugPathFindingCategory, "NavPathFinder Class", NavContextObserver.GetNavPathFinderClass());
		StringManager.AddClass(DebugPathFindingCategory, "NavPathFilter Class", NavContextObserver.GetNavPathFilterClass());
	}

	//--------------------------------------------------------------------------
	// Draw debug visuals
	if(bDrawPathNodes)
	{
		DrawPathNodes(C, DebugTarget, StringManager);
	}
	if(bDrawPathPoints)
	{
		DrawPathPoints(C, DebugTarget, StringManager);
	}
	if(bDrawPathPortals)
	{
		DrawPathPortals(C, DebugTarget, StringManager);
	}
	if(bDrawBoundaryPushDirs)
	{
		DrawBoundaryPushDirs(C, DebugTarget, StringManager);
	}
}

simulated function DrawPathNodes(Canvas C, R_Bot DebugTarget, R_RBotsDebug_StringManager StringManager)
{
	local R_NavMesh NavMesh;
	local int VertexIndices[3];
	local Vector VertexLocations[3];
	local int NumPathNodeIndices;
	local int PathNodeIndex;
	local int i, j;
	local float NodeR, NodeG, NodeB;
	local Vector Normal, Center;
	local Vector DrawElevation;

	NavMesh = GetNavMesh();
	if(NavContextObserver == None || NavMesh == None)
	{
		StringManager.AddWarning(DebugPathFindingCategory, "DrawPathNodes failed" @ "NavContextObserver:" @ NavContextObserver @ "NavMesh:" @ NavMesh);
		return;
	}

	NumPathNodeIndices = NavContextObserver.GetNumPathNodeIndices();

	// Color legend and strings
	StringManager.AddColor(DebugPathFindingCategory, "Path Nodes", PathNodeColor);
	StringManager.AddInt(DebugPathFindingCategory, "PathNodesCount", NumPathNodeIndices);

	DrawElevation = Vect(0,0,1) * NODE_DRAW_ELEVATION;
	Utilities.Static.ColorToFloats(PathNodeColor, NodeR, NodeG, NodeB);

	// Draw all nodes
	for(i = 0; i < NumPathNodeIndices; ++i)
	{
		if(NavContextObserver.GetPathNodeIndex(i, PathNodeIndex))
		{
			NavMesh.GetTriangleVertexIndicesUnchecked(PathNodeIndex, VertexIndices[0], VertexIndices[1], VertexIndices[2]);
			for(j = 0; j < 3; ++j)
			{
				NavMesh.GetVertexUnchecked(VertexIndices[j], VertexLocations[j]);
			}

			for(j = 0; j < 3; ++j)
			{	// Draw node edges
				C.DrawLine3D(VertexLocations[0] + DrawElevation, VertexLocations[1] + DrawElevation, NodeR, NodeG, NodeB);
				C.DrawLine3D(VertexLocations[1] + DrawElevation, VertexLocations[2] + DrawElevation, NodeR, NodeG, NodeB);
				C.DrawLine3D(VertexLocations[2] + DrawElevation, VertexLocations[0] + DrawElevation, NodeR, NodeG, NodeB);
			}

			if(bDrawPathNodeIndexNumeric)
			{	// Draw the index in the middle of the node
				NavMesh.GetTriangleNormalAndCenterUnchecked(PathNodeIndex, Normal, Center);
				DebugLib.Static.InitializeCanvasForDebugDrawing(C);
				CanvasLib.Static.DrawTextAtWorldLocation(C, "" $ i, Center + DrawElevation, Vect(0.5,0.5,0.0));
			}
		}
	}
}

simulated function DrawPathPoints(Canvas C, R_Bot DebugTarget, R_RBotsDebug_StringManager StringManager)
{
	local int i;
	local int NumPathPoints;
	local Vector PathPointExtents, GoalPointExtents;
	local Vector PathPoint, PrevPathPoint;
	local float PointR, PointG, PointB;
	local float StartRGB[3], EndRGB[3];
	local float EdgeR, EdgeG, EdgeB;
	local Vector DrawElevation;

	if(DebugTarget == None || NavContextObserver == None)
	{
		StringManager.AddWarning(DebugPathFindingCategory, "DrawPathPoints failed" @ "DebugTarget:" @ DebugTarget @ "NavContextObserver:" @ NavContextObserver);
		return;
	}

	// Color legend
	StringManager.AddColor(DebugPathFindingCategory, "Path Start Location", PathStartColor);
	StringManager.AddColor(DebugPathFindingCategory, "Path End Location", PathEndColor);
	StringManager.AddInt(DebugPathFindingCategory, "NumPathPoints", NumPathPoints);

	Utilities.Static.ColorToFloats(PathPointColor, PointR, PointG, PointB);
	Utilities.Static.ColorToFloats(PathStartColor, StartRGB[0], StartRGB[1], StartRGB[2]);
	Utilities.Static.ColorToFloats(PathEndColor, EndRGB[0], EndRGB[1], EndRGB[2]);
	Utilities.Static.ColorToFloats(PathEdgeColor, EdgeR, EdgeG, EdgeB);

	PathPointExtents = Vect(1.0,1.0,0.5) * PATH_POINT_DRAW_SIZE;
	GoalPointExtents = Vect(1.0,1.0,0.5) * GOAL_POINT_DRAW_SIZE;
	//NumPathPoints = DebugTarget.GetNumPathPoints();
	NumPathPoints = NavContextObserver.GetNumPathLocations();

	DrawElevation = Vect(0,0,0);
	DrawElevation.Z = PATH_DRAW_ELEVATION;

	for(i = 0; i < NumPathPoints; ++i)
	{
		PrevPathPoint = PathPoint;
		if(NavContextObserver.GetPathLocation(i, PathPoint))
		{
			if(i == 0)
			{	// Start location
				CanvasLib.Static.DrawBox3D(C, PathPoint + DrawElevation, GoalPointExtents, StartRGB[0], StartRGB[1], StartRGB[2]);
			}
			else if(i == NumPathPoints - 1)
			{	// End location
				CanvasLib.Static.DrawBox3D(C, PathPoint + DrawElevation, GoalPointExtents, EndRGB[0], EndRGB[1], EndRGB[2]);
			}
			else
			{	// Intermediate path point
				CanvasLib.Static.DrawBox3D(C, PathPoint + DrawElevation, PathPointExtents, PointR, PointG, PointB);
			}
		}

		if(i > 0)
		{
			CanvasLib.Static.DrawLine3D(C, PrevPathPoint + DrawElevation, PathPoint + DrawElevation, EdgeR, EdgeG, EdgeB);
		}
	}
}

simulated function DrawPathPortals(Canvas C, R_Bot DebugTarget, R_RBotsDebug_StringManager StringManager)
{
	local Vector PortalLeft, PortalRight;
	local int PortalsCount;
	local float PosX, PosY;
	local int i;
	local float LeftPortalRGB[3], RightPortalRGB[3];
	local Vector PortalExtents;
	local Vector DrawElevation;

	if(NavContextObserver == None)
	{
		StringManager.AddWarning(DebugPathFindingCategory, "DrawPathPortals failed" @ "NavContextObserver:" @ NavContextObserver);
		return;
	}

	StringManager.AddColor(DebugPathFindingCategory, "Left Portal Vertex", LeftPortalColor);
	StringManager.AddColor(DebugPathFindingCategory, "Right Portal Vertex", RightPortalColor);
	StringManager.AddInt(DebugPathFindingCategory, "PortalsCount", NavContextObserver.GetPortalsCount());
	StringManager.AddInt(DebugPathFindingCategory, "BoundaryLeftCount", NavContextObserver.GetBoundaryLeftCount());
	StringManager.AddInt(DebugPathFindingCategory, "BoundaryRightCount", NavContextObserver.GetBoundaryRightCount());

	Utilities.Static.ColorToFloats(LeftPortalColor, LeftPortalRGB[0], LeftPortalRGB[1], LeftPortalRGB[2]);
	Utilities.Static.ColorToFloats(RightPortalColor, RightPortalRGB[0], RightPortalRGB[1], RightPortalRGB[2]);

	DrawElevation = Vect(0,0,0);
	DrawElevation.Z = PORTAL_DRAW_ELEVATION;

	PortalExtents = Vect(1.0,1.0,0.5) * PORTAL_DRAW_SIZE;

	PortalsCount = NavContextObserver.GetPortalsCount();
	for(i = 0; i < PortalsCount; ++i)
	{
		if(NavContextObserver.GetPortal(i, PortalLeft, PortalRight))
		{
			CanvasLib.Static.DrawBox3D(C, PortalLeft + DrawElevation, PortalExtents, LeftPortalRGB[0], LeftPortalRGB[1], LeftPortalRGB[2]);
			CanvasLib.Static.DrawBox3D(C, PortalRight + DrawElevation, PortalExtents, RightPortalRGB[0], RightPortalRGB[1], RightPortalRGB[2]);
		}
	}
}

simulated function DrawBoundaryPushDirs(Canvas C, R_Bot DebugTarget, R_RBotsDebug_StringManager StringManager)
{
	local Vector BoundaryVector;
	local Vector PushDir;
	local Vector DrawOffset;
	local float DrawRGB[3];
	local int BoundaryCount;
	local int i;

	if(NavContextObserver == None)
	{
		StringManager.AddWarning(DebugPathFindingCategory, "DrawBoundaryPushDirs failed" @ "NavContextObserver:" @ NavContextObserver);
		return;
	}

	StringManager.AddColor(DebugPathFindingCategory, "Boundary Push Directions", BoundaryPushDirColor);

	Utilities.Static.ColorToFloats(BoundaryPushDirColor, DrawRGB[0], DrawRGB[1], DrawRGB[2]);

	DrawOffset = Vect(0,0,1) * BOUNDARY_PUSH_ELEVATION;

	// Draw all left boundary push dirs
	BoundaryCount = NavContextObserver.GetBoundaryLeftCount();
	for(i = 0; i < BoundaryCount; ++i)
	{
		NavContextObserver.GetBoundaryLeftVector(i, BoundaryVector, PushDir);
		if(PushDir != Vect(0,0,0))
		{
			CanvasLib.Static.DrawLine3D(
			C,
			DrawOffset + BoundaryVector,
			DrawOffset + BoundaryVector + PushDir * BOUNDARY_PUSH_DRAW_LENGTH,
			DrawRGB[0], DrawRGB[1], DrawRGB[2]);
		}
	}

	// Draw all right boundary push dirs
	BoundaryCount = NavContextObserver.GetBoundaryRightCount();
	for(i = 0; i < BoundaryCount; ++i)
	{
		NavContextObserver.GetBoundaryRightVector(i, BoundaryVector, PushDir);
		if(PushDir != Vect(0,0,0))
		{
			CanvasLib.Static.DrawLine3D(
			C,
			DrawOffset + BoundaryVector,
			DrawOffset + BoundaryVector + PushDir * BOUNDARY_PUSH_DRAW_LENGTH,
			DrawRGB[0], DrawRGB[1], DrawRGB[2]);
		}
	}
}

defaultproperties
{
	PathNodeColor=(R=11,G=49,B=133)
	PathPointColor=(R=240,G=226,B=41)
	PathStartColor=(R=255,G=56,B=238)
	PathEndColor=(R=55,G=255,B=28)
	PathEdgeColor=(R=240,G=226,B=41)
	LeftPortalColor=(R=255,G=56,B=238)
	RightPortalColor=(R=240,G=226,B=41)
	BoundaryPushDirColor=(R=255,G=13,B=13)
	bDrawPathNodes=true
	bDrawPathNodeIndexNumeric=true
	bDrawPathPoints=true
	bDrawPathPortals=true
	bDrawBoundaryPushDirs=true
}