//==============================================================================
//  R_PathPostProcessor_Funnel
//  Applies a funnel filter to a path of NavMesh indices
//==============================================================================
class R_PathPostProcessor_Funnel extends R_PathPostProcessor;

function bool PostProcessPath(
    R_BotNavMesh NavMesh,
    Vector StartLocation, Vector EndLocation,
    out int InPathIndices[32], int PathIndexCount,
    out Vector OutPathPoints[32], out int OutPathPointCount,
	optional R_PathFindData OptionalPathFindData)
{
	local Vector NodeNormal, NodeCenter;
    local Vector PortalLeft[32], PortalRight[32];
    local int PortalCount;
    local int i;

    local Vector Apex, Left, Right;
    local Vector NewLeft, NewRight;
	local Vector ReferenceVector;
    local int ApexIndex, LeftIndex, RightIndex;
	local float Dot;

    // No path, just fail
    if (PathIndexCount <= 0)
    {
        OutPathPointCount = 0;
        return false;
    }

	// Project start and end locations onto their containing nodes
	NavMesh.GetTriangleNormalAndCenterUnchecked(InPathIndices[0], NodeNormal, NodeCenter);
	StartLocation = StartLocation - (NodeNormal * ((StartLocation - NodeCenter) Dot NodeNormal));
	NavMesh.GetTriangleNormalAndCenterUnchecked(InPathIndices[PathIndexCount - 1], NodeNormal, NodeCenter);
	EndLocation = EndLocation - (NodeNormal * ((EndLocation - NodeCenter) Dot NodeNormal));

	GetPortals(NavMesh, InPathIndices, PathIndexCount, StartLocation, EndLocation, PortalLeft, PortalRight, PortalCount);

	OutPathPoints[0] = StartLocation;
	OutPathPointCount = 1;

	// Init funnel
	Apex = StartLocation;
	ApexIndex = 0;

	LeftIndex = 1;
	RightIndex = 1;

	Left = PortalLeft[LeftIndex];
	Right = PortalRight[RightIndex];

	for(i = 2; i < PortalCount; ++i)
	{
		// Get reference vector for edge cross checking
		ReferenceVector = Normal((Left - Apex) Cross (Right - Apex));

		// Check left
		NewLeft = PortalLeft[i];
		if(TriangleDot(ReferenceVector, Apex, Left, NewLeft) >= 0.0f)
		{
			Dot = TriangleDot(ReferenceVector, Apex, NewLeft, Right);
			if(Apex == Left || Dot > 0.0f)
			{
				Left = NewLeft;
				LeftIndex = i;
			}
			else
			{
				OutPathPoints[OutPathPointCount] = Right;
				++OutPathPointCount;

				Apex = Right;
				Left = Apex;
				ApexIndex = RightIndex;
				LeftIndex = ApexIndex;
				i = ApexIndex;
				continue;
			}
		}

		// Check right
		NewRight = PortalRight[i];
		if(TriangleDot(ReferenceVector, Apex, NewRight, Right) >= 0.0f)
		{
			Dot = TriangleDot(ReferenceVector, Apex, Left, NewRight);
			if(Apex == Right || Dot > 0.0f)
			{
				Right = NewRight;
				RightIndex = i;
			}
			else
			{
				OutPathPoints[OutPathPointCount] = Left;
				++OutPathPointCount;

				Apex = Left;
				Right = Apex;
				ApexIndex = LeftIndex;
				RightIndex = ApexIndex;
				i = ApexIndex;
				continue;
			}
		}
	}

	OutPathPoints[OutPathPointCount] = EndLocation;
	++OutPathPointCount;

	// Separate the path from the boundaries (push away from walls, ledges, etc)
	BoundarySeparation(OutPathPoints, OutPathPointCount, PortalLeft, PortalRight, PortalCount, 32.0f, OptionalPathFindData);

	// If a PathFindData object was provided, add data
	if(OptionalPathFindData != None)
	{
		// Push portals
		OptionalPathFindData.ClearPortals();
		for(i = 0; i < PortalCount; ++i)
		{
			OptionalPathFindData.PushPortal(PortalLeft[i], PortalRight[i]);
		}
	}

    return true;
}

function GetPortals(
	R_BotNavMesh NavMesh,
	out int InPathIndices[32], int PathIndexCount,
	out Vector InPathStartLocation, out Vector InPathEndLocation,
	out Vector OutPortalsLeft[32], out Vector OutPortalsRight[32], out int OutPortalsCount)
{
	local int i;

	OutPortalsCount = 0;

	// First portal is start location
	OutPortalsLeft[OutPortalsCount] = InPathStartLocation;
	OutPortalsRight[OutPortalsCount] = InPathStartLocation;
	++OutPortalsCount;

	// Add edges between all nodes
	for(i = 0; i < PathIndexCount - 1; ++i)
	{
		NavMesh.GetSharedEdgePointsUnchecked(InPathIndices[i], InPathIndices[i+1], OutPortalsLeft[OutPortalsCount], OutPortalsRight[OutPortalsCount]);
		++OutPortalsCount;
	}

	// Last portal is end location
	OutPortalsLeft[OutPortalsCount] = InPathEndLocation;
	OutPortalsRight[OutPortalsCount] = InPathEndLocation;
	++OutPortalsCount;
}

