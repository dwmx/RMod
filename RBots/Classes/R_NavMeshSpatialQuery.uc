//==============================================================================
//	R_NavMeshSpatialQuery
//	Interface for performing spatial and proximity look-ups on NavMesh
//==============================================================================
class R_NavMeshSpatialQuery extends R_NavObject abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavSpatialQuery';

const NavLib = Class'RBots.R_NavLibrary';
const GeomLib = Class'RBase.R_AGeometryLibrary';

function InitNavMeshSpatialQuery(R_NavMesh NavMesh);

function bool FindContainingNode(R_NavMesh NavMesh, Vector Location, out int OutNode);
function bool FindNodesInRadius(R_NavMesh NavMesh, Vector Origin, float Radius, out int OutNodes[32], out int OutNumNodes);

// FindNodeNeighbors
// Given a NavMesh node index, find all neighbors to that node
function bool FindNodeNeighbors2D(
	R_NavMesh NavMesh,
	int NodeIndex,
	float MaxProximalRadius,
	out R_NavNeighbor OutNeighbors[32],
	out int OutNumNeighbors);