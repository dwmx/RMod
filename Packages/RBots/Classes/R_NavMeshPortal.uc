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

function Vector GetPortalLocation();

function SetAdjacentPolyGroupIndices(int PolyGroupIndexA, int PolyGroupIndexB);
function GetAdjacentPolyGroupIndices(out int OutPolyGroupIndexA, out int OutPolyGroupIndexB);
function bool IsPortalBetween(int PolyGroupIndexA, int PolyGroupIndexB);
function int GetOtherPolyGroupIndex(int PolyGroupIndex);

function int GetEdgeNavMeshIndex(int EdgePortalIndex);
function int GetEdgePortalIndex(int EdgeNavMeshIndex);
function AddEdgeUnique(int EdgeNavMeshIndex);
function int GetEdgeCount();

function int GetPolygonNavMeshIndexForPolyGroup(int PolyGroupNavMeshIndex, int PolygonPortalIndex);
function int GetPolygonPortalIndexForPolyGroup(int PolyGroupNavMeshIndex, int PolygonPortalIndex);
function AddPolygonUniqueForPolyGroupA(int PolygonNavMeshIndex);
function AddPolygonUniqueForPolyGroupB(int PolygonNavMeshIndex);
function int GetPolygonCountForPolyGroupA();
function int GetPolygonCountForPolyGroupB();
function int GetPolygonCountForPolyGroup(int PolyGroupNavMeshIndex);
function bool ContainsPolygon(int PolygonNavMeshIndex);

function SetCostToPolyGroup(int PolyGroupIndex, float Cost);
function float GetCostToPolyGroup(int PolyGroupIndex);

function GetNeighborSet(out R_NavNeighborSet OutNeighborSet);