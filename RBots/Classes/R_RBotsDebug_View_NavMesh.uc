//==============================================================================
//	R_RbotsDebug_View_NavMesh
//	Debug View for RBots NavMesh
//==============================================================================
class R_RbotsDebug_View_NavMesh extends R_RbotsDebug_View;

const Utilities = Class'RBots.R_BotUtilities';
const DebugNavMeshCategory = 'NavMesh';

var R_BotNavMesh CachedNavMesh;

// Vertex display
var Color VertexColor;
var float VertexSize;

// Triangle display
var Color TriangleColor;
var Color NormalColor;

simulated function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager)
{
	local R_BotNavMesh NavMesh;

	// Add debug strings
	StringManager.AddInt(DebugNavMeshCategory, "NumVertices", CachedNavMesh.GetVertexCount());
	StringManager.AddInt(DebugNavMeshCategory, "NumTriangles", CachedNavMesh.GetTriangleCount());
	StringManager.AddBool(DebugNavMeshCategory, "HasBadAdjacents", CachedNavMesh.HasBadAdjacents());
	StringManager.AddClass(DebugNavMeshCategory, "PathFinderClass", CachedNavMesh.PathFinderClass);
	StringManager.AddClass(DebugNavMeshCategory, "PathPostProcessorClass", CachedNavMesh.PathPostProcessorClass);

	// Update the NavMesh if necessary
	if(CachedNavMesh == None)
	{
		foreach AllActors(Class'RBots.R_BotNavMesh', NavMesh)
		{
			break;
		}
		CachedNavMesh = NavMesh;
	}
	
	if(CachedNavMesh != None)
	{
		DrawNavMesh(C, CachedNavMesh);
	}
}

simulated function DrawNavMesh(Canvas C, R_BotNavMesh NavMesh)
{
	DrawNavMeshVertices(C, NavMesh);
	DrawNavMeshTriangles(C, NavMesh);
	DrawPlayerContainedNavMeshTriangle(C, NavMesh);
}

simulated function DrawNavMeshVertices(Canvas C, R_BotNavMesh NavMesh)
{
	local Vector VertexExtents;
	local Vector Vertex;
	local int VertexCount;
	local int i;

	VertexExtents.X = VertexSize;
	VertexExtents.Y = VertexSize;
	VertexExtents.Z = VertexSize;

	VertexCount = NavMesh.GetVertexCount();

	for(i = 0; i < VertexCount; ++i)
	{
		NavMesh.GetVertexUnchecked(i, Vertex);
		C.DrawBox3D(Vertex, VertexExtents, VertexColor.R, VertexColor.G, VertexColor.B);
	}
}

simulated function DrawNavMeshTriangles(Canvas C, R_BotNavMesh NavMesh)
{
	local int IndexA, IndexB, IndexC;
	local Vector VertexA, VertexB, VertexC;
	local float TR, TG, TB;
	local float NR, NG, NB;
	local Vector TriangleCenter, TriangleNormal;
	local int TriangleCount;
	local int i;

	TriangleCount = NavMesh.GetTriangleCount();

	// Triangle color
	TR = float(TriangleColor.R) / 255.0;
	TG = float(TriangleColor.G) / 255.0;
	TB = float(TriangleColor.B) / 255.0;

	// Normal color
	NR = float(NormalColor.R) / 255.0;
	NG = float(NormalColor.G) / 255.0;
	NB = float(NormalColor.B) / 255.0;

	for(i = 0; i < TriangleCount; ++i)
	{
		NavMesh.GetTriangleUnchecked(i, IndexA, IndexB, IndexC);
		NavMesh.GetVertexUnchecked(IndexA, VertexA);
		NavMesh.GetVertexUnchecked(IndexB, VertexB);
		NavMesh.GetVertexUnchecked(IndexC, VertexC);

		// Draw triangle
		C.DrawLine3D(VertexA, VertexB, TR, TG, TB);
		C.DrawLine3D(VertexB, VertexC, TR, TG, TB);
		C.DrawLine3D(VertexC, VertexA, TR, TG, TB);

		// Draw normal
		NavMesh.GetTriangleNormalAndCenterUnchecked(i, TriangleNormal, TriangleCenter);
		C.DrawLine3D(TriangleCenter, TriangleCenter + TriangleNormal * 32.0, NR, NG, NB);
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
	VertexSize=16.0
	TriangleColor=(R=11,G=247,B=11)
	NormalColor=(R=255,0,0)
}