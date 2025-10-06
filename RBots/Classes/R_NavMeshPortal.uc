//==============================================================================
//	R_NavMeshPortal
//	A collection of edges separating two groups of polygons
//
//	'EdgeNavMeshIndex' refers to an edge as referenced within the NavMesh
//	'EdgePortalIndex' refers to an edge as referenced within this Portal
//==============================================================================
class R_NavMeshPortal extends R_NavObject abstract;

function InitializePortal(R_NavMesh NavMesh);
function FinalizePortal(R_NavMesh NavMesh);

function SetPortalIndex(int NewPortalIndex);
function int GetPortalIndex();

function SetAdjacentPolyGroupIndices(int PolyGroupIndexA, int PolyGroupIndexB);
function GetAdjacentPolyGroupIndices(out int OutPolyGroupIndexA, out int OutPolyGroupIndexB);
function bool IsPortalBetween(int PolyGroupIndexA, int PolyGroupIndexB);
function int GetOtherPolyGroupIndex(int PolyGroupIndex);

function int GetEdgeNavMeshIndex(int EdgePortalIndex);
function int GetEdgePortalIndex(int EdgeNavMeshIndex);
function AddEdgeUnique(int EdgeNavMeshIndex);
function int GetEdgeCount();

function int GetPolygonNavMeshIndex(int PolygonPortalIndex);
function int GetPolygonPortalIndex(int PolygonNavMeshIndex);
function AddPolygonUnique(int PolygonNavMeshIndex);
function int GetPolygonCount();
function bool ContainsPolygon(int PolygonNavMeshIndex);

function GetNeighborSet(out R_NavNeighborSet OutNeighborSet);