//==============================================================================
//	R_BotBehavior_Main
//	Main bot behavior
//==============================================================================
class R_BotBehavior_Main extends R_BotBehavior;

var private float TimeAccumulator;

const PickupType_None = -1;
const PickupType_Weapon = 0;
const PickupType_Shield = 1;
const PickupType_Health = 2;
const PickupType_Strength = 3;
const PickupType_RunePower = 4;

var private Class PickupTypes_Weapon[4];
var private Class PickupTypes_Shield[4];
var private Class PickupTypes_Health[4];
var private Class PickupTypes_Strength[4];
var private Class PickupTypes_RunePower[4];

function BehaviorTick(float DeltaSeconds)
{
	local R_BlackBoard BlackBoard;
	local R_BotPawnController Controller;
	local int TargetNavZoneIndex;
	local Vector MoveDirection;

	UpdateInventoryWantParameters();

	TimeAccumulator += DeltaSeconds;
	if(TimeAccumulator >= 10.0)
	{
		UpdateNavZone();
		TimeAccumulator = 0.0;
	}

	BlackBoard = GetBlackBoard();
	Controller = GetBotPawnController();
	if(BlackBoard != None && Controller != None)
	{
		TargetNavZoneIndex = BlackBoard.GetTargetNavZoneIndex();
		if(GetNavDirectionTowardsNavZone(TargetNavZoneIndex, MoveDirection))
		{
			Controller.AddMovementInput_WorldSpace(MoveDirection);
		}
	}

	UpdateInventoryTarget();
}

function UpdateNavZone()
{
	local R_NavQueryInterface NavQueryInterface;
	local R_BlackBoard BlackBoard;
	local int NumNavZones;

	NavQueryInterface = GetNavQueryInterface();
	BlackBoard = GetBlackBoard();

	if(NavQueryInterface == None || BlackBoard == None)
	{
		return;
	}

	NumNavZones = NavQueryInterface.GetNavZoneCount();
	BlackBoard.SetTargetNavZoneIndex(Rand(NumNavZones));
}

function UpdateInventoryTarget()
{
	local R_BotPerception Perception;
	local R_BlackBoard BlackBoard;
	local int NumInventories;
	local Inventory Inv;
	local int i;
	local int PickupTypeCode;
	local float CurrentScore, BestScore;
	local Inventory BestInventory;

	Perception = GetBotPerception();
	BlackBoard = GetBlackBoard();

	if(Perception == None || BlackBoard == None)
	{
		return;
	}

	BlackBoard.SetInventoryTarget(None);

	BestScore = 0.0;
	BestInventory = None;
	NumInventories = Perception.GetPerceivedInventoriesCount();

	for(i = 0; i < NumInventories; ++i)
	{
		Inv = Perception.GetPerceivedInventory(i);
		PickupTypeCode = GetPickupTypeCodeForInventory(Inv);
		switch(PickupTypeCode)
		{
		case PickupType_Weapon:
			CurrentScore = ScoreInventoryAsWeapon(Inv) * BlackBoard.GetWantWeapon();
			break;
		case PickupType_Shield:
			CurrentScore = ScoreInventoryAsShield(Inv) * BlackBoard.GetWantShield();
			break;
		case PickupType_Health:
			CurrentScore = ScoreInventoryAsHealthPickup(Inv) * BlackBoard.GetWantHealth();
			break;
		case PickupType_Strength:
			CurrentScore = ScoreInventoryAsStrengthPickup(Inv) * BlackBoard.GetWantStrength();
			break;
		case PickupType_RunePower:
			CurrentScore = ScoreInventoryAsRunePowerPickup(Inv) * BlackBoard.GetWantRunePower();
			break;
		}

		if(CurrentScore > BestScore)
		{
			BestScore = CurrentScore;
			BestInventory = Inv;
		}
	}

	BlackBoard.SetInventoryTarget(BestInventory);
}

function int GetPickupTypeCodeForInventory(Inventory Inv)
{
	local int i;

	if(Inv == None)
	{
		return PickupType_None;
	}

	// Shield pickups
	for(i = 0; i < ArrayCount(PickupTypes_Weapon); ++i)
	{
		if(PickupTypes_Weapon[i] != None)
		{
			if(ClassIsChildOf(Inv.Class, PickupTypes_Weapon[i]))
			{
				return PickupType_Weapon;
			}
		}
	}

	// Shield pickups
	for(i = 0; i < ArrayCount(PickupTypes_Shield); ++i)
	{
		if(PickupTypes_Shield[i] != None)
		{
			if(ClassIsChildOf(Inv.Class, PickupTypes_Shield[i]))
			{
				return PickupType_Shield;
			}
		}
	}

	// Check for Health pickups
	for(i = 0; i < ArrayCount(PickupTypes_Health); ++i)
	{
		if(PickupTypes_Health[i] != None)
		{
			if(ClassIsChildOf(Inv.Class, PickupTypes_Health[i]))
			{
				return PickupType_Health;
			}
		}
	}

	// Strength pickups
	for(i = 0; i < ArrayCount(PickupTypes_Strength); ++i)
	{
		if(PickupTypes_Strength[i] != None)
		{
			if(ClassIsChildOf(Inv.Class, PickupTypes_Strength[i]))
			{
				return PickupType_Strength;
			}
		}
	}

	// Rune Power pickups
	for(i = 0; i < ArrayCount(PickupTypes_RunePower); ++i)
	{
		if(PickupTypes_RunePower[i] != None)
		{
			if(ClassIsChildOf(Inv.Class, PickupTypes_RunePower[i]))
			{
				return PickupType_RunePower;
			}
		}
	}

	return PickupType_None;
}

