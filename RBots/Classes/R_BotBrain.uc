//==============================================================================
//	R_BotBrain
//
//	Brain is the core decision-making component of a Bot
//
//	This Class's job is to take information from all other components of a Bot,
//	make decisions with that information, and write the results of those
//	decisions back to the Bot's BlackBoard
//
//	This is the only class, other than the Bot itself, that is allowed to
//	write to the BlackBoard
//==============================================================================
class R_BotBrain extends R_BotObject;

var private R_BlackBoardWriteInterface BlackBoardWriteInterface;

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

function SetBlackBoardWriteInterface(R_BlackBoardWriteInterface NewBlackBoardWriteInterface)
{
	BlackBoardWriteInterface = NewBlackBoardWriteInterface;
}

//------------------------------------------------------------------------------

function TickBotObject(float DeltaSeconds)
{
	UpdateInventoryWantParameters();
	UpdateInventoryTarget();
}

//------------------------------------------------------------------------------

function UpdateInventoryWantParameters()
{
	local PlayerPawn PP;
	local float Value;

	PP = GetPlayerPawn();
	if(PP != None)
	{
		BlackBoardWriteInterface.SetFloat(BBKey_WantWeapon, CalcParamWantWeapon(PP));
		BlackBoardWriteInterface.SetFloat(BBKey_WantShield, CalcParamWantShield(PP));
		BlackBoardWriteInterface.SetFloat(BBKey_WantHealth, CalcParamWantHealth(PP));
		BlackBoardWriteInterface.SetFloat(BBKey_WantStrength, CalcParamWantStrength(PP));
		BlackBoardWriteInterface.SetFloat(BBKey_WantRunePower, CalcParamWantRunePower(PP));
	}
}

function float CalcParamWantWeapon(PlayerPawn PP)
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

	return 1.0 - FClamp(BestScore, 0.0, 1.0);
}

function float CalcParamWantShield(PlayerPawn PP)
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

	return 1.0 - FClamp(BestScore, 0.0, 1.0);
}

function float CalcParamWantHealth(PlayerPawn PP)
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

function float CalcParamWantStrength(PlayerPawn PP)
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

function float CalcParamWantRunePower(PlayerPawn PP)
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

//------------------------------------------------------------------------------

function UpdateInventoryTarget()
{
	local R_BotPerception Perception;
	local int NumInventories;
	local Inventory Inv;
	local int i;
	local int PickupTypeCode;
	local float CurrentScore, BestScore;
	local Inventory BestInventory;
	local R_BlackBoardReadInterface BlackBoardReadInterface;
	local float WantWeapon, WantShield, WantHealth, WantStrength, WantRunePower;

	Perception = GetBotPerception();
	BlackBoardReadInterface = GetBlackBoardReadInterface();

	if(Perception == None || BlackBoardReadInterface == None)
	{
		return;
	}

	BlackBoardWriteInterface.SetActor(BBKey_InventoryTarget, None);
	BlackBoardReadInterface.GetFloat(BBKey_WantWeapon, WantWeapon);
	BlackBoardReadInterface.GetFloat(BBKey_WantShield, WantShield);
	BlackBoardReadInterface.GetFloat(BBKey_WantHealth, WantHealth);
	BlackBoardReadInterface.GetFloat(BBKey_WantStrength, WantStrength);
	BlackBoardReadInterface.GetFloat(BBKey_WantRunePower, WantRunePower);

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
			CurrentScore = ScoreInventoryAsWeapon(Inv) * WantWeapon;
			break;
		case PickupType_Shield:
			CurrentScore = ScoreInventoryAsShield(Inv) * WantShield;
			break;
		case PickupType_Health:
			CurrentScore = ScoreInventoryAsHealthPickup(Inv) * WantHealth;
			break;
		case PickupType_Strength:
			CurrentScore = ScoreInventoryAsStrengthPickup(Inv) * WantStrength;
			break;
		case PickupType_RunePower:
			CurrentScore = ScoreInventoryAsRunePowerPickup(Inv) * WantRunePower;
			break;
		}

		if(CurrentScore > BestScore)
		{
			BestScore = CurrentScore;
			BestInventory = Inv;
		}
	}

	BlackBoardWriteInterface.SetActor(BBKey_InventoryTarget, BestInventory);
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