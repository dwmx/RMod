//==============================================================================
//	R_NavMeshGraphInterface_PolyGroups
//	NavGraphInterface for performing pathfinding on the PolyGroups of a NavMesh
//	In this graph, PolyGroups are nodes, Portals are edges
//==============================================================================
class R_NavMeshGraphInterface_PolyGroups extends R_NavMeshGraphInterface;

function int GetNodeCount()
{
	local R_NavMesh LocalNavMesh;

	LocalNavMesh = GetNavMesh();
	if(LocalNavMesh != None)
	{
		return LocalNavMesh.GetPolyGroupCount();
	}
	return 0;
}

function GetNeighborSet(int NodeIndex, out R_NavNeighborSet OutNeighborSet)
{
	local R_NavMesh LocalNavMesh;
	local R_NavMeshPolyGroup LocalPolyGroup;

	LocalNavMesh = GetNavMesh();
	if(LocalNavMesh == None)
	{
		return;
	}

	LocalPolyGroup = LocalNavMesh.GetPolyGroupByIndex(NodeIndex);
	if(LocalPolyGroup == None)
	{
		return;
	}

	NavObjectClass.Static.NavNeighborSet_Clear(OutNeighborSet);

	LocalPolyGroup.GetNeighborSet(OutNeighborSet);
}