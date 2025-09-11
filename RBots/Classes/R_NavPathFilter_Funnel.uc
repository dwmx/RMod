//==============================================================================
//  R_NavPathFilter_Funnel
//  Applies a funnel filter to a path of NavMesh indices
//==============================================================================
class R_NavPathFilter_Funnel extends R_NavPathFilter;

// This is just a temp constant until something better is figured out
const MAX_POINT_ARRAY_SIZE = 32;
const BOUNDARY_SEPARATION_DIST = 48.0;	// The distance paths will try to stay from boundaries

function bool PostProcessPath(
	R_NavMesh NavMesh,
	Vector StartLocation, Vector EndLocation,
	R_NavContext NavContext,
	optional R_NavContextObserver OptionalNavPathObserver)
{
	local Vector NodeNormal, NodeCenter;
    //local Vector PortalLeft[32], PortalRight[32];

	local Vector BoundaryLeft[32], BoundaryRight[32];
	local int NumBoundaryLeftPoints, NumBoundaryRightPoints;
	local int PortalLeft[32], PortalRight[32];
    local int NumPortalIndices;
	local Vector V0, V1, V2, PushDir; // For push direction
	local Vector NewPathPoint;


    local int i;

    local Vector Apex, Left, Right;
    local Vector NewLeft, NewRight;
	local Vector ReferenceVector;
    local int ApexIndex, LeftIndex, RightIndex;
	local float Dot;
	local int PathIndexCount;
	local int IndexA, IndexB;

	PathIndexCount = NavContext.GetNumPathNodeIndices();

    // No path, just fail
    if (PathIndexCount <= 0)
    {
        //OutPathPointCount = 0;
        return false;
    }

	// Project start and end locations onto their containing nodes
	NavContext.GetPathNodeIndex(0, IndexA);
	NavContext.GetPathNodeIndex(NavContext.GetNumPathNodeIndices() - 1, IndexB);
	NavMesh.GetTriangleNormalAndCenterUnchecked(IndexA, NodeNormal, NodeCenter);
	StartLocation = StartLocation - (NodeNormal * ((StartLocation - NodeCenter) Dot NodeNormal));
	NavMesh.GetTriangleNormalAndCenterUnchecked(IndexB, NodeNormal, NodeCenter);
	EndLocation = EndLocation - (NodeNormal * ((EndLocation - NodeCenter) Dot NodeNormal));

	//GetPortals(NavMesh, InPathIndices, PathIndexCount, StartLocation, EndLocation, PortalLeft, PortalRight, PortalCount);
	// Get boundary and portals
	GetPortals(
		NavMesh,
		//InPathIndices, PathIndexCount, 
		NavContext,
		StartLocation, EndLocation,
		BoundaryLeft, NumBoundaryLeftPoints,
		BoundaryRight, NumBoundaryRightPoints,
		PortalLeft, PortalRight, NumPortalIndices);

	//OutPathPoints[0] = StartLocation;
	//OutPathPointCount = 1;
	NavContext.PushPathLocation(StartLocation);

	// Init funnel
	Apex = StartLocation;
	ApexIndex = 0;

	LeftIndex = 1;
	RightIndex = 1;

	Left = BoundaryLeft[PortalLeft[LeftIndex]];
	Right = BoundaryRight[PortalRight[RightIndex]];

	for(i = 2; i < NumPortalIndices; ++i)
	{
		// Get reference vector for edge cross checking
		ReferenceVector = Normal((Left - Apex) Cross (Right - Apex));

		// Check left
		NewLeft = BoundaryLeft[PortalLeft[i]];
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
				NewPathPoint = Right;

				if(RightIndex >= 2 && RightIndex < NumPortalIndices - 1)
				{
					V0 = BoundaryRight[PortalRight[RightIndex]-1];
					V1 = BoundaryRight[PortalRight[RightIndex]];
					V2 = BoundaryRight[PortalRight[RightIndex]+1];
					CalcPushDirection2D(V0, V1, V2, PushDir);
					BoundarySeparatePathPoint2D(NewPathPoint, V1, PushDir, BOUNDARY_SEPARATION_DIST);
				}
				
				//OutPathPoints[OutPathPointCount] = NewPathPoint;
				//++OutPathPointCount;
				NavContext.PushPathLocation(NewPathPoint);

				Apex = Right;
				Left = Apex;
				ApexIndex = RightIndex;
				LeftIndex = ApexIndex;
				i = ApexIndex;
				continue;
			}
		}

		// Check right
		NewRight = BoundaryRight[PortalRight[i]];
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
				NewPathPoint = Left;

				if(LeftIndex >= 2 && LeftIndex < NumPortalIndices - 1)
				{
					V0 = BoundaryLeft[PortalLeft[LeftIndex]-1];
					V1 = BoundaryLeft[PortalLeft[LeftIndex]];
					V2 = BoundaryLeft[PortalLeft[LeftIndex]+1];
					CalcPushDirection2D(V0, V1, V2, PushDir);
					BoundarySeparatePathPoint2D(NewPathPoint, V1, PushDir, BOUNDARY_SEPARATION_DIST);
				}
				
				//OutPathPoints[OutPathPointCount] = NewPathPoint;
				//++OutPathPointCount;
				NavContext.PushPathLocation(NewPathPoint);

				Apex = Left;
				Right = Apex;
				ApexIndex = LeftIndex;
				RightIndex = ApexIndex;
				i = ApexIndex;
				continue;
			}
		}
	}

	//OutPathPoints[OutPathPointCount] = EndLocation;
	//++OutPathPointCount;
	NavContext.PushPathLocation(EndLocation);

	// If a NavPathObserver object was provided, add data
	if(OptionalNavPathObserver != None)
	{
		// Push boundaries, portals and push directions
		OptionalNavPathObserver.ClearPortals();
		for(i = 0; i < NumPortalIndices; ++i)
		{
			OptionalNavPathObserver.PushPortal(BoundaryLeft[PortalLeft[i]], BoundaryRight[PortalRight[i]]);
		}

		// Push boundaries
		OptionalNavPathObserver.ClearBoundaries();
		if(NumBoundaryLeftPoints >= 3)
		{
			for(i = 1; i < NumBoundaryLeftPoints - 1; ++i)
			{
				V0 = BoundaryLeft[PortalLeft[i]-1];
				V1 = BoundaryLeft[PortalLeft[i]];
				V2 = BoundaryLeft[PortalLeft[i]+1];
				CalcPushDirection2D(V0, V1, V2, PushDir);
				OptionalNavPathObserver.PushBoundaryLeft(V1, PushDir);
			}
		}
		if(NumBoundaryRightPoints >= 3)
		{
			for(i = 1; i < NumBoundaryRightPoints - 1; ++i)
			{
				V0 = BoundaryRight[PortalRight[i]-1];
				V1 = BoundaryRight[PortalRight[i]];
				V2 = BoundaryRight[PortalRight[i]+1];
				CalcPushDirection2D(V0, V1, V2, PushDir);
				OptionalNavPathObserver.PushBoundaryRight(V1, PushDir);
			}
		}
	}

    return true;
}