function float TriangleDot(out Vector InReferenceVector, out Vector InA, out Vector InB, out Vector InC)
{
	local Vector TempA, TempB, TempC, TempRef;
	local Vector Cross;

	TempA = Vect(1,1,0) * InA;
	TempB = Vect(1,1,0) * InB;
	TempC = Vect(1,1,0) * InC;
	TempRef = Vect(0,0,1) * InReferenceVector;

	Cross = (TempB - TempA) Cross (TempC - TempA);
	return Cross Dot TempRef;
}

// Given an array of path points and left/right boundaries, this attempts to push the path away from the boundary by the
// specified amount
// Likely will result in a path with more points
function BoundarySeparation(
	out Vector InOutPathPoints[32], out int InOutNumPathPoints,
	out Vector InLeftBoundary[32], out Vector InRightBoundary[32], int NumBoundaryPoints,
	float SeparationDistance,
	optional R_PathFindData OptionalPathFindData)
{
	local Vector UniqueLeftBoundary[32];
	local Vector UniqueRightBoundary[32];
	local Vector LeftBoundaryPushDir[32];
	local Vector RightBoundaryPushDir[32];
	local Vector V0, V1, V2; // Vectors for projecting onto Z=0
	local int NumUniqueLeftBoundary, NumUniqueRightBoundary;
	local int i, j;

	CollapseDuplicateVectors(InLeftBoundary, NumBoundaryPoints, UniqueLeftBoundary, NumUniqueLeftBoundary);
	CollapseDuplicateVectors(InRightBoundary, NumBoundaryPoints, UniqueRightBoundary, NumUniqueRightBoundary);

	// Calc all left boundary push directions
	for(i = 1; i < NumUniqueLeftBoundary - 1; ++i)
	{
		V0 = Vect(1,1,0) * UniqueLeftBoundary[i-1];
		V1 = Vect(1,1,0) * UniqueLeftBoundary[i];
		V2 = Vect(1,1,0) * UniqueLeftBoundary[i+1];
		CalcPushDirection(V0, V1, V2, LeftBoundaryPushDir[i]);
	}

	// Calc all right boundary push directions
	for(i = 1; i < NumUniqueRightBoundary - 1; ++i)
	{
		V0 = Vect(1,1,0) * UniqueRightBoundary[i-1];
		V1 = Vect(1,1,0) * UniqueRightBoundary[i];
		V2 = Vect(1,1,0) * UniqueRightBoundary[i+1];
		CalcPushDirection(V0, V1, V2, RightBoundaryPushDir[i]);
	}

	// Add boundary push data if requested
	if(OptionalPathFindData != None)
	{
		OptionalPathFindData.ClearBoundaries();
		for(i = 0; i < NumUniqueLeftBoundary; ++i)
		{
			OptionalPathFindData.PushBoundaryLeft(UniqueLeftBoundary[i], LeftBoundaryPushDir[i]);
		}

		for(i = 0; i < NumUniqueRightBoundary; ++i)
		{
			OptionalPathFindData.PushBoundaryRight(UniqueRightBoundary[i], RightBoundaryPushDir[i]);
		}
	}

	//// Push away from the left boundary
	//for(i = 1; i < NumUniqueLeftBoundary - 1; ++i)
	//{
	//	PerpEdge = Normal(InLeftBoundary[i+1] - InLeftBoundary[i-1]);
	//	PushEdge = InLeftBoundary[i] - InLeftBoundary[i-1];
	//	PerpDotPush = PerpEdge Dot PushEdge;
	//	if(PerpDotPush >= 0.95)
	//	{
	//		// Approximately colinear, ignore
	//		continue;
	//	}
	//	PushEdge = Normal(PushEdge - (PerpEdge * PerpDotPush));
//
	//	// Find the two path points on opposite sides of the push edg
	//	for(j = 0; j < InOutNumPathPoints - 1; ++j)
	//	{
	//		if(InOutPathPoints[j] == InLeftBoundary[i])
	//		{	// Special case -- The path point is directly on the boundary vertex
//
	//		}
	//		else if(InOutPathPoints[j] Dot PerpEdge <= 0.0f && InOutPathPoints[j+1] >= 0.0f)
	//		{	// j is left, j+1 is right of push direction
	//		}
	//	}
	//}
}

// Given three sequential boundary vertices, calculates a push direction
function CalcPushDirection(out Vector InB0, out Vector InB1, out Vector InB2, out Vector OutPushDir)
{
	local Vector PerpDir;
	local Vector PushVector;
	local float PerpDotPush;

	PerpDir = Normal(InB2 - InB0);
	PushVector = InB1 - InB0;
	
	PushVector = PushVector - (PerpDir * (PushVector Dot PerpDir));
	
	OutPushDir = Normal(PushVector);
}

function CollapseDuplicateVectors(out Vector InVectorArray[32], int Num, out Vector OutNewVectorArray[32], out int OutNewNum)
{
	local int i;

	OutNewNum = 0;
	Num = Clamp(Num, 0, 32);
	if(Num == 0)
	{
		OutNewNum = 0;
		return;
	}

	OutNewVectorArray[0] = InVectorArray[0];
	++OutNewNum;

	i = 1;
	while(i < Num)
	{
		if(InVectorArray[i] != OutNewVectorArray[OutNewNum-1])
		{
			OutNewVectorArray[OutNewNum] = InVectorArray[i];
			++OutNewNum;
		}
		++i;
	}
}