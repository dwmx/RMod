//==============================================================================
//  R_PathPostProcessor_Funnel
//  Applies a funnel filter to a path of NavMesh indices
//==============================================================================
class R_PathPostProcessor_Funnel extends R_PathPostProcessor;

function bool PostProcessPath(
    R_BotNavMesh NavMesh,
    Vector StartLocation, Vector EndLocation,
    out int InPathIndices[32], int PathIndexCount,
    out Vector OutPathPoints[32], out int OutPathPointCount)
{
    local Vector PortalLeft[32], PortalRight[32];
    local int PortalCount;
    local int i;

    local Vector Apex, Left, Right;
    local Vector NewLeft, NewRight;
    local int ApexIndex, LeftIndex, RightIndex;
    local Vector DirLeft, DirRight, DirNew;
    local float Cross;

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

    // -------------------------------
    // Funnel algorithm core
    // -------------------------------
    Apex      = StartLocation;
    ApexIndex = 0;
    Left      = PortalLeft[1];
    Right     = PortalRight[1];
    LeftIndex = 1;
    RightIndex= 1;

    OutPathPoints[0] = StartLocation;
    OutPathPointCount = 1;

    for (i = 2; i < PortalCount; i++)
    {
        NewLeft  = PortalLeft[i];
        NewRight = PortalRight[i];

        // Check if new left is "inside" funnel
        DirLeft = Left - Apex;
        DirRight= Right - Apex;
        DirNew  = NewLeft - Apex;

        Cross = Cross2D(DirLeft, DirNew, Apex);
        if (Cross >= 0.0) // NewLeft is left of current Left
        {
            // Tighten funnel
            Left = NewLeft;
            LeftIndex = i;

            // If funnel collapses, move apex to Right
            if (Cross2D(Right - Apex, Left - Apex, Apex) < 0.0)
            {
                Apex = Right;
                ApexIndex = RightIndex;
                OutPathPoints[OutPathPointCount++] = Apex;

                // Reset funnel
                Left = Apex;
                Right = Apex;
                LeftIndex = ApexIndex;
                RightIndex = ApexIndex;
                i = ApexIndex + 1;
                continue;
            }
        }

        // Check if new right is "inside" funnel
        DirNew = NewRight - Apex;
        Cross = Cross2D(DirRight, DirNew, Apex);
        if (Cross <= 0.0) // NewRight is right of current Right
        {
            // Tighten funnel
            Right = NewRight;
            RightIndex = i;

            // If funnel collapses, move apex to Left
            if (Cross2D(Right - Apex, Left - Apex, Apex) < 0.0)
            {
                Apex = Left;
                ApexIndex = LeftIndex;
                OutPathPoints[OutPathPointCount++] = Apex;

                // Reset funnel
                Left = Apex;
                Right = Apex;
                LeftIndex = ApexIndex;
                RightIndex = ApexIndex;
                i = ApexIndex + 1;
                continue;
            }
        }
    }

    // Add the end point
    OutPathPoints[OutPathPointCount++] = EndLocation;

    return true;
}

// -----------------------------------------------------------
// 2D cross helper (uses triangle normal for projection)
// -----------------------------------------------------------
static final function float Cross2D(Vector A, Vector B, Vector Apex)
{
    // Project into a stable plane — here we ignore Z
    // Assumes left/right already corrected in GetSharedEdgeUnchecked
    return A.X * B.Y - A.Y * B.X;
}
