//==============================================================================
//	R_RbotsDebug_View_NavMesh
//	Debug View for RBots NavMesh
//==============================================================================
class R_RBotsDebug_View_NavMesh extends R_RBotsDebug_View config(RBotsDebug);

const Utilities = Class'RBots.R_BotUtilities';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const NavLib = Class'RBots.R_NavLibrary';
const DebugNavMeshCategory = 'NavMesh';

// Vertical offset for drawing to avoid z fighting and invisible lines
const VERTICAL_DRAW_OFFSET = 2.0;

const VertexSize = 6.0;
const NormalSize = 16.0;

var config private bool bDrawNormals;
var config private bool bDrawVertices;
var config private bool bDrawEdges;
var config private bool bDrawTriangles;
var config private bool bDrawNeighbors;
var config private bool bDrawAdjacents;
var config private bool bDrawProximity;

// Colors
var Color VertexColor;
var Color TriangleColor;
var Color NormalColor;

var Color EdgeColor_Normal;
var Color EdgeColor_Border;
var Color EdgeColor_Impassable;

var Color TriangleColor_Contained;
var Color TriangleColor_Adjacent;
var Color TriangleColor_Proximity;

simulated function ToggleNormals()
{
	bDrawNormals = !bDrawNormals;
	SaveConfig();
}

simulated function ToggleVertices()
{
	bDrawVertices = !bDrawVertices;
	SaveConfig();
}

simulated function ToggleEdges()
{
	bDrawEdges = !bDrawEdges;
	if(bDrawEdges && bDrawTriangles)
	{	// Can't really see edges and triangles together
		bDrawTriangles = false;
	}
	SaveConfig();
}

simulated function ToggleTriangles()
{
	bDrawTriangles = !bDrawTriangles;
	if(bDrawTriangles && bDrawEdges)
	{	// Can't really see edges and triangles together
		bDrawEdges = false;
	}
	SaveConfig();
}

function ToggleNeighbors()
{
	bDrawNeighbors = !bDrawNeighbors;
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

simulated function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager)
{
	local R_NavMesh NavMesh;

	NavMesh = GetNavMesh();

	// Add debug strings
	if(NavMesh != None)
	{
		StringManager.AddClass(DebugNavMeshCategory, "NavMesh Class", NavMesh.Class);
		StringManager.AddInt(DebugNavMeshCategory, "NumVertices", NavMesh.GetVertexCount());
		StringManager.AddInt(DebugNavMeshCategory, "NumEdges", NavMesh.GetEdgeCount());
		StringManager.AddInt(DebugNavMeshCategory, "NumTriangles", NavMesh.GetTriangleCount());
	}
	else
	{
		StringManager.AddWarning(DebugNavMeshCategory, "Invalid NavMesh");
	}

	if(NavMesh != None)
	{
		DrawNavMesh(C, StringManager, NavMesh);
	}
}

simulated function DrawNavMesh(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	if(bDrawVertices)
	{
		DrawNavMeshVertices(C, StringManager, NavMesh);
	}
	if(bDrawEdges)
	{
		DrawNavMeshEdges(C, StringManager, NavMesh);
	}
	if(bDrawTriangles)
	{
		DrawNavMeshTriangles(C, StringManager, NavMesh);
	}

	StringManager.AddBool(DebugNavMeshCategory, "Draw Neighbors", bDrawNeighbors);
	if(bDrawNeighbors)
	{
		DrawNavMeshNeighbors(C, StringManager, NavMesh);
	}
	
	// This will draw the node containing the player, and that node's adjacencies
	//DrawPlayerContainedNavMeshTriangle(C, NavMesh);
}

