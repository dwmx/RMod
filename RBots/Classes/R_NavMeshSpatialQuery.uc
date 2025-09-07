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

// FindBorderEdgesInRadius


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

// FindRelevantBorderEdgesInRadius2D
// Given a location, finds all directly connected border edges with orientations
// pointing toward that location
//
// i.e. For a given location within some node in a NavMesh, this gives you the borders
// that are relevant to navigation at that location
function bool FindRelevantBorderEdgesInRadius2D(
	R_NavMesh NavMesh,
	Vector Location,
	float Radius,
	out int OutEdgeIndices[32],
	out float OutEdgeDistances[32],
	out int OutNumEdges);