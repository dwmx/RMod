//==============================================================================
//	R_LogicLayer_InventoryWants
//	Writes each of the Inventory-related 'Want' parameters to the BlackBoard,
//	if they're available
//
//	This determines what is the most important Inventory to pick up, i.e.
//	if health is low, the Bot might want to prefer a health pickup over a weapon
//==============================================================================
class R_LogicLayer_InventoryWants extends R_LogicLayer;

//------------------------------------------------------------------------------

function Initialize() {}

function TickLogicLayer(
	float DeltaSeconds,
	R_Bot Bot,
	R_BlackBoardWriteInterface BlackBoardWriteInterface)
{
	local PlayerPawn PP;

	PP = Bot.GetOwnedPlayerPawn();
	if(PP != None)
	{
		UpdateInventoryWantParameters(BlackBoardWriteInterface, PP);
	}	
}

//------------------------------------------------------------------------------

function UpdateInventoryWantParameters(R_BlackBoardWriteInterface BlackBoardWriteInterface, PlayerPawn PP)
{
	local float Value;

	BlackBoardWriteInterface.SetFloat(BBKey_WantWeapon, CalcParamWantWeapon(PP));
	BlackBoardWriteInterface.SetFloat(BBKey_WantShield, CalcParamWantShield(PP));
	BlackBoardWriteInterface.SetFloat(BBKey_WantHealth, CalcParamWantHealth(PP));
	BlackBoardWriteInterface.SetFloat(BBKey_WantStrength, CalcParamWantStrength(PP));
	BlackBoardWriteInterface.SetFloat(BBKey_WantRunePower, CalcParamWantRunePower(PP));
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