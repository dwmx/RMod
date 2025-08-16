//==============================================================================
//	R_RBotsDebug_PathBot
//	Special debug bot class meant for debugging path finding
//==============================================================================
class R_RBotsDebug_PathBot extends R_Bot;

var float TimeAccumulator;

var Inventory CurrentPathingTarget;

event Tick(float DeltaSeconds)
{
	super.Tick(DeltaSeconds);

	TimeAccumulator += DeltaSeconds;
	if(TimeAccumulator >= 10.0)
	{
		TimeAccumulator = 0.0;
		FindNewDebugPath();
	}
}

function FindNewDebugPath()
{
	local Weapon NewTargetWeapon;
	local Vector StartLocation;
	local Vector EndLocation;
	local R_BotNavMesh LocalNavmesh;

	NewTargetWeapon = GetRandomWeapon();
	if(NewTargetWeapon != None)
	{
		StartLocation = NewTargetWeapon.Location;
	}

	NewTargetWeapon = GetRandomWeapon();
	if(NewTargetWeapon != None)
	{
		CurrentPathingTarget = NewTargetWeapon;
		EndLocation = CurrentPathingTarget.Location;
	}

	TryUpdatePath(StartLocation, EndLocation);
}

// Returns a random non-owned weapon somewhere in the level
function Weapon GetRandomWeapon()
{
	local Weapon WeaponArray[24];
	local int i;
	local Weapon W;

	i = 0;
	foreach AllActors(Class'Weapon', W)
	{
		if(W.Owner == None)
		{
			WeaponArray[i] = W;
			++i;
			if(i >= 24)
			{
				break;
			}
		}
	}

	return WeaponArray[Rand(i)];
}

function Actor GetCurrentPathingTarget()
{
	return CurrentPathingTarget;
}