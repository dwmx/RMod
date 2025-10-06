//==============================================================================
//	R_NavMeshPolyGroup
//
//	Important note on function arguments:
//
//	'TriangleNavMeshIndex' refers to a triangle as referenced within the NavMesh
//	'TrianglePolyGroupIndex' refers to a triangle as referenced inside this group
//==============================================================================
class R_NavMeshPolyGroup extends R_NavObject abstract;

function SetPolyGroupName(Name NewPolyGroupName);
function Name GetPolyGroupName();

function SetPolyGroupIndex(int NewPolyGroupIndex);
function int GetPolyGroupIndex();

function InitializePolyGroup(R_NavMesh NavMesh);
function FinalizePolyGroup(R_NavMesh NavMesh);

function ClearTriangles();
function ClearPortals();

function int GetTriangleIndexCount();
function int GetTriangleNavMeshIndex(int TrianglePolyGroupIndex);
function int GetTrianglePolyGroupIndex(int TriangleNavMeshIndex);
function PushTriangleIndex(int TriangleNavMeshIndex);

function int GetPortalCount();
function int GetPortalNavMeshIndex(int PortalPolyGroupIndex);
function int GetNumEdgesInPortal(int PortalIndex);
function int GetPortalEdge(int PortalIndex, int EdgeIndex);

// Given a PortalIndex into this PolyGroup, returns the neighboring PolyGroup
// accessible through that Portal
// Returns InvalidIndex if PortalIndex is invalid
function int GetNeighborPolyGroupIndexForPortalIndex(int PortalIndex);

// Given a neighboring PolyGroup index, returns the Portal index which
// interfaces with that neighboring PolyGroup
// Returns InvalidIndex if no such Portal exists
function int GetPortalIndexForNeighborPolyGroupIndex(int NeighborPolyGroupIndex);

function bool DoesPortalExistToDest(int DestPolyGroupIndex);
function BuildPortals(R_NavMesh NavMesh);

function float GetPortalCostFromIndex(int TrianglePolyGroupIndex, int PortalIndex);

// Given a TriangleNavMeshIndex, returns the distance from that triangle to the portal
// between this PolyGroup and the specified PolyGroup
// If no portal exists, returns false and 0.0
function bool GetCostFromTriangleToNeighborPolyGroup(
	int TriangleNavMeshIndex,
	int PolyGroupIndex,
	out float OutCost);

function GetNeighborSet(out R_NavNeighborSet OutNeighborSet);

function AddPortalUnique(int PortalNavMeshIndex);