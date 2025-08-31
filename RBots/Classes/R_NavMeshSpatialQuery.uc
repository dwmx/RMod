//==============================================================================
//	R_NavMeshSpatialQuery
//	Interface for performing spatial and proximity look-ups on NavMesh
//==============================================================================
class R_NavMeshSpatialQuery extends Object abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavSpatialQuery';

const NavLib = Class'RBots.R_NavLibrary';

function InitNavMeshSpatialQuery(R_NavMesh NavMesh);

function bool FindContainingNode(R_NavMesh NavMesh, Vector Location, out int OutNode);
function bool FindNodesInRadius(R_NavMesh NavMesh, Vector Origin, float Radius, out int OutNodes[32], out int OutNumNodes);