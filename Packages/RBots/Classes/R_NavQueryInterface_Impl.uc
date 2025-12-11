//==============================================================================
//	R_NavQueryInterface_Impl
//	Implementation of NavQueryInterface class
//==============================================================================
class R_NavQueryInterface_Impl extends R_NavQueryInterface;

const Utilities = Class'RBots.R_BotUtilities';
const NavLib = Class'RBots.R_NavLibrary';
const LogCategory = 'NavQueryInterface';

// Cached references
var private R_DynamicMapData CachedMapData;
var private R_NavMesh CachedNavMesh;

const NavPathFinderClass = Class'RBots.R_NavPathFinder_Dijkstras';
const NavPathFilterClass = Class'RBots.R_NavPathFilter_Funnel';

var private R_NavPathFinder NavPathFinder;
var private R_NavPathFilter NavPathFilter;

//------------------------------------------------------------------------------

function Initialize()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{
		LogString = "Failed to initialize subobjects -- Invalid RBotsServerActor reference";
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
	}
	else
	{
		NavPathFinder = R_NavPathFinder(LocalRBots.CreateRBotsObject(NavPathFinderClass, Self));
		if(NavPathFinder == None)
		{
			LogString = "Failed to initialize NavPathFinder from class" @ NavPathFinderClass;
			Warn(LogString);
			Utilities.Static.RLog(LogString, LogCategory);
		}

		NavPathFilter = R_NavPathFilter(LocalRBots.CreateRBotsObject(NavPathFilterClass, Self));
		if(NavPathFilter == None)
		{
			LogString = "Failed to initialize NavPathFilter from class" @ NavPathFilterClass;
			Warn(LogString);
			Utilities.Static.RLog(LogString, LogCategory);
		}
	}
}

//------------------------------------------------------------------------------
//	Cached reference accessors

final function R_DynamicMapData GetMapData()
{
	local R_RBotsServerActor LocalRBots;
	LocalRBots = GetRBotsServerActor();
	if(CachedMapData == None && LocalRBots != None)
	{
		CachedMapData = LocalRBots.GetMapData();
	}
	return CachedMapData;
}

final function R_NavMesh GetNavMesh()
{
	local R_DynamicMapData LocalMapData;

	if(CachedNavMesh == None)
	{
		LocalMapData = GetMapData();
		if(LocalMapData != None)
		{
			CachedNavMesh = LocalMapData.GetNavMesh();
		}
	}
	return CachedNavMesh;
}

//------------------------------------------------------------------------------

function R_NavPathFinder GetNavPathFinder()
{
	return NavPathFinder;
}

function R_NavPathFilter GetNavPathFilter()
{
	return NavPathFilter;
}

//------------------------------------------------------------------------------
//	NavZones
//	In the context of a NavMesh, NavZones are PolyGroups

function int GetNavZoneCount()
{
	local R_NavMesh NavMesh;

	NavMesh = GetNavMesh();
	if(NavMesh != None)
	{
		return NavMesh.GetPolyGroupCount();
	}
	return 0;
}

function int GetNavZoneIndexByName(Name NavZoneName)
{
	local R_NavMesh NavMesh;
	local int NavZoneIndex;

	NavMesh = GetNavMesh();
	if(NavMesh != None)
	{
		NavZoneIndex = NavMesh.GetPolyGroupIndexByName(NavZoneName);
		if(NavZoneIndex != NavLib.Static.InvalidIndex())
		{
			return NavZoneIndex;
		}
	}
	return NavLib.Static.InvalidIndex();
}

//------------------------------------------------------------------------------
//	FindPath

function bool FindPath(
	Vector StartLocation,
	Vector EndLocation,
	R_NavContext NavContext,
	optional R_NavContextObserver OptionalNavContextObserver,
	optional R_NavSettings OptionalNavSettings)
{
	local R_NavMesh NavMesh;
	local R_NavGraphInterface PolygonGraphInterface;
	local int StartIndex, EndIndex;

	if(NavPathFinder == None || NavPathFilter == None)
	{
		return false;
	}

	NavMesh = GetNavMesh();
	if(NavMesh == None)
	{	// Cannot path find without a NavMesh
		return false;
	}

	PolygonGraphInterface = NavMesh.GetPolygonGraphInterface();
	if(PolygonGraphInterface == None)
	{	// Cannot path find without the polygon graph interface
		return false;
	}

	StartIndex = NavMesh.FindContainingNodeIndex(StartLocation);
	EndIndex = NavMesh.FindContainingNodeIndex(EndLocation);

	if(StartIndex == NavLib.Static.InvalidIndex() || EndIndex == NavLib.Static.InvalidIndex())
	{
		return false;
	}

	if(OptionalNavContextObserver != None)
	{
		OptionalNavContextObserver.ClearPath();
		OptionalNavContextObserver.SetNavPathFinderClass(NavPathFinder.Class);
		OptionalNavContextObserver.SetNavPathFilterClass(NavPathFilter.Class);
	}

	NavContext.ClearPath();

	if(!NavPathFinder.FindPath(PolygonGraphInterface, StartIndex, EndIndex, NavContext, OptionalNavContextObserver))
	{
		return false;
	}

	if(!NavPathFilter.PostProcessPath(NavMesh, StartLocation, EndLocation, NavContext, OptionalNavContextObserver))
	{
		return false;
	}

	if(OptionalNavContextObserver != None)
	{
		OptionalNavContextObserver.CopyNavPath(NavContext);
	}

	return true;
}

