//==============================================================================
//	R_RbotsDebug_View_NavMesh
//	Debug View for RBots NavMesh
//==============================================================================
class R_RBotsDebug_View_NavMesh extends R_RBotsDebug_View;

const Utilities = Class'RBots.R_BotUtilities';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const DebugNavMeshCategory = 'NavMesh';

// Vertical offset for drawing to avoid z fighting and invisible lines
const VERTICAL_DRAW_OFFSET = 2.0;

const VertexSize = 6.0;
const NormalSize = 16.0;

var private bool bDrawNormals;
var private bool bDrawVertices;

// Colors
var Color VertexColor;
var Color TriangleColor;
var Color NormalColor;

simulated function ToggleNormals()
{
	bDrawNormals = !bDrawNormals;
}

simulated function ToggleVertices()
{
	bDrawVertices = !bDrawVertices;
}

simulated function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager)
{
	local R_BotNavMesh NavMesh;

	NavMesh = GetNavMesh();

	// Add color legend
	StringManager.AddColor(DebugNavMeshCategory, "NavMesh Vertices", VertexColor);
	StringManager.AddColor(DebugNavMeshCategory, "NavMesh Nodes", TriangleColor);
	StringManager.AddColor(DebugNavMeshCategory, "Normals", NormalColor);

	// Add debug strings
	if(NavMesh != None)
	{
		StringManager.AddInt(DebugNavMeshCategory, "NumVertices", NavMesh.GetVertexCount());
		StringManager.AddInt(DebugNavMeshCategory, "NumTriangles", NavMesh.GetTriangleCount());
		StringManager.AddBool(DebugNavMeshCategory, "HasBadAdjacents", NavMesh.HasBadAdjacents());
	}
	else
	{
		StringManager.AddWarning(DebugNavMeshCategory, "Invalid NavMesh");
	}

	if(NavMesh != None)
	{
		DrawNavMesh(C, NavMesh);
	}
}

simulated function DrawNavMesh(Canvas C, R_BotNavMesh NavMesh)
{
	DrawNavMeshVertices(C, NavMesh);
	DrawNavMeshTriangles(C, NavMesh);

	// This will draw the node containing the player, and that node's adjacencies
	//DrawPlayerContainedNavMeshTriangle(C, NavMesh);
}

simulated function DrawNavMeshVertices(Canvas C, R_BotNavMesh NavMesh)
{
	local Vector VertexLocation;
	local Vector DrawExtents, DrawVerticalOffset;
	local float VertexRGB[3];
	local int VertexCount;
	local int i;

	if(!bDrawVertices)
	{
		return;
	}

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

simulated function DrawNavMeshTriangles(Canvas C, R_BotNavMesh NavMesh)
{
	local int IndexA, IndexB, IndexC;
	local Vector VertexA, VertexB, VertexC;
	local float NodeRGB[3], NormalRGB[3];
	local Vector TriangleCenter, TriangleNormal;
	local Vector DrawVerticalOffset;
	local int TriangleCount;
	local int i;

	TriangleCount = NavMesh.GetTriangleCount();

	Utilities.Static.ColorToFloats(TriangleColor, NodeRGB[0], NodeRGB[1], NodeRGB[2]);
	Utilities.Static.ColorToFloats(NormalColor, NormalRGB[0], NormalRGB[1], NormalRGB[2]);

	DrawVerticalOffset = Vect(0,0,1) * VERTICAL_DRAW_OFFSET;

	for(i = 0; i < TriangleCount; ++i)
	{
		NavMesh.GetTriangleUnchecked(i, IndexA, IndexB, IndexC);
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

simulated function DrawPlayerContainedNavMeshTriangle(Canvas C, R_BotNavMesh NavMesh)
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

		if(NavMesh.FindContainingNode(PlayerLocation, ContainingIndex))
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

defaultproperties
{
	VertexColor=(R=252,G=207,B=91)
	TriangleColor=(R=6,G=119,B=6)
	NormalColor=(R=255,0,0)
	bDrawNormals=true
	bDrawVertices=false
}