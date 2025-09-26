//==============================================================================
//	R_RbotsDebug_View_NavMesh
//	Debug View for RBots NavMesh
//==============================================================================
class R_RBotsDebug_View_NavMesh extends R_RBotsDebug_View config(RBotsDebug);

const Utilities = Class'RBots.R_BotUtilities';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const DebugLib = Class'RBots.R_RBots_DebugLibrary';
const NavLib = Class'RBots.R_NavLibrary';
const NavTranslator = Class'RBots.R_RBotsDebug_NavObjectTranslator';

const DebugCategory_NavMesh = 'NavMesh';
const DebugCategory_NavMeshPolygon = 'NavMeshPolygons';
const DebugCategory_NavMeshEdges = 'NavMeshEdges';
const DebugCategory_NavMeshPolyGroup = 'NavMeshPolyGroups';
const DebugCategory_NavMeshNeighbors = 'NavMeshNeighbors';
const DebugCategory_NavMeshPlayerBorders = 'NavMeshPlayerBorders';

// Vertical offset for drawing to avoid z fighting and invisible lines
const VERTICAL_DRAW_OFFSET = 2.0;

const VertexSize = 6.0;
const NormalSize = 16.0;

enum R_NavMeshDrawMode
{
	DrawMode_None,
	DrawMode_Polygons,
	DrawMode_Edges,
	DrawMode_PolyGroups
};
var config private R_NavMeshDrawMode DrawMode;

var config private bool bDrawNormals;
var config private bool bDrawVertices;
var config private bool bDrawEdgeOrientations;
var config private bool bDrawNeighbors;
var config private bool bDrawNeighborCosts;
var config private bool bDrawAdjacents;
var config private bool bDrawProximity;
var config private bool bDrawPlayerBorders;

// Colors
var Color VertexColor;
var Color TriangleColor;
var Color NormalColor;

var Color EdgeColor_Normal;
var Color EdgeColor_Border;
var Color EdgeColor_Impassable;
var Color EdgeColor_Orientation;

var Color TriangleColor_Contained;
var Color TriangleColor_Adjacent;
var Color TriangleColor_Proximity;

var Color PlayerColor_Borders;
var Color PlayerColor_BorderAvoidance;

var Color PolyGroupColor_ActivePolygons;
var Color PolyGroupColor_NeighboringPolygons;
var Color PolyGroupColor_InactivePolygons;
var Color PolyGroupColor_InvalidPolygons;
var Color PolyGroupColor_Actors;

function SwitchToOrDisableDrawMode(R_NavMeshDrawMode NewDrawMode)
{
	if(DrawMode == NewDrawMode)
	{
		NewDrawMode = DrawMode_None;
	}
	if(DrawMode == NewDrawMode)
	{
		return;
	}

	DrawMode = NewDrawMode;
	SaveConfig();
}

function ToggleTriangles()
{
	SwitchToOrDisableDrawMode(DrawMode_Polygons);
}

function ToggleEdges()
{
	SwitchToOrDisableDrawMode(DrawMode_Edges);
}

function TogglePolyGroupInfo()
{
	SwitchToOrDisableDrawMode(DrawMode_PolyGroups);
}



function ToggleNormals()
{
	bDrawNormals = !bDrawNormals;
	SaveConfig();
}

function ToggleVertices()
{
	bDrawVertices = !bDrawVertices;
	SaveConfig();
}



function ToggleEdgeOrientations()
{
	bDrawEdgeOrientations = !bDrawEdgeOrientations;
	SaveConfig();
}



function ToggleNeighbors()
{
	bDrawNeighbors = !bDrawNeighbors;
	SaveConfig();
}

function ToggleCosts()
{
	bDrawNeighborCosts = !bDrawNeighborCosts;
	SaveConfig();
}

function ToggleAdjacents()
{
	bDrawAdjacents = !bDrawAdjacents;
	SaveConfig();
}

function ToggleProximity()
{
	bDrawProximity = !bDrawProximity;
	SaveConfig();
}

function TogglePlayerBorders()
{
	bDrawPlayerBorders = !bDrawPlayerBorders;
	SaveConfig();
}



