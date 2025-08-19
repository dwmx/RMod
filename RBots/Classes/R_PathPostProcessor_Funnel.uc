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
    local Vector PortalLeft[32], PortalRight[32];
    local int PortalCount;
    local int i;

    local Vector Apex, Left, Right;
    local Vector NewLeft, NewRight;
	local Vector ReferenceVector;
    local int ApexIndex, LeftIndex, RightIndex;

    // No path, just fail
    if (PathIndexCount <= 0)
    {
        OutPathPointCount = 0;
        return false;
    }

    // Build portals (edges between consecutive triangles)
    PortalCount = 0;

    // First portal: start to itself (degenerate)
    PortalLeft[PortalCount]  = StartLocation;
    PortalRight[PortalCount] = StartLocation;
    PortalCount++;

    for (i = 0; i < PathIndexCount - 1; i++)
    {
        NavMesh.GetSharedEdgePointsUnchecked(
            InPathIndices[i], InPathIndices[i+1],
            PortalLeft[PortalCount], PortalRight[PortalCount]);
        PortalCount++;
    }

    // Final portal: end point to itself
    PortalLeft[PortalCount]  = EndLocation;
    PortalRight[PortalCount] = EndLocation;
    PortalCount++;

	// Funnel algo
	Apex = StartLocation;
	ApexIndex = 0;

	LeftIndex = 1;
	RightIndex = 1;

	Left = PortalLeft[LeftIndex];
	Right = PortalRight[RightIndex];

	OutPathPoints[0] = StartLocation;
	OutPathPointCount = 1;

	for(i = 2; i < PortalCount; ++i)
	{
		// Get reference vector for edge cross checking
		ReferenceVector = (Left - Apex) Cross (Right - Apex);

		// Check left
		NewLeft = PortalLeft[i];
		if(TriangleDot(ReferenceVector, Apex, Left, NewLeft) >= 0.0f)
		{
			if(Apex == Left || TriangleDot(ReferenceVector, Apex, Right, NewLeft) < 0.0f)
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
		if(TriangleDot(ReferenceVector, Apex, Right, NewRight) <= 0.0f)
		{
			if(Apex == Right || TriangleDot(ReferenceVector, Apex, Left, NewRight) > 0.0f)
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

function float TriangleDot(out Vector InReferenceVector, out Vector InA, out Vector InB, out Vector InC)
{
	local Vector Cross;

	Cross = (InB - InA) Cross (InC - InA);
	return Cross Dot InReferenceVector;
}