function BoundarySeparatePathPoint2D(out Vector InOutPathPoint, out Vector InBoundaryPoint, out Vector InPushDir, float MinSeparationDistance)
{
	local Vector Delta;
	local Vector BoundaryPoint2D;

	Delta = Vect(1,1,0) * InOutPathPoint - Vect(1,1,0) * InBoundaryPoint;
	if(VSize(Delta) >= MinSeparationDistance)
	{
		return;
	}

	BoundaryPoint2D = Vect(1,1,0) * InBoundaryPoint;
	InOutPathPoint = BoundaryPoint2D + (InPushDir * MinSeparationDistance) + Vect(0,0,1) * InOutPathPoint;
}

// GetPortals
// Returns arrays of left and right boundary points, and left and right portal
// arrays as indices into the boundary points
function GetPortals(
	R_Navmesh NavMesh,
	//out int InPathIndices[32], int NumPathIndices,
	R_NavContext NavContext,
	out Vector InPathStartLocation, out Vector InPathEndLocation,
	out Vector OutBoundaryLeft[32], out int OutNumBoundaryLeft,
	out Vector OutBoundaryRight[32], out int OutNumBoundaryRight,
	out int OutPortalLeft[32], out int OutPortalRight[32], out int OutNumPortals)
{
	local Vector Left, Right;
	local int i;
	local int NumPathIndices;
	local int IndexA, IndexB;

	NumPathIndices = NavContext.GetNumPathNodeIndices();

	OutNumBoundaryLeft = 0;
	OutNumBoundaryRight = 0;
	OutNumPortals = 0;

	if(NumPathIndices == 0 || NavMesh == None)
	{
		return;
	}

	// First portal is start location
	InsertPortalPoint(InPathStartLocation, OutBoundaryLeft, OutNumBoundaryLeft, OutPortalLeft, OutNumPortals);
	InsertPortalPoint(InPathStartLocation, OutBoundaryRight, OutNumBoundaryRight, OutPortalRight, OutNumPortals);

	// Insert each shared edge along the corridor
	for(i = 0; i < NumPathIndices - 1; ++i)
	{
		NavContext.GetPathNodeIndex(i, IndexA);
		NavContext.GetPathNodeIndex(i+1, IndexB);
		NavMesh.GetTriangleSharedEdgeLocationsUnchecked(IndexA, IndexB, Left, Right);

		InsertPortalPoint(Left, OutBoundaryLeft, OutNumBoundaryLeft, OutPortalLeft, OutNumPortals);
		InsertPortalPoint(Right, OutBoundaryRight, OutNumBoundaryRight, OutPortalRight, OutNumPortals);
		++OutNumPortals;
	}

	// Last portal is end location
	InsertPortalPoint(InPathEndLocation, OutBoundaryLeft, OutNumBoundaryLeft, OutPortalLeft, OutNumPortals);
	InsertPortalPoint(InPathEndLocation, OutBoundaryRight, OutNumBoundaryRight, OutPortalRight, OutNumPortals);
	++OutNumPortals;
}