function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager)
{
	local R_NavMesh NavMesh;

	NavMesh = GetNavMesh();

	// Add debug strings
	if(NavMesh != None)
	{
		StringManager.AddClass(DebugCategory_NavMesh, "NavMesh Class", NavMesh.Class);
		StringManager.AddInt(DebugCategory_NavMesh, "NumVertices", NavMesh.GetVertexCount());
		StringManager.AddInt(DebugCategory_NavMesh, "NumEdges", NavMesh.GetEdgeCount());
		StringManager.AddInt(DebugCategory_NavMesh, "NumTriangles", NavMesh.GetTriangleCount());
	}
	else
	{
		StringManager.AddWarning(DebugCategory_NavMesh, "Invalid NavMesh");
	}

	if(NavMesh != None)
	{
		DrawNavMesh(C, StringManager, NavMesh);
	}
}

function DrawNavMesh(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	// Draw Mode
	StringManager.AddString(DebugCategory_NavMesh, String(GetEnum(Enum'R_NavMeshDrawMode', DrawMode)), "Draw Mode");
	switch(DrawMode)
	{
	case DrawMode_Polygons:		DrawNavMeshTriangles(C, StringManager, NavMesh);	break;
	case DrawMode_Edges:		DrawNavMeshEdges(C, StringManager, NavMesh);		break;
	case DrawMode_PolyGroups:	DrawPolyGroupInfo(C, StringManager, NavMesh);		break;
	}

	// Vertices -- Available in any draw mode
	StringManager.AddBool(DebugCategory_NavMesh, "Draw Vertices", bDrawVertices);
	if(bDrawVertices)
	{
		DrawNavMeshVertices(C, StringManager, NavMesh);
	}

	// Neighbors -- Available in any draw mode
	StringManager.AddBool(DebugCategory_NavMesh, "Draw Neighbors", bDrawNeighbors);
	if(bDrawNeighbors)
	{
		DrawNavMeshNeighbors(C, StringManager, NavMesh);
	}

	// Player Borders -- Available in any draw mode
	StringManager.AddBool(DebugCategory_NavMesh, "Draw Player Borders", bDrawPlayerBorders);
	if(bDrawPlayerBorders)
	{
		DrawNavMeshPlayerBorders(C, StringManager, NavMesh);
	}
}

function DrawNavMeshVertices(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local Vector VertexLocation;
	local Vector DrawExtents, DrawVerticalOffset;
	local float VertexRGB[3];
	local int VertexCount;
	local int i;

	StringManager.AddColor(DebugCategory_NavMesh, "NavMesh Vertices", VertexColor);

	DrawExtents = Vect(1.0,1.0,0.5) * VertexSize;
	DrawVerticalOffset = Vect(0,0,1) * VERTICAL_DRAW_OFFSET;
	Utilities.Static.ColorToFloats(VertexColor, VertexRGB[0], VertexRGB[1], VertexRGB[2]);

	VertexCount = NavMesh.GetVertexCount();
	for(i = 0; i < VertexCount; ++i)
	{
		NavMesh.GetVertexUnchecked(i, VertexLocation);
		CanvasLib.Static.DrawBox3D(C, VertexLocation + DrawVerticalOffset, DrawExtents, VertexRGB[0], VertexRGB[1], VertexRGB[2]);
	}
}

