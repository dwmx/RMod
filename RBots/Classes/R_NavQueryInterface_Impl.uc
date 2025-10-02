//==============================================================================
//	R_NavQueryInterface_Impl
//	Implementation of NavQueryInterface class
//==============================================================================
class R_NavQueryInterface_Impl extends R_NavQueryInterface;

const Utilities = Class'RBots.R_BotUtilities';
const NavLib = Class'RBots.R_NavLibrary';
const LogCategory = 'NavQueryInterface';

var private R_RBotsServerActor RBots;

// Cached references
var private R_DynamicMapData CachedMapData;
var private R_NavMesh CachedNavMesh;

const NavPathFinderClass = Class'RBots.R_NavPathFinder_Dijkstras';
const NavPathFilterClass = Class'RBots.R_NavPathFilter_Funnel';

var private R_NavPathFinder NavPathFinder;
var private R_NavPathFilter NavPathFilter;

//------------------------------------------------------------------------------

function SetRBotsServerActor(R_RBotsServerActor NewRBotsServerActor)
{
	RBots = NewRBotsServerActor;
}

function InitializeNavQueryInterface()
{
	InitNavPathFinder();
	InitNavPathFilter();
}

final function InitNavPathFinder()
{
	local String FailedLogString;

	if(NavPathFinder != None)
	{	// Already instantiated
		return;
	}

	NavPathFinder = R_NavPathFinder(InitSubObject(NavPathFinderClass, FailedLogString));
	if(NavPathFinder == None)
	{
		Utilities.Static.RLog("InitNavPathFinder failed --" @ FailedLogString, LogCategory);
		return;
	}

	Utilities.Static.RLog("Initialized NavPathFinder:" @ NavPathFinder, LogCategory);
}

final function InitNavPathFilter()
{
	local String FailedLogString;

	if(NavPathFilter != None)
	{	// Already instantiated
		return;
	}

	NavPathFilter = R_NavPathFilter(InitSubObject(NavPathFilterClass, FailedLogString));
	if(NavPathFilter == None)
	{
		Utilities.Static.RLog("InitNavPathFilter failed --" @ FailedLogString, LogCategory);
		return;
	}

	Utilities.Static.RLog("Initialized NavPathFilter:" @ NavPathFilter, LogCategory);
}

final function Object InitSubObject(Class ObjectClass, out String OutFailedLogString)
{
	local Object Result;

	if(ObjectClass == None)
	{
		OutFailedLogString = "Bad ObjectClass:" @ ObjectClass;
		return None;
	}

	Result = new(None) ObjectClass;
	if(Result == None)
	{
		OutFailedLogString = "Instantiation failed for ObjectClass:" @ ObjectClass;
		return None;
	}

	return Result;
}

//------------------------------------------------------------------------------
//	Cached reference accessors

final function R_DynamicMapData GetMapData()
{
	if(CachedMapData == None && RBots != None)
	{
		CachedMapData = RBots.GetMapData();
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
//	Implementation

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