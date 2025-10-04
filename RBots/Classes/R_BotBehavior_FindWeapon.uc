//==============================================================================
//	R_BotBehavior_FindWeapon
//	Try to acquire a weapon
//==============================================================================
class R_BotBehavior_FindWeapon extends R_BotBehavior;

var private Inventory InventoryTarget;

const StowRange = 350.0;	// Range at which Bot will stow weapon
const UseRange = 48.0;		// Range at which Bot will attempt to pick up

function BehaviorActivated()
{
	local R_Bot Bot;

	Bot = GetBot();
	if(Bot != None)
	{
		Bot.ClearPath();
	}

	SetInventoryTarget(FindDesiredInventory());
}

function OnOwnedPlayerPawnRespawned()
{
	local R_Bot Bot;
	local Weapon W;

	Bot = GetBot();
	if(Bot != None)
	{
		Bot.ClearPath();
	}

	SetInventoryTarget(FindDesiredInventory());
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

function SetInventoryTarget(Inventory Inv)
{
	local R_Bot Bot;
	local PlayerPawn PP;

	Bot = GetBot();
	PP = GetPlayerPawn();
	if(Bot == None || PP == None)
	{
		return;
	}

	InventoryTarget = Inv;
	Bot.ClearPath();
	if(InventoryTarget != None)
	{
		Bot.TryUpdatePath(PP.Location, InventoryTarget.Location);
	}
}

// Returns true if Weapon is valid to be picked up by this Bot's Pawn
function bool IsValidInventoryTarget(Inventory Inv)
{
	local PlayerPawn P;

	if(Inv.Owner != None)
	{
		return false;
	}

	P = GetPlayerPawn();
	if(P == None)
	{
		return false;
	}

	// CanBeUsed does most of this -- invisible check, duplicate inventory check, etc
	if(!Inv.CanBeUsed(P))
	{
		return false;
	}

	return true;
}

/*
// Scoring for each weapon
function float ScoreWeapon(Weapon W)
{
	return W.Damage + W.Rating;
}
	*/

// Find weapon with highest desirability score
function Inventory FindDesiredInventory()
{
	local R_BlackBoard BlackBoard;

	BlackBoard = GetBlackBoard();
	if(BlackBoard != None)
	{
		return BlackBoard.GetInventoryTarget();
	}
	/*
	local PlayerPawn P;
	local R_NavMesh NavMesh;
	local R_NavMeshActorTracker ActorTracker;
	local int NodeIndex, PolyGroupIndex;
	local Actor PolyGroupActors[32];
	local int NumPolyGroupActors;
	local int i;
	local Weapon BestWeapon, CurrentWeapon;
	local float BestScore, CurrentScore;

	P = GetPlayerPawn();
	if(P != None)
	{
		NavMesh = GetNavMesh();
		ActorTracker = GetNavMeshActorTracker();

		NumPolyGroupActors = 0;
		if(NavMesh != None && ActorTracker != None)
		{
			NodeIndex = NavMesh.FindContainingNodeIndex(P.Location);
			NavMesh.GetTrianglePolyGroupIndexUnchecked(NodeIndex, PolyGroupIndex);
			ActorTracker.GetActorsByPolyGroupIndex(PolyGroupIndex, PolyGroupActors, NumPolyGroupActors);
		}

		BestWeapon = None;
		BestScore = 0;

		// Try to find a weapon in the current poly group first
		for(i = 0; i < NumPolyGroupActors; ++i)
		{
			CurrentWeapon = Weapon(PolyGroupActors[i]);
			if(CurrentWeapon != None)
			{
				if(IsValidInventoryTarget(CurrentWeapon))
				{
					CurrentScore = ScoreWeapon(CurrentWeapon);
					if(CurrentScore > BestScore)
					{
						BestScore = CurrentScore;
						BestWeapon = CurrentWeapon;
					}
				}
			}
		}

		if(BestWeapon == None)
		{	// No weapon found, pick one anywhere on the map
			foreach P.AllActors(Class'Engine.Weapon', CurrentWeapon)
			{
				if(IsValidInventoryTarget(CurrentWeapon))
				{
					CurrentScore = ScoreWeapon(CurrentWeapon);
					if(CurrentScore > BestScore)
					{
						BestScore = CurrentScore;
						BestWeapon = CurrentWeapon;
					}
				}
			}
		}
	}

	return BestWeapon;
	*/
}

function BehaviorTick(float DeltaSeconds)
{
	local PlayerPawn PP;
	local R_BotPawnController Controller;
	local float Distance;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return;
	}

	SetInventoryTarget(FindDesiredInventory());
	if(InventoryTarget == None)
	{
		return;
	}

	Distance = VSize(InventoryTarget.Location - PP.Location);
	// If within use range, try to pickup
	if(Distance <= UseRange)
	{
		if(TryPickupWeapon())
		{
			return;
		}
	}

	// If within stow range, stow weapon
	if(Weapon(InventoryTarget) != None && PP.Weapon != None && Distance <= StowRange)
	{
		Controller = GetBotPawnController();
		if(Controller != None)
		{
			Controller.StowWeapon();
		}
	}

	// Follow path until within UseRange
	FollowCurrentPath();
}

// Attempt to pick up
function bool TryPickupWeapon()
{
	local R_BotPawnController Controller;

	Controller = GetBotPawnController();
	if(Controller != None)
	{
		return Controller.TryUse();
	}

	return false;
}