function DrawNavMeshEdges(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local int V0, V1;
	local int EdgeFlags;
	local Vector Location0, Location1;
	local Vector Center, Orientation;
	local int EdgeCount;
	local float EdgeRGB[3], BorderPassableRGB[3], BorderImpassableRGB[3], OrientationRGB[3];
	local Vector DrawVerticalOffset;
	local bool bImpassable, bBorder;
	local int i;

	StringManager.AddColor(DebugCategory_NavMeshEdges, "Edges", EdgeColor_Normal);
	StringManager.AddColor(DebugCategory_NavMeshEdges, "Passable Border Edges", EdgeColor_Border);
	StringManager.AddColor(DebugCategory_NavMeshEdges, "Impassable Edges", EdgeColor_Impassable);

	EdgeCount = NavMesh.GetEdgeCount();

	Utilities.Static.ColorToFloats(EdgeColor_Normal, EdgeRGB[0], EdgeRGB[1], EdgeRGB[2]);
	Utilities.Static.ColorToFloats(EdgeColor_Border, BorderPassableRGB[0], BorderPassableRGB[1], BorderPassableRGB[2]);
	Utilities.Static.ColorToFloats(EdgeColor_Impassable, BorderImpassableRGB[0], BorderImpassableRGB[1], BorderImpassableRGB[2]);

	if(bDrawEdgeOrientations)
	{
		StringManager.AddColor(DebugCategory_NavMeshEdges, "Edge Orientations", EdgeColor_Orientation);
		Utilities.Static.ColorToFloats(EdgeColor_Orientation, OrientationRGB[0], OrientationRGB[1], OrientationRGB[2]);
	}

	DrawVerticalOffset = Vect(0,0,1) * VERTICAL_DRAW_OFFSET;

	for(i = 0; i < EdgeCount; ++i)
	{
		NavMesh.GetEdgeVertexIndicesUnchecked(i, V0, V1);
		NavMesh.GetVertexUnchecked(V0, Location0);
		NavMesh.GetVertexUnchecked(V1, Location1);

		NavMesh.GetEdgeFlagsUnchecked(i, EdgeFlags);

		// Draw edge -----------------------------------------------------------
		bImpassable = false;
		bBorder = false;
		if((EdgeFlags & NavLib.Static.EdgeFlag_Impassable()) == NavLib.Static.EdgeFlag_Impassable())	bImpassable = true;
		if((EdgeFlags & NavLib.Static.EdgeFlag_Border()) == NavLib.Static.EdgeFlag_Border())			bBorder = true;

		if(bImpassable)
		{	// Impassable edge
			CanvasLib.Static.DrawLine3D(
				C,
				Location0 + DrawVerticalOffset,
				Location1 + DrawVerticalOffset,
				BorderImpassableRGB[0], BorderImpassableRGB[1], BorderImpassableRGB[2]);
		}
		else if(bBorder)
		{	// Border edge
			CanvasLib.Static.DrawLine3D(
				C,
				Location0 + DrawVerticalOffset,
				Location1 + DrawVerticalOffset,
				BorderPassableRGB[0], BorderPassableRGB[1], BorderPassableRGB[2]);
		}
		else
		{	// Normal edge
			CanvasLib.Static.DrawLine3D(
				C,
				Location0 + DrawVerticalOffset,
				Location1 + DrawVerticalOffset,
				EdgeRGB[0], EdgeRGB[1], EdgeRGB[2]);
		}

		// Edge orientation
		if(bDrawEdgeOrientations && (bBorder || bImpassable))
		{
			NavMesh.GetEdgeOrientationUnchecked(i, Orientation);
			Center = (Location0 + Location1) * 0.5f;
			CanvasLib.Static.DrawLine3D(
				C,
				Center + DrawVerticalOffset,
				(Center + Orientation * 64.0) + DrawVerticalOffset,
				OrientationRGB[0], OrientationRGB[1], OrientationRGB[2]);
		}
	}
}

