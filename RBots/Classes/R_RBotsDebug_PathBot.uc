//==============================================================================
//	R_RBotsDebug_PathBot
//	Special debug bot class meant for debugging path finding
//==============================================================================
class R_RBotsDebug_PathBot extends R_Bot;

var float TimeAccumulator;

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
	local Vector StartLocation;
	local Vector EndLocation;
	local R_BotNavMesh LocalNavmesh;

	StartLocation = GetRandomWeaponLocation();
	EndLocation = GetRandomWeaponLocation();

	TryUpdatePath(StartLocation, EndLocation);
}

function Vector GetRandomWeaponLocation()
{
	local Weapon W[24];
	local int i;
	local Weapon WTemp;

	foreach AllActors(Class'Weapon', WTemp)
	{
		W[i] = WTemp;
		++i;
		if(i >= 24)
		{
			break;
		}
	}

	return W[Rand(i)].Location;
}