// InsertPortalPoint
// Given an array of boundary points, and an array of portal indices in that boundary,
// adds a point (InPortalPoint) into that boundary if it's not already there, and
// and inserts a portal index to that point at the specified index
//
// If insertion fails, output arrays are unmodified and function returns false
function bool InsertPortalPoint(
	out Vector InPortalPoint,
	out Vector InOutBoundaryPoints[32], out int InOutNumBoundaryPoints,
	out int InOutPortalIndices[32], int PortalIndex)
{
	local int i;

	if(PortalIndex >= MAX_POINT_ARRAY_SIZE)
	{	// Too many portal indices
		return false;
	}

	for(i = 0; i < InOutNumBoundaryPoints; ++i)
	{
		// TODO: May want to use some epsilon value here instead
		if(InOutBoundaryPoints[i] == InPortalPoint)
		{
			break;
		}
	}

	if(i >= MAX_POINT_ARRAY_SIZE)
	{	// Too many points
		return false;
	}

	if(i == InOutNumBoundaryPoints)
	{	// New boundary point
		InOutBoundaryPoints[InOutNumBoundaryPoints] = InPortalPoint;
		++InOutNumBoundaryPoints;
	}

	InOutPortalIndices[PortalIndex] = i;
}

/*	ORIGINAL
function bool PostProcessPath(
    R_BotNavMesh NavMesh,
    Vector StartLocation, Vector EndLocation,
    out int InPathIndices[32], int PathIndexCount,
    out Vector OutPathPoints[32], out int OutPathPointCount,
	optional R_NavContextObserver OptionalNavPathObserver)
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
	BoundarySeparation(OutPathPoints, OutPathPointCount, PortalLeft, PortalRight, PortalCount, 32.0f, OptionalNavPathObserver);

	// If a NavPathObserver object was provided, add data
	if(OptionalNavPathObserver != None)
	{
		// Push portals
		OptionalNavPathObserver.ClearPortals();
		for(i = 0; i < PortalCount; ++i)
		{
			OptionalNavPathObserver.PushPortal(PortalLeft[i], PortalRight[i]);
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
*/

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

// Given three sequential boundary vertices, calculates a push direction
function CalcPushDirection2D(out Vector InB0, out Vector InB1, out Vector InB2, out Vector OutPushDir)
{
	local Vector PerpDir;
	local Vector PushVector;
	local float PerpDotPush;

	PerpDir = Normal(Vect(1,1,0) * InB2 - Vect(1,1,0) * InB0);
	PushVector = Vect(1,1,0) * InB1 - Vect(1,1,0) * InB0;
	
	PushVector = PushVector - (PerpDir * (PushVector Dot PerpDir));
	
	OutPushDir = Normal(PushVector);
}

function CalcPushedPathPoint(out Vector InBoundaryVertex, out Vector InPushDirection, float PushDistance, out Vector InPathPoints[32], int NumPathPoints, out Vector OutNewPathPoint)
{
	local Vector PathDelta, BoundaryDelta;
	local Vector E0;
	local float DP;
	local Vector IntersectionPoint;
	local int i;

	if(NumPathPoints <= 2)
	{
		return;
	}

	for(i = 0; i < NumPathPoints - 1; ++i)
	{
		if(InBoundaryVertex == InPathPoints[i])
		{
			IntersectionPoint = InBoundaryVertex;
			break;
		}

		PathDelta = Vect(1,1,0) * InPathPoints[i+1] - Vect(1,1,0) * InPathPoints[i];
		BoundaryDelta = Vect(1,1,0) * InPathPoints[i+1] - Vect(1,1,0) * InBoundaryVertex;
		if(PathDelta Dot BoundaryDelta > 0.0)
		{
			E0 = Vect(1,1,0) * InBoundaryVertex - Vect(1,1,0) * InPathPoints[i];
			PathDelta = Normal(PathDelta);
			E0 = Vect(1,1,0) * InPathPoints[i] + (PathDelta * (PathDelta Dot E0));
			break;
		}
	}

	E0 = Vect(1,1,0) * IntersectionPoint - Vect(1,1,0) * InBoundaryVertex;
	if(VSize(E0) >= PushDistance)
	{
		OutNewPathPoint = E0;
		return;
	}
	else
	{
		OutNewPathPoint = InBoundaryVertex + Normal(InPushDirection) * PushDistance;
		return;
	}
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