//==============================================================================
//	R_NavMeshPortal
//	A collection of edges separating two groups of polygons
//
//	'EdgeNavMeshIndex' refers to an edge as referenced within the NavMesh
//	'EdgePortalIndex' refers to an edge as referenced within this Portal
//==============================================================================
class R_NavMeshPortal extends R_NavObject abstract;

function InitializePortal();

function SetAdjacentPolyGroupIndices(int PolyGroupIndexA, int PolyGroupIndexB);

function int GetEdgeNavMeshIndex(int EdgePortalIndex);
function int GetEdgePortalIndex(int EdgeNavMeshIndex);

function PushEdge(int EdgeNavMeshIndex);
function int GetEdgeCount();