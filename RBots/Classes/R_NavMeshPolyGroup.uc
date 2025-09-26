//==============================================================================
//	R_NavMeshPolyGroup
//==============================================================================
class R_NavMeshPolyGroup extends R_NavObject abstract;

function SetPolyGroupName(Name NewPolyGroupName);
function Name GetPolyGroupName();

function SetPolyGroupIndex(int NewPolyGroupIndex);

function ClearTriangles();
function ClearPortals();

function int GetTriangleIndexCount();
function int GetTriangleIndex(int Index);
function PushTriangleIndex(int TriangleIndex);

function int GetPortalCount();
function bool DoesPortalExistToDest(int DestPolyGroupIndex);
function BuildPortals(R_NavMesh NavMesh);

function float GetPortalCostFromIndex(int Index, int PortalIndex);