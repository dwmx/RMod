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