//------------------------------------------------------------------------------
//	FindDirectionTowardsAreaByIndex

function bool FindDirectionTowardsNavZoneByIndex(
	Vector StartLocation,
	int NavZoneIndex,
	out Vector OutDirection,
	optional R_NavSettings OptionalNavSettings)
{
	local R_NavMesh NavMesh;
	local int StartPolygonNavMeshIndex, StartPolygonPolyGroupIndex;
	local int StartPolyGroupIndex;
	local int NextPolygonIndex;
	local R_NavMeshPolyGroup StartPolyGroup, EndPolyGroup;
	local R_NavMeshPortal Portal;
	local int PortalCount;
	local int PortalIndex;
	local int i;
	local float CurrentCost, BestCost;
	local int BestPortalIndex;
	local Vector VLocStart[3], VLocNext[3];
	local Vector CenterStart, CenterNext;

	OutDirection = Vect(0,0,0);
	
	NavMesh = GetNavMesh();
	if(NavMesh == None)
	{
		return false;
	}

	// Get Polygon and PolyGroup start indices
	StartPolygonNavMeshIndex = NavMesh.FindContainingNodeIndex(StartLocation);
	StartPolyGroupIndex = NavMesh.FindContainingPolyGroupIndex(StartLocation);
	if(StartPolygonNavMeshIndex == NavLib.Static.InvalidIndex() || StartPolyGroupIndex == NavLib.Static.InvalidIndex())
	{
		return false;
	}

	// Get PolyGroup references
	StartPolyGroup = NavMesh.GetPolyGroupByIndex(StartPolyGroupIndex);
	EndPolyGroup = NavMesh.GetPolyGroupByIndex(NavZoneIndex);
	if(StartPolyGroup == None || EndPolyGroup == None)
	{
		return false;
	}

	// If start and end polygroups are the same, return success with no direction
	if(StartPolyGroup.GetPolyGroupIndex() == EndPolyGroup.GetPolyGroupIndex())
	{
		OutDirection = Vect(0,0,0);
		return true;
	}

	// Need Polygon's PolyGroup index
	StartPolygonPolyGroupIndex = StartPolyGroup.GetTrianglePolyGroupIndex(StartPolygonNavMeshIndex);

	// Find the lowest cost Portal to the destination PolyGroup
	// Cost = (Cost from location to Portal) + (Cost from Portal to PolyGroup)
	BestCost = NavLib.Static.MaxDistance();
	BestPortalIndex = NavLib.Static.InvalidIndex();
	PortalCount = StartPolyGroup.GetPortalCount();
	for(i = 0; i < PortalCount; ++i)
	{
		PortalIndex = StartPolyGroup.GetPortalNavMeshIndex(i);
		Portal = NavMesh.GetPortalByIndex(PortalIndex);
		if(Portal == None)
		{
			continue;
		}

		//CurrentCost = StartPolyGroup.GetPortalCostFromIndex(StartPolygonPolyGroupIndex, i);
		CurrentCost = Portal.GetCostToPolyGroup(EndPolyGroup.GetPolyGroupIndex());
		if(CurrentCost < BestCost)
		{
			BestCost = CurrentCost;
			BestPortalIndex = PortalIndex;
		}
	}

	// If no Portal found, there's no Path to that PolyGroup from the current
	if(BestPortalIndex == NavLib.Static.InvalidIndex())
	{
		OutDirection = Vect(0,0,0);
		return false;
	}

	// Get the best neighbor towards the Portal
	NextPolygonIndex = StartPolyGroup.GetNextPolygonNeighborTowardsPortal(StartPolygonNavMeshIndex, BestPortalIndex);
	if(NextPolygonIndex == NavLib.Static.InvalidIndex())
	{
		OutDirection = Vect(0,0,0);
		return false;
	}

	// Return direction from here to there
	NavMesh.GetTriangleVertexLocationsUnchecked(StartPolygonNavMeshIndex, VLocStart);
	NavMesh.GetTriangleVertexLocationsUnchecked(NextPolygonIndex, VLocNext);

	CenterStart = (VLocStart[0] + VLocStart[1] + VLocStart[2]) * (1.0/3.0);
	CenterNext = (VLocNext[0] + VLocNext[1] + VLocNext[2]) * (1.0/3.0);

	OutDirection = Normal(Vect(1,1,0) * (CenterNext - CenterStart));
	return true;
}