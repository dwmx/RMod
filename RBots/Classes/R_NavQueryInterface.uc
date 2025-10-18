//==============================================================================
//	R_NavQueryInterface
//	Provides the interface through which all environmental navigation queries
//	may be made
//==============================================================================
class R_NavQueryInterface extends R_NavObject;

//------------------------------------------------------------------------------

function R_NavPathFinder GetNavPathFinder();
function R_NavPathFilter GetNavPathFilter();

//------------------------------------------------------------------------------
//	NavZones
//	NavZones are abstract partitions of some underlying navigation structure,
//	cutting the map into multiple different zones
//	In the context of a NavMesh, a NavZone is a PolyGroup
//	Note that these are not in any way tied to the concept of Engine.ZoneInfo

// Returns the number of available navigable zones
function int GetNavZoneCount();

// Returns the index of the navigable zone associated with the given name
// Returns InvalidIndex if no zone could be found
function int GetNavZoneIndexByName(Name NavZoneName);

//------------------------------------------------------------------------------

/**
*	FindRandomNavigableLocationInRadius
*	Given some world location and a radius, returns a random location within
*	XY radius that is reachable via navigation functions
*	Return false if no location could be found
*/
function bool FindRandomNavigableLocationInRadius(
	Vector Origin,
	float Radius,
	out Vector OutLocation);

/**
*	FindPath
*	Given a start and end location, returns a path between them
*	Path is stored in the provided NavContext object's Path
*	Returns false if no path could be found
*/
function bool FindPath(
	Vector StartLocation,
	Vector EndLocation,
	R_NavContext NavContext,
	optional R_NavContextObserver OptionalNavContextObserver,
	optional R_NavSettings OptionalNavSettings);

/**
*	FindDirectionTowardsNavZoneByIndex
*	Given a start location and a NavZone index, returns the instantaneous direction
*	that would progress you towards that NavZone, without performing full path-finding
*	Very fast, fine to use inside of Tick
*
*	Returns false if no direction could be found
*/
function bool FindDirectionTowardsNavZoneByIndex(
	Vector StartLocation,
	int NavZoneIndex,
	out Vector OutDirection,
	optional R_NavSettings OptionalNavSettings);

/**
*	FindAvoidanceDirectionForBordersInRadius
*	Given an origin and radius, returns the direction which best points away from
*	border edges inside that radius
*
*	Returns false if avoidance direction could not be determined
*/
function bool FindAvoidanceDirectionForBordersInRadius(
	Vector Origin,
	float Radius,
	out Vector OutDirection);

defaultproperties
{
	bLogCreation=true
}