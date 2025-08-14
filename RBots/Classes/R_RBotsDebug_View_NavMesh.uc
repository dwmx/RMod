//==============================================================================
//	R_RbotsDebug_View_NavMesh
//	Debug View for RBots NavMesh
//==============================================================================
class R_RbotsDebug_View_NavMesh extends R_RbotsDebug_View;

const Utilities = Class'RBots.R_BotUtilities';
var R_BotNavMesh CachedNavMesh;

// Vertex display
var Color VertexColor;
var float VertexSize;

// Triangle display
var Color TriangleColor;

simulated event PostRender(Canvas C)
{
	local R_BotNavMesh NavMesh;

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
	local float R, G, B;
	local int TriangleCount;
	local int i;

	TriangleCount = NavMesh.GetTriangleCount();
	R = float(TriangleColor.R);
	G = float(TriangleColor.G);
	B = float(TriangleColor.B);

	for(i = 0; i < TriangleCount; ++i)
	{
		NavMesh.GetTriangleUnchecked(i, IndexA, IndexB, IndexC);
		NavMesh.GetVertexUnchecked(IndexA, VertexA);
		NavMesh.GetVertexUnchecked(IndexB, VertexB);
		NavMesh.GetVertexUnchecked(IndexC, VertexC);
		C.DrawLine3D(VertexA, VertexB, R, G, B);
		C.DrawLine3D(VertexB, VertexC, R, G, B);
		C.DrawLine3D(VertexC, VertexA, R, G, B);
	}
}

defaultproperties
{
	VertexColor=(R=252,G=207,B=91)
	VertexSize=16.0
	TriangleColor=(R=0,G=1,B=0)
}