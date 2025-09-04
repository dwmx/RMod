class R_RBotsDebug_NavObjectTranslator extends R_NavObject abstract;

static function GetAdjacentNeighbors(
	R_NavMesh NavMesh,
	int NodeIndex,
	out int OutNeighborIndices[3],
	out float OutNeighborCosts[3],
	out int OutNumNeighbors)
{
	local R_NavNeighborSet NeighborSet;
	local int i;

	OutNumNeighbors = 0;
	NavMesh.GetTriangleNeighborSetUnchecked(NodeIndex, NeighborSet);
	for(i = 0; i < NeighborSet.NumNeighbors; ++i)
	{
		if(OutNumNeighbors >= ArrayCount(OutNeighborIndices))
		{
			break;
		}

		if(NeighborSet.Neighbors[i].NeighborType == NeighborType_Adjacent)
		{
			OutNeighborIndices[OutNumNeighbors] = NeighborSet.Neighbors[i].NeighborIndex;
			OutNeighborCosts[OutNumNeighbors] = NeighborSet.Neighbors[i].NeighborCost;
			++OutNumNeighbors;
		}
	}
}

static function GetProximalNeighbors(
	R_NavMesh NavMesh,
	int NodeIndex,
	out int OutNeighborIndices[32],
	out float OutNeighborCosts[32],
	out int OutNumNeighbors)
{
	local R_NavNeighborSet NeighborSet;
	local int i;

	OutNumNeighbors = 0;
	NavMesh.GetTriangleNeighborSetUnchecked(NodeIndex, NeighborSet);
	for(i = 0; i < NeighborSet.NumNeighbors; ++i)
	{
		if(OutNumNeighbors >= ArrayCount(OutNeighborIndices))
		{
			break;
		}

		if(NeighborSet.Neighbors[i].NeighborType == NeighborType_Proximal)
		{
			OutNeighborIndices[OutNumNeighbors] = NeighborSet.Neighbors[i].NeighborIndex;
			OutNeighborCosts[OutNumNeighbors] = NeighborSet.Neighbors[i].NeighborCost;
			++OutNumNeighbors;
		}
	}
}