function DrawNavMeshTriangles(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local int IndexA, IndexB, IndexC;
	local Vector VertexA, VertexB, VertexC;
	local float NodeRGB[3], NormalRGB[3];
	local Vector TriangleCenter, TriangleNormal;
	local Vector DrawVerticalOffset;
	local int TriangleCount;
	local int i;

	StringManager.AddColor(DebugCategory_NavMeshPolygon, "NavMesh Nodes", TriangleColor);
	if(bDrawNormals)
	{
		StringManager.AddColor(DebugCategory_NavMeshPolygon, "Normals", NormalColor);
	}

	TriangleCount = NavMesh.GetTriangleCount();

	Utilities.Static.ColorToFloats(TriangleColor, NodeRGB[0], NodeRGB[1], NodeRGB[2]);
	Utilities.Static.ColorToFloats(NormalColor, NormalRGB[0], NormalRGB[1], NormalRGB[2]);

	DrawVerticalOffset = Vect(0,0,1) * VERTICAL_DRAW_OFFSET;

	for(i = 0; i < TriangleCount; ++i)
	{
		NavMesh.GetTriangleVertexIndicesUnchecked(i, IndexA, IndexB, IndexC);
		NavMesh.GetVertexUnchecked(IndexA, VertexA);
		NavMesh.GetVertexUnchecked(IndexB, VertexB);
		NavMesh.GetVertexUnchecked(IndexC, VertexC);

		// Draw triangle
		C.DrawLine3D(VertexA + DrawVerticalOffset, VertexB + DrawVerticalOffset, NodeRGB[0], NodeRGB[1], NodeRGB[2]);
		C.DrawLine3D(VertexB + DrawVerticalOffset, VertexC + DrawVerticalOffset, NodeRGB[0], NodeRGB[1], NodeRGB[2]);
		C.DrawLine3D(VertexC + DrawVerticalOffset, VertexA + DrawVerticalOffset, NodeRGB[0], NodeRGB[1], NodeRGB[2]);

		// Draw normal
		if(bDrawNormals)
		{
			NavMesh.GetTriangleNormalAndCenterUnchecked(i, TriangleNormal, TriangleCenter);
			C.DrawLine3D(TriangleCenter + DrawVerticalOffset, TriangleCenter + DrawVerticalOffset + TriangleNormal * NormalSize, NormalRGB[0], NormalRGB[1], NormalRGB[2]);
		}
	}
}

function DrawNavMeshNeighbors(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local Vector PlayerLocation;
	local int NodeIndex;
	local int V[3];
	local Vector VLoc[3], Normal, Center;
	local float RGBActive[3], RGBProxy[3], RGBAdjacent[3];
	local int NumNodes;
	local int AdjacentNodes[3];
	local float AdjacentCosts[3];
	local int ProximalNodes[32];
	local float ProximalCosts[32];
	local int i, j;

	DebugLib.Static.InitializeCanvasForDebugDrawing(C);
	Utilities.Static.ColorToFloats(TriangleColor_Contained, RGBActive[0], RGBActive[1], RGBActive[2]);

	if(Owner != None && Owner.Owner != None)
	{
		PlayerLocation = Owner.Owner.Location;
		NodeIndex = NavMesh.FindContainingNodeIndex(PlayerLocation);

		StringManager.AddColor(DebugCategory_NavMeshNeighbors, "Current Index", TriangleColor_Contained);
		StringManager.AddInt(DebugCategory_NavMeshNeighbors, "Current Index", NodeIndex);

		// Draw node the player is standing on
		NavMesh.GetTriangleVertexLocationsUnchecked(NodeIndex, VLoc);
		DrawTriangle(C, VLoc, RGBActive, 0.75, 8.0);

		// Draw adjacent nodes
		StringManager.AddBool(DebugCategory_NavMeshNeighbors, "Draw Adjacent Neighbors", bDrawAdjacents);
		if(bDrawAdjacents)
		{
			// Draw all adjacent nodes
			Utilities.Static.ColorToFloats(TriangleColor_Adjacent, RGBAdjacent[0], RGBAdjacent[1], RGBAdjacent[2]);
			StringManager.AddColor(DebugCategory_NavMeshNeighbors, "Adjacent Neighbors", TriangleColor_Adjacent);

			NavTranslator.Static.GetAdjacentNeighbors(NavMesh, NodeIndex, AdjacentNodes, AdjacentCosts, NumNodes);
			for(i = 0; i < NumNodes; ++i)
			{
				if(AdjacentNodes[i] == NavLib.Static.InvalidIndex())
				{
					continue;
				}

				NavMesh.GetTriangleVertexLocationsUnchecked(AdjacentNodes[i], VLoc);
				DrawTriangle(C, VLoc, RGBAdjacent, 0.75, 8.0);

				if(bDrawNeighborCosts)
				{
					NavMesh.GetTriangleNormalAndCenterUnchecked(AdjacentNodes[i], Normal, Center);
					CanvasLib.Static.DrawTextAtWorldLocation(C, "C:" $ Utilities.Static.FloatToString(AdjacentCosts[i], 1), Center, Vect(0.5,0.5,0.0));
				}
			}
		}
		
		// Draw proximal nodes
		StringManager.AddBool(DebugCategory_NavMeshNeighbors, "Draw Proximal Neighbors", bDrawProximity);
		if(bDrawProximity)
		{
			Utilities.Static.ColorToFloats(TriangleColor_Proximity, RGBProxy[0], RGBProxy[1], RGBProxy[2]);
			StringManager.AddColor(DebugCategory_NavMeshNeighbors, "Proximal Neighbors", TriangleColor_Proximity);

			// Draw all proxy nodes in some radius
			NavTranslator.Static.GetProximalNeighbors(NavMesh, NodeIndex, ProximalNodes, ProximalCosts, NumNodes);
			for(i = 0; i < NumNodes; ++i)
			{
				if(ProximalNodes[i] == NodeIndex)
				{
					continue;
				}

				NavMesh.GetTriangleVertexLocationsUnchecked(ProximalNodes[i], VLoc);
				DrawTriangle(C, VLoc, RGBProxy, 0.75, 8.0);

				if(bDrawNeighborCosts)
				{
					NavMesh.GetTriangleNormalAndCenterUnchecked(ProximalNodes[i], Normal, Center);
					CanvasLib.Static.DrawTextAtWorldLocation(C, "C:" $ Utilities.Static.FloatToString(ProximalCosts[i], 1), Center, Vect(0.5,0.5,0.0));
				}
			}
		}
	}
}

