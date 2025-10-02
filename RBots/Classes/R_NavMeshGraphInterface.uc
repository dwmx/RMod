//==============================================================================
//	R_NavMeshGraphInterface
//	NavGraphInterface base class for any object implementing graph features
//	on parts of the NavMesh
//==============================================================================
class R_NavMeshGraphInterface extends R_NavGraphInterface abstract;

var private R_NavMesh OwningNavMesh;

final function SetNavMesh(R_NavMesh NewOwningNavMesh)
{
	OwningNavMesh = NewOwningNavMesh;
}

final function R_NavMesh GetNavMesh()
{
	return OwningNavMesh;
}