simulated function DrawNavMeshVertices(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local Vector VertexLocation;
	local Vector DrawExtents, DrawVerticalOffset;
	local float VertexRGB[3];
	local int VertexCount;
	local int i;

	StringManager.AddColor(DebugNavMeshCategory, "NavMesh Vertices", VertexColor);

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

simulated function DrawNavMeshEdges(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local int V0, V1;
	local int EdgeFlags;
	local Vector Location0, Location1;
	local int EdgeCount;
	local float EdgeRGB[3], BorderPassableRGB[3], BorderImpassableRGB[3];
	local Vector DrawVerticalOffset;
	local int i;

	StringManager.AddColor(DebugNavMeshCategory, "Edges", EdgeColor_Normal);
	StringManager.AddColor(DebugNavMeshCategory, "Passable Border Edges", EdgeColor_Border);
	StringManager.AddColor(DebugNavMeshCategory, "Impassable Edges", EdgeColor_Impassable);

	EdgeCount = NavMesh.GetEdgeCount();

	Utilities.Static.ColorToFloats(EdgeColor_Normal, EdgeRGB[0], EdgeRGB[1], EdgeRGB[2]);
	Utilities.Static.ColorToFloats(EdgeColor_Border, BorderPassableRGB[0], BorderPassableRGB[1], BorderPassableRGB[2]);
	Utilities.Static.ColorToFloats(EdgeColor_Impassable, BorderImpassableRGB[0], BorderImpassableRGB[1], BorderImpassableRGB[2]);

	DrawVerticalOffset = Vect(0,0,1) * VERTICAL_DRAW_OFFSET;

	for(i = 0; i < EdgeCount; ++i)
	{
		NavMesh.GetEdgeVertexIndicesUnchecked(i, V0, V1);
		NavMesh.GetVertexUnchecked(V0, Location0);
		NavMesh.GetVertexUnchecked(V1, Location1);

		NavMesh.GetEdgeFlagsUnchecked(i, EdgeFlags);

		// Draw edge -----------------------------------------------------------
		if((EdgeFlags & NavLib.Static.EdgeFlag_Impassable()) == NavLib.Static.EdgeFlag_Impassable())
		{	// Impassable edge
			C.DrawLine3D(Location0 + DrawVerticalOffset, Location1 + DrawVerticalOffset, BorderImpassableRGB[0], BorderImpassableRGB[1], BorderImpassableRGB[2]);
			continue;
		}
		if((EdgeFlags & NavLib.Static.EdgeFlag_Border()) == NavLib.Static.EdgeFlag_Border())
		{	// Border edge
			C.DrawLine3D(Location0 + DrawVerticalOffset, Location1 + DrawVerticalOffset, BorderPassableRGB[0], BorderPassableRGB[1], BorderPassableRGB[2]);
			continue;
		}

		// Normal edge
		C.DrawLine3D(Location0 + DrawVerticalOffset, Location1 + DrawVerticalOffset, EdgeRGB[0], EdgeRGB[1], EdgeRGB[2]);
	}
}

simulated function DrawNavMeshTriangles(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local int IndexA, IndexB, IndexC;
	local Vector VertexA, VertexB, VertexC;
	local float NodeRGB[3], NormalRGB[3];
	local Vector TriangleCenter, TriangleNormal;
	local Vector DrawVerticalOffset;
	local int TriangleCount;
	local int i;

	StringManager.AddColor(DebugNavMeshCategory, "NavMesh Nodes", TriangleColor);
	if(bDrawNormals)
	{
		StringManager.AddColor(DebugNavMeshCategory, "Normals", NormalColor);
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

simulated function DrawNavMeshNeighbors(Canvas C, R_RbotsDebug_StringManager StringManager, R_NavMesh NavMesh)
{
	local Vector PlayerLocation;
	local int NodeIndex;
	local int V[3];
	local Vector VLoc[3];
	local float RGBActive[3], RGBProxy[3], RGBAdjacent[3];
	local int Nodes[16];
	local float Costs[16];
	local int NumNodes;
	local int AdjacentNodes[3], AdjacentEdges[3];
	local float AdjacentCosts[3];
	local int i, j;

	Utilities.Static.ColorToFloats(TriangleColor_Contained, RGBActive[0], RGBActive[1], RGBActive[2]);

	if(Owner != None && Owner.Owner != None)
	{
		PlayerLocation = Owner.Owner.Location;
		NodeIndex = NavMesh.FindContainingNodeIndex(PlayerLocation);

		StringManager.AddColor(DebugNavMeshCategory, "Current Index", TriangleColor_Contained);
		StringManager.AddInt(DebugNavMeshCategory, "Current Index", NodeIndex);

		// Draw node the player is standing on
		NavMesh.GetTriangleVertexLocationsUnchecked(NodeIndex, VLoc);
		DrawTriangle(C, VLoc, RGBActive, 0.75, 8.0);

		// Draw adjacent nodes
		StringManager.AddBool(DebugNavMeshCategory, "Draw Adjacent Neighbors", bDrawAdjacents);
		if(bDrawAdjacents)
		{
			// Draw all adjacent nodes
			Utilities.Static.ColorToFloats(TriangleColor_Adjacent, RGBAdjacent[0], RGBAdjacent[1], RGBAdjacent[2]);
			StringManager.AddColor(DebugNavMeshCategory, "Adjacent Neighbors", TriangleColor_Adjacent);

			NavMesh.GetTriangleAdjacentDataUnchecked(NodeIndex, AdjacentNodes, AdjacentEdges, AdjacentCosts);
			for(i = 0; i < 3; ++i)
			{
				if(AdjacentNodes[i] == NavLib.Static.InvalidIndex())
				{
					continue;
				}

				NavMesh.GetTriangleVertexLocationsUnchecked(AdjacentNodes[i], VLoc);
				DrawTriangle(C, VLoc, RGBAdjacent, 0.75, 8.0);
			}
		}
		
		// Draw proximal nodes
		StringManager.AddBool(DebugNavMeshCategory, "Draw Proximal Neighbors", bDrawProximity);
		if(bDrawProximity)
		{
			Utilities.Static.ColorToFloats(TriangleColor_Proximity, RGBProxy[0], RGBProxy[1], RGBProxy[2]);
			StringManager.AddColor(DebugNavMeshCategory, "Proximal Neighbors", TriangleColor_Proximity);

			// Draw all proxy nodes in some radius
			NavMesh.GetTriangleProximalDataUnchecked(NodeIndex, Nodes, Costs, NumNodes);
			for(i = 0; i < NumNodes; ++i)
			{
				if(Nodes[i] == NodeIndex)
				{
					continue;
				}

				NavMesh.GetTriangleVertexLocationsUnchecked(Nodes[i], VLoc);
				DrawTriangle(C, VLoc, RGBProxy, 0.75, 8.0);
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

/*
simulated function DrawPlayerContainedNavMeshTriangle(Canvas C, R_NavMesh NavMesh)
{
	local int ContainingIndex;
	local Vector TriangleNormal, TriangleCenter;
	local Vector PlayerLocation;
	//local int AdjacentIndexA, AdjacentIndexB, AdjacentIndexC;
	local int Adjacents[3];
	local int i;

	if(Owner != None && Owner.Owner != None)
	{
		PlayerLocation = Owner.Owner.Location;

		if(NavMesh.FindContainingTriangle(PlayerLocation, ContainingIndex))
		{
			NavMesh.GetTriangleNormalAndCenterUnchecked(ContainingIndex, TriangleNormal, TriangleCenter);
			C.DrawBox3D(TriangleCenter, Vect(64,64,64), 1, 1, 0);

			// Draw adjacents
			NavMesh.GetTriangleAdjacentsUnchecked(ContainingIndex, Adjacents[0], Adjacents[1], Adjacents[2]);
			for(i = 0; i < 3; ++i)
			{
				if(Adjacents[i] != -1)
				{
					NavMesh.GetTriangleNormalAndCenterUnchecked(Adjacents[i], TriangleNormal, TriangleCenter);
					C.DrawBox3D(TriangleCenter, Vect(64,64,64), 0, 0, 1);
				}
			}
		}
	}
}
	*/

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
	bDrawNormals=true
	bDrawVertices=false
	bDrawEdges=true
	bDrawNeighbors=true
	bDrawAdjacents=true
	bDrawProximity=true
}