function DrawTriangle(Canvas C, Vector VLoc[3], float RGB[3], float Scale, optional float NormalOffset)
{
	local Vector Center;
	local Vector NormalOffsetVec;

	Center = (VLoc[0] + VLoc[1] + VLoc[2]) * (1.0/3.0);
	VLoc[0] = Center + ((VLoc[0] - Center) * Scale);
	VLoc[1] = Center + ((VLoc[1] - Center) * Scale);
	VLoc[2] = Center + ((VLoc[2] - Center) * Scale);

	if(NormalOffset != 0.0)
	{
		NormalOffsetVec = Normal((VLoc[1] - VLoc[0]) Cross (VLoc[2] - VLoc[0])) * NormalOffset;
		VLoc[0] += NormalOffsetVec;
		VLoc[1] += NormalOffsetVec;
		VLoc[2] += NormalOffsetVec;
	}

	CanvasLib.Static.DrawLine3D(C, VLoc[0], VLoc[1], RGB[0], RGB[1], RGB[2]);
	CanvasLib.Static.DrawLine3D(C, VLoc[1], VLoc[2], RGB[0], RGB[1], RGB[2]);
	CanvasLib.Static.DrawLine3D(C, VLoc[2], VLoc[0], RGB[0], RGB[1], RGB[2]);
}

function DrawNavMeshPlayerBorders(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local Vector Location;
	local int EdgeIndices[32], NumEdges;
	local float EdgeDistances[32];
	local Vector VLoc[2], EdgeCenter;
	local float BorderRGB[3], AvoidanceRGB[3];
	local String DistanceString;
	local Vector AvoidanceDir;
	local int i;

	StringManager.AddColor(DebugCategory_NavMeshPlayerBorders, "Near Player Borders", PlayerColor_Borders);
	StringManager.AddColor(DebugCategory_NavMeshPlayerBorders, "Border Avoidance Dir", PlayerColor_BorderAvoidance);

	if(Owner != None && Owner.Owner != None)
	{
		Utilities.Static.ColorToFloats(PlayerColor_Borders, BorderRGB[0], BorderRGB[1], BorderRGB[2]);
		Utilities.Static.ColorToFloats(PlayerColor_BorderAvoidance, AvoidanceRGB[0], AvoidanceRGB[1], AvoidanceRGB[2]);

		Location = Owner.Owner.Location;

		NavMesh.FindRelevantBorderEdgesInRadius2D(Location, 256.0, EdgeIndices, EdgeDistances, NumEdges);
		for(i = 0; i < NumEdges; ++i)
		{
			NavMesh.GetEdgeVertexLocationsUnchecked(EdgeIndices[i], VLoc);
			EdgeCenter = (VLoc[0] + VLoc[1]) * 0.5f;
			CanvasLib.Static.DrawLine3D(C, Location, EdgeCenter, BorderRGB[0], BorderRGB[1], BorderRGB[2]);

			// Draw distance as text
			DistanceString = Utilities.Static.FloatToString(EdgeDistances[i], 1);
			DebugLib.Static.InitializeCanvasForDebugDrawing(C);
			CanvasLib.Static.DrawTextAtWorldLocation(C, DistanceString, EdgeCenter, Vect(0.5, 0.5, 0.0));
		}

		// Draw the avoidance direction
		AvoidanceDir = NavLib.Static.CalcBorderAvoidanceDirection(NavMesh, EdgeIndices, EdgeDistances, NumEdges, Location, 16.0, 64.0);
		CanvasLib.Static.DrawLine3D(C, Location, Location + AvoidanceDir * 64.0, AvoidanceRGB[0], AvoidanceRGB[1], AvoidanceRGB[2]);
	}
}

