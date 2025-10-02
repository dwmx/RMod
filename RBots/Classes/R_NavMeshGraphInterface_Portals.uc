//==============================================================================
//	R_NavMeshGraphInterface_Portals
//	NavGraphInterface for performing pathfinding on Portals between PolyGroups
//	inside a NavMesh
//	In this graph, Portals are nods, PolyGroups are edges
//==============================================================================
class R_NavMeshGraphInterface_Portals extends R_NavMeshGraphInterface;

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