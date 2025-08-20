//==============================================================================
//	R_Behavior_FindWeapon
//	Try to acquire a weapon
//==============================================================================
class R_Behavior_FindWeapon extends R_Behavior;

var private Weapon WeaponTarget;
var private float WeaponUpdateCooldownSeconds, LastWeaponUpdateTimeSeconds;

function BehaviorActivated()
{
	local R_Bot Bot;

	Bot = GetBot();
	if(Bot != None)
	{
		Bot.ClearPath();
	}

	LastWeaponUpdateTimeSeconds = 0.0;
}

function BehaviorTerminated()
{
	local R_Bot Bot;

	Bot = GetBot();
	if(Bot != None)
	{
		Bot.ClearPath();
	}
}

function float ScoreWeapon(Weapon W)
{
	return W.Damage;
}

function Weapon FindWeaponTarget()
{
	local PlayerPawn P;
	local Weapon BestWeapon, CurrentWeapon;
	local float BestScore, CurrentScore;

	P = GetPlayerPawn();
	if(P != None)
	{
		BestWeapon = None;
		BestScore = 0.0;

		foreach P.AllActors(Class'Engine.Weapon', CurrentWeapon)
		{
			CurrentScore = ScoreWeapon(CurrentWeapon);
			if(CurrentScore > BestScore)
			{
				BestScore = CurrentScore;
				BestWeapon = CurrentWeapon;
			}
		}
	}

	return BestWeapon;
}

function BehaviorTick(float DeltaSeconds)
{
	local R_Bot Bot;
	local PlayerPawn P;
	local float TimeSeconds;

	Bot = GetBot();
	if(Bot == None)
	{
		return;
	}

	P = GetPlayerPawn();
	TimeSeconds = 0.0;
	if(P != None)
	{
		TimeSeconds = P.Level.TimeSeconds;
	}

	if(WeaponTarget == None && TimeSeconds - LastWeaponUpdateTimeSeconds >= WeaponUpdateCooldownSeconds)
	{
		LastWeaponUpdateTimeSeconds = TimeSeconds;
		WeaponTarget = FindWeaponTarget();

		if(WeaponTarget != None)
		{
			Bot.TryUpdatePath(P.Location, WeaponTarget.Location);
		}
	}

	FollowPath();
}

function FollowPath()
{
	local R_Bot Bot;
	local Vector MovementInput;

	Bot = GetBot();
	if(Bot != None)
	{
		MovementInput = Bot.GetPathFollowMovementInputVector();
		Bot.AddMovementInput(MovementInput);
	}
}

defaultproperties
{
	WeaponUpdateCooldownSeconds=2.0
}