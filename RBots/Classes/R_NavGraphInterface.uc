//==============================================================================
//	R_NavGraphInterface
//	A Nav object which may have path finding performed on it via NavPathFinder
//	Any object that implements these functions may be passed through the
//	NavPathFinder.FindPath --> NavPathFilter.FilterPath process
//==============================================================================
class R_NavGraphInterface extends R_NavObject abstract;

function int GetNodeCount();
function GetNeighborSet(int NodeIndex, out R_NavNeighborSet OutNeighborSet);