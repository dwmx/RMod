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
*	FindDirectionTowardsLocation
*	Given a start and end location, performs a broad search to find only
*	the instantaneous direction that would progress you closer to end,
*	without finding a full path
*
*	Returns false if no direction could be found
*/
function bool FindDirectionTowardsLocation(
	Vector StartLocation,
	Vector EndLocation,
	out Vector OutDirection,
	optional R_NavSettings OptionalNavSettings);

/**
*	FindDirectionTowardsPolyGroup
*	Given a location and a PolyGroup index, performs a broad search to find
*	only the instantaneous direction that would progress you closer to the
*	specified polygroup, without finding a full path
*
*	Slightly faster than DirectionTowardsLocation, but less accurate if know
*	specifically where you want to be in some room
*
*	Returns false if no direction could be found
*/
function bool FindDirectionTowardsPolyGroup(
	Vector Location,
	int PolyGroupIndex,
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