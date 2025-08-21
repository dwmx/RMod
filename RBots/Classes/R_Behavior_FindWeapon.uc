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

// Find weapon with highest desirability score
function Weapon FindDesiredWeapon()
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

function bool IsValidWeaponTarget(Weapon W)
{
	local PlayerPawn P;

	if(W.Owner != None)
	{
		return false;
	}

	P = GetPlayerPawn();
	if(P == None)
	{
		return false;
	}

	// CanBeUsed does most of this -- invisible check, duplicate inventory check, etc
	if(!W.CanBeUsed(P))
	{
		return false;
	}

	return true;
}

// Find any random weapon in the level
function Weapon FindRandomWeapon()
{
	local R_Bot Bot;
	local Weapon WeaponCandidates[64];
	local int NumCandidates;
	local Weapon W;

	Bot = GetBot();
	if(Bot != None)
	{
		NumCandidates = 0;
		foreach Bot.AllActors(Class'Engine.Weapon', W)
		{
			if(!IsValidWeaponTarget(W))
			{
				continue;
			}

			WeaponCandidates[NumCandidates] = W;
			++NumCandidates;
			if(NumCandidates >= 64)
			{
				break;
			}
		}
	}

	if(NumCandidates == 0)
	{
		return None;
	}

	return WeaponCandidates[Rand(NumCandidates-1)];
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

	if(TimeSeconds - LastWeaponUpdateTimeSeconds >= WeaponUpdateCooldownSeconds)
	{
		LastWeaponUpdateTimeSeconds = TimeSeconds;
		//WeaponTarget = FindDesiredWeapon();
		WeaponTarget = FindRandomWeapon();

		if(WeaponTarget != None)
		{
			Bot.TryUpdatePath(P.Location, WeaponTarget.Location);
		}
	}

	FollowPath();
	TryPickupWeapon();	
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

function TryPickupWeapon()
{
	local PlayerPawn P;
	local float Distance;

	if(WeaponTarget == None || WeaponTarget.Owner != None)
	{
		return;
	}

	P = GetPlayerPawn();
	if(P == None)
	{
		return;
	}

	Distance = VSize(WeaponTarget.Location - P.Location);
	//Log("FindWeapon distance" @ Distance);
	if(Distance <= 32.0)
	{
		P.Use();
	}
	else if(Distance <= 350.0 && P.Weapon != None)
	{
		P.SwitchWeapon(1); // Stow
	}
}

defaultproperties
{
	WeaponUpdateCooldownSeconds=8.0
}