function DrawPolyGroupInfo(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local R_NavMeshPolyGroup PolyGroup;
	local int NumPolyGroups, NumTriangles;
	local int PlayerNodeIndex, PlayerPolyGroupIndex, OtherPolyGroupIndex;
	local float ActiveRGB[3], NeighborRGB[3], InactiveRGB[3], InvalidRGB[3];
	local Vector VLoc[3];
	local int i, j;
	local int PolyGroupTriangleCount;
	local float PortalCost;
	local int TriangleIndex;
	local Vector DrawLocation;

	NumPolyGroups = NavMesh.GetPolyGroupCount();

	// Add strings
	StringManager.AddInt(DebugCategory_NavMeshPolyGroup, "NumPolyGroups", NumPolyGroups);
	for(i = 0; i < NumPolyGroups; ++i)
	{
		PolyGroup = NavMesh.GetPolyGroupByIndex(i);
		if(PolyGroup != None)
		{
			StringManager.AddName(DebugCategory_NavMeshPolyGroup, "PolyGroups[" $ i $ "]", PolyGroup.GetPolyGroupName());
		}
	}

	// Draw PolyGroup visuals
	if(Owner == None || Owner.Owner == None)
	{
		StringManager.AddWarning(DebugCategory_NavMeshPolyGroup, "Failed to draw PolyGroup data, Owner == None or Owner.Owner == None");
	}
	else
	{
		PlayerNodeIndex = NavMesh.FindContainingNodeIndex(Owner.Owner.Location); // Owner.Owner is Player's PlayerPawn

		NavMesh.GetTrianglePolyGroupIndexUnchecked(PlayerNodeIndex, PlayerPolyGroupIndex);

		// Info for the PolyGroup the Player is standing inside of
		PolyGroup = NavMesh.GetPolyGroupByIndex(PlayerPolyGroupIndex);
		StringManager.AddObject(DebugCategory_NavMeshPolyGroup, "Current PolyGroup", PolyGroup);
		if(PolyGroup != None)
		{
			StringManager.AddName(DebugCategory_NavMeshPolyGroup, "Current PolyGroup Name", PolyGroup.GetPolyGroupName());
			StringManager.AddInt(DebugCategory_NavMeshPolyGroup, "Current PolyGroup NumPortals", PolyGroup.GetPortalCount());
			StringManager.AddInt(DebugCategory_NavMeshPolyGroup, "Current PolyGroup NumTriangles", PolyGroup.GetTriangleIndexCount());
		}

		// Color legend
		StringManager.AddColor(DebugCategory_NavMeshPolyGroup, "Polygons in Current PolyGroup", PolyGroupColor_ActivePolygons);
		StringManager.AddColor(DebugCategory_NavMeshPolyGroup, "Polygons in Neighboring PolyGroup", PolyGroupColor_NeighboringPolygons);
		StringManager.AddColor(DebugCategory_NavMeshPolyGroup, "Polygons not in Current PolyGroup", PolyGroupColor_InactivePolygons);
		StringManager.AddColor(DebugCategory_NavMeshPolyGroup, "No PolyGroup Assigned", PolyGroupColor_InvalidPolygons);
		Utilities.Static.ColorToFloats(PolyGroupColor_ActivePolygons, ActiveRGB[0], ActiveRGB[1], ActiveRGB[2]);
		Utilities.Static.ColorToFloats(PolyGroupColor_NeighboringPolygons, NeighborRGB[0], NeighborRGB[1], NeighborRGB[2]);
		Utilities.Static.ColorToFloats(PolyGroupColor_InactivePolygons, InactiveRGB[0], InactiveRGB[1], InactiveRGB[2]);
		Utilities.Static.ColorToFloats(PolyGroupColor_InvalidPolygons, InvalidRGB[0], InvalidRGB[1], InvalidRGB[2]);

		// Draw color-coded PolyGroups
		NumTriangles = NavMesh.GetTriangleCount();
		for(i = 0; i < NumTriangles; ++i)
		{
			NavMesh.GetTriangleVertexLocationsUnchecked(i, VLoc);
			NavMesh.GetTrianglePolyGroupIndexUnchecked(i, OtherPolyGroupIndex);

			if(OtherPolyGroupIndex == NavLib.Static.InvalidIndex())
			{	// Invalid polygroups
				DrawTriangle(C, VLoc, InvalidRGB, 1.0, 1.0);
			}
			else if(OtherPolyGroupIndex == PlayerPolyGroupIndex)
			{	// Polygons belonging to the polygroup the player is on
				DrawTriangle(C, VLoc, ActiveRGB, 1.0, 1.0);
			}
			else if(PolyGroup != None && PolyGroup.DoesPortalExistToDest(OtherPolyGroupIndex))
			{	// Polygons belong to a neighboring polygroup
				DrawTriangle(C, VLoc, NeighborRGB, 1.0, 1.0);
			}
			else
			{	// All other polygroups
				DrawTriangle(C, VLoc, InactiveRGB, 1.0, 1.0);
			}
		}

		// Draw portal cost visualization
		if(PolyGroup != None)
		{
			PolyGroupTriangleCount = PolyGroup.GetTriangleIndexCount();
			for(j = 0; j < PolyGroupTriangleCount; ++j)
			{
				PortalCost = PolyGroup.GetPortalCostFromIndex(j, 0);
				TriangleIndex = PolyGroup.GetTriangleIndex(j);
				NavMesh.GetTriangleVertexLocationsUnchecked(TriangleIndex, VLoc);
				DrawLocation = (VLoc[0] + VLoc[1] + VLoc[2]) * (1.0/3.0);
				DebugLib.Static.InitializeCanvasForDebugDrawing(C);
				CanvasLib.Static.DrawTextAtWorldLocation(C, "C:" $ PortalCost, DrawLocation, Vect(0.5,0.5,0.0));
			}
		}
	}
}

