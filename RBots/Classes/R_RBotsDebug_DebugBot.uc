//==============================================================================
//	R_RBotsDebug_DebugBot
//	Special debug bot class meant for debugging path finding
//==============================================================================
class R_RBotsDebug_DebugBot extends R_Bot;

var float TimeAccumulator;
var Inventory CurrentPathingTarget;
var bool bRandomPathing;

var Vector StartLocation;
var Vector EndLocation;

event Tick(float DeltaSeconds)
{
	super.Tick(DeltaSeconds);

	if(bRandomPathing)
	{
		TimeAccumulator += DeltaSeconds;
		if(TimeAccumulator >= 6.0)
		{
			TimeAccumulator = 0.0;
			FindNewDebugPath();
		}
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

function SetStartLocation(Vector NewStartLocation)
{
	StartLocation = NewStartLocation;
	TryUpdatePath(StartLocation, EndLocation);
}

function SetEndLocation(Vector NewEndLocation)
{
	EndLocation = NewEndLocation;
	TryUpdatePath(StartLocation, EndLocation);
}

function bool GetDesiredPathStart(out Vector OutDesiredStart)
{
	OutDesiredStart = StartLocation;
	return true;
}

function bool GetDesiredPathEnd(out Vector OutDesiredEnd)
{
	OutDesiredEnd = EndLocation;
	return true;
}

defaultproperties
{
	bRandomPathing=false
}