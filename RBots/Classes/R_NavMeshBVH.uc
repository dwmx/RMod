//==============================================================================
//	R_NavMeshBVH
//	Bounding Volume Hierarchy which works with R_NavMesh
//	NavMesh relies on BVH for fast node lookups based on proximity
//	This is necessary for searching nearby nodes that are not directly adjacent,
//	but can still be part of a path (i.e. jumping, ledge grabbing, dodging)
//==============================================================================
class R_NavMeshBVH extends Object abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavMeshBVH';

const NavMeshLib = Class'RBots.R_NavMeshLibrary';

// Clear this BVH
function Clear();

// Owning NavMesh
function SetNavMesh(R_NavMesh NewNavMesh);

// Set the bounds for this BVH
function SetBounds(Vector NewBoundsMin, Vector NewBoundsMax);
function GetBounds(out Vector OutBoundsMin, out Vector OutBoundsMax);

// Insert a triangle with associated index
function InsertTriangle(int Index, out Vector InVLoc[3]);

// Given a world location, finds the index of the triangle containing that location
// Returns false if no location found
function bool FindContainingTriangle(out Vector InWorldLocation, out int OutIndex);

// Given a world location and a radius, finds all triangles that are touched by that radius
function FindTrianglesInRadius(float Radius, out Vector InWorldLocation, out int OutIndices[64], out int OutNumIndices);

// Returns whether or not this BVH is valid -- error reporting allows this to return false
function bool IsBVHValid();