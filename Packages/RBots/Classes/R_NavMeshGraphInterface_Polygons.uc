//==============================================================================
//	R_NavMeshGraphInterface_Polygons
//	NavGraphInterface for performing pathfinding on the polygons in a NavMesh
//==============================================================================
class R_NavMeshGraphInterface_Polygons extends R_NavMeshGraphInterface;

function int GetNodeCount()
{
	local R_NavMesh LocalNavMesh;

	LocalNavMesh = GetNavMesh();
	if(LocalNavmesh != None)
	{
		return LocalNavMesh.GetTriangleCount();
	}
	return 0;
}

function GetNeighborSet(int NodeIndex, out R_NavNeighborSet OutNeighborSet)
{
	local R_NavMesh LocalNavMesh;

	LocalNavMesh = GetNavMesh();
	if(LocalNavMesh != None)
	{
		LocalNavMesh.GetTriangleNeighborSetUnchecked(NodeIndex, OutNeighborSet);
	}
}