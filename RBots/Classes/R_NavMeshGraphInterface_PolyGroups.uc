//==============================================================================
//	R_NavMeshGraphInterface_PolyGroups
//	NavGraphInterface for performing pathfinding on the PolyGroups of a NavMesh
//	In this graph, PolyGroups are nodes, Portals are edges
//==============================================================================
class R_NavMeshGraphInterface_PolyGroups extends R_NavMeshGraphInterface;

/**
*	TODO
*	Need to build neighbor sets for polygroups and portal in NavMesh
*	Once that is done, implement this class
*/

function int GetNodeCount()
{
	return 0;
}

function GetNeighborSet(int NodeIndex, out R_NavNeighborSet OutNeighborSet)
{}