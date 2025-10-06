//==============================================================================
//	R_NavMeshGraphInterface_Portals
//	NavGraphInterface for performing pathfinding on Portals between PolyGroups
//	inside a NavMesh
//	In this graph, Portals are nods, PolyGroups are edges
//==============================================================================
class R_NavMeshGraphInterface_Portals extends R_NavMeshGraphInterface;

function int GetNodeCount()
{
	local R_NavMesh LocalNavMesh;

	LocalNavMesh = GetNavMesh();
	if(LocalNavMesh != None)
	{
		return LocalNavMesh.GetPortalCount();
	}
	return 0;
}

function GetNeighborSet(int NodeIndex, out R_NavNeighborSet OutNeighborSet)
{
	local R_NavMesh LocalNavMesh;
	local R_NavMeshPortal LocalPortal;

	NavObjectClass.Static.NavNeighborSet_Clear(OutNeighborSet);

	LocalNavMesh = GetNavMesh();
	if(LocalNavMesh == None)
	{
		return;
	}

	LocalPortal = LocalNavMesh.GetPortalByIndex(NodeIndex);
	if(LocalPortal == None)
	{
		return;
	}

	LocalPortal.GetNeighborSet(OutNeighborSet);
}