defaultproperties
{
	VertexColor=(R=252,G=207,B=91)
	TriangleColor=(R=4,G=73,B=4)
	TriangleColor_Contained=(R=23,G=255,B=54)
	TriangleColor_Adjacent=(R=255,G=0,B=255)
	TriangleColor_Proximity=(R=251,G=255,B=3)
	NormalColor=(R=255,0,0)
	EdgeColor_Normal=(R=29,G=44,B=133)
	EdgeColor_Border=(R=43,G=255,B=53)
	EdgeColor_Impassable=(R=255,G=32,B=32)
	EdgeColor_Orientation=(R=255,G=255,B=0)
	PlayerColor_Borders=(R=248,G=55,B=255)
	PlayerColor_BorderAvoidance=(R=255,G=251,B=1)
	PolyGroupColor_ActivePolygons=(R=0,G=245,B=41)
	PolyGroupColor_NeighboringPolygons=(R=245,G=241,B=0)
	PolyGroupColor_InactivePolygons=(R=202,G=0,B=0)
	PolyGroupColor_InvalidPolygons=(R=255,G=255,B=255)
	PolyGroupColor_Actors=(R=17,G=219,B=255)
	bDrawNormals=true
	bDrawVertices=false
	bDrawEdgeOrientations=true
	bDrawNeighbors=true
	bDrawNeighborCosts=true
	bDrawAdjacents=true
	bDrawProximity=true
	bDrawPlayerBorders=true
}