//==============================================================================
//	R_NavMeshActorTracker
//	Tracks Actors and maintains navmesh related information for them
//==============================================================================
class R_NavMeshActorTracker extends R_NavObject abstract;

function SetNavMesh(R_NavMesh NewNavMesh);
function TrackActor(Actor NewActor);
function Update();

function GetActorsByPolyGroupIndex(int PolyGroupIndex, out Actor OutActors[32], out int OutNumActors);