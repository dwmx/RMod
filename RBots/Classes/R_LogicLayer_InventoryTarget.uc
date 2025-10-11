//==============================================================================
//	R_LogicLayer_InventoryTarget
//	Writes the 'InventoryTarget' to the BlackBoard, using information from
//	the Inventory 'Want' parameters, and the Bot's Perception
//
//	The Bot's Perception object continuously updates an array of Inventory
//	Actors that it's sensing in the world
//
//	This layer determines which of those candidate Inventories the Bot should
//	try to acquire
//==============================================================================
class R_LogicLayer_InventoryTarget extends R_LogicLayer;

//------------------------------------------------------------------------------
const InventoryLib = Class'RBots.R_RBotsInventoryLibrary';
const PickupType_None = -1;
const PickupType_Weapon = 0;
const PickupType_Shield = 1;
const PickupType_Health = 2;
const PickupType_Strength = 3;
const PickupType_RunePower = 4;

//------------------------------------------------------------------------------

function Initialize() {}

function TickLogicLayer(
	float DeltaSeconds,
	R_Bot Bot,
	R_BlackBoardWriteInterface BlackBoardWriteInterface)
{
	local R_BlackBoardReadInterface BlackBoardReadInterface;
	local float WantWeapon, WantShield, WantHealth, WantStrength, WantRunePower;
	local R_BotPerception Perception;
	local int NumInventories;
	local Inventory Inv;
	local int i;
	local int PickupTypeCode;
	local float CurrentScore, BestScore;
	local Inventory BestInventory;
	
	Perception = Bot.GetBotPerception();
	BlackBoardReadInterface = Bot.GetBlackBoardReadInterface();

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
		PickupTypeCode = InventoryLib.Static.GetInventoryPickupTypeCode(Inv);

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