//------------------------------------------------------------------------------
//	Inventory Want Params
function UpdateInventoryWantParameters()
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;
	local PlayerPawn PP;

	Bot = GetBot();
	BlackBoard = GetBlackBoard();
	PP = GetPlayerPawn();

	if(Bot != None && BlackBoard != None && PP != None)
	{
		BlackBoard.SetWantWeapon(CalcParamWantWeapon(Bot, PP));
		BlackBoard.SetWantShield(CalcParamWantShield(Bot, PP));
		BlackBoard.SetWantHealth(CalcParamWantHealth(Bot, PP));
		BlackBoard.SetWantStrength(CalcParamWantStrength(Bot, PP));
		BlackBoard.SetWantRunePower(CalcParamWantRunePower(Bot, PP));
		BlackBoard.SetOwnedWeaponScore(CalcParamOwnedWeaponScore(Bot, PP));
		BlackBoard.SetOwnedShieldScore(CalcParamOwnedShieldScore(Bot, PP));
	}
}

function float CalcParamWantWeapon(R_Bot Bot, PlayerPawn PP)
{
	return 1.0 - CalcParamOwnedWeaponScore(Bot, PP);
}

function float CalcParamWantShield(R_Bot Bot, PlayerPawn PP)
{
	return 0.0;
}

function float CalcParamWantHealth(R_Bot Bot, PlayerPawn PP)
{
	local int PawnHealth, PawnMaxHealth;

	PawnHealth = PP.Health;
	PawnMaxHealth = PP.MaxHealth;

	PawnMaxHealth = Max(0, PawnMaxHealth);
	if(PawnMaxHealth == 0)
	{
		return 0.0;
	}

	PawnHealth = Clamp(PawnHealth, 0, PawnMaxHealth);
	return 1.0 - (float(PawnHealth) / float(PawnMaxHealth));
}

function float CalcParamWantStrength(R_Bot Bot, PlayerPawn PP)
{
	local int PawnStrength, PawnMaxStrength;

	PawnStrength = PP.Strength;
	PawnMaxStrength = PP.MaxStrength;

	PawnMaxStrength = Max(0, PawnMaxStrength);
	if(PawnMaxStrength == 0)
	{
		return 0.0;
	}

	PawnStrength = Clamp(PawnStrength, 0, PawnMaxStrength);
	return 1.0 - (float(PawnStrength) / float(PawnMaxStrength));
}

function float CalcParamWantRunePower(R_Bot Bot, PlayerPawn PP)
{
	local int PawnRunePower, PawnMaxRunePower;

	PawnRunePower = PP.RunePower;
	PawnMaxRunePower = PP.MaxPower;

	PawnMaxRunePower = Max(0, PawnMaxRunePower);
	if(PawnMaxRunePower == 0)
	{
		return 0.0;
	}

	PawnRunePower = Clamp(PawnRunePower, 0, PawnMaxRunePower);
	return 1.0 - (float(PawnRunePower) / float(PawnMaxRunePower));
}

function float CalcParamOwnedWeaponScore(R_Bot Bot, PlayerPawn PP)
{
	local Inventory Inv;
	local float BestScore, CurrentScore;

	BestScore = 0.0;
	for(Inv = PP.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		CurrentScore = ScoreInventoryAsWeapon(Inv);
		if(CurrentScore > BestScore)
		{
			BestScore = CurrentScore;
		}
	}

	return FClamp(BestScore, 0.0, 1.0);
}

function float CalcParamOwnedShieldScore(R_Bot Bot, PlayerPawn PP)
{
	local Inventory Inv;
	local float BestScore, CurrentScore;

	BestScore = 0.0;
	for(Inv = PP.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		CurrentScore = ScoreInventoryAsShield(Inv);
		if(CurrentScore > BestScore)
		{
			BestScore = CurrentScore;
		}
	}

	return FClamp(BestScore, 0.0, 1.0);
}

//------------------------------------------------------------------------------
//	Scoring functions
function float ScoreInventoryAsWeapon(Inventory Inv)
{
	local Weapon InvWeap;
	local int Rating;

	InvWeap = Weapon(Inv);
	if(InvWeap == None)
	{
		return 0.0;
	}

	Rating = Clamp(InvWeap.Rating, 0, 4) + 1;
	return float(Rating) / 5.0;
}

function float ScoreInventoryAsShield(Inventory Inv)
{
	local Shield InvShield;
	local int Rating;

	InvShield = Shield(Inv);
	if(InvShield == None)
	{
		return 0.0;
	}

	Rating = Clamp(InvShield.Rating, 0, 4) + 1;
	return float(Rating) / 5.0;
}

function float ScoreInventoryAsHealthPickup(Inventory Inv)
{
	return 1.0;
}

function float ScoreInventoryAsStrengthPickup(Inventory Inv)
{
	return 1.0;
}

function float ScoreInventoryAsRunePowerPickup(Inventory Inv)
{
	return 1.0;
}

defaultproperties
{
	PickupTypes_Weapon(0)=Class'Engine.Weapon'
	PickupTypes_Shield(0)=Class'Engine.Shield'
	PickupTypes_Health(0)=Class'RuneI.Food'
	PickupTypes_Health(1)=Class'RuneI.RuneOfHealth'
	PickupTypes_Strength(0)=Class'RuneI.RuneOfStrength'
	PickupTypes_Strength(1)=Class'RuneI.RuneOfStrengthRefill'
	PickupTypes_RunePower(0)=Class'RuneI.RuneOfPower'
	PickupTypes_RunePower(1)=Class'RuneI.RuneOfPowerRefill'
}