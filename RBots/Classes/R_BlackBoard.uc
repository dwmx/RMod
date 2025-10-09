//==============================================================================
//	R_BlackBoard
//	Contains AI context state shared over multiple behaviors
//==============================================================================
class R_BlackBoard extends R_BotObject;

var private Inventory InventoryTarget;	// The Inventory this Bot wants

//------------------------------------------------------------------------------
//	Inventory selection parameters
var private float WantWeapon;
var private float WantShield;
var private float WantHealth;
var private float WantStrength;
var private float WantRunePower;

var private float OwnedWeaponScore;	// The highest score of any owned weapon
var private float OwnedShieldScore; // The score of the current shield

var private int TargetNavZoneIndex;	// The NavZone the Bot wants to be in

//------------------------------------------------------------------------------
//	Inventory selection parameters
function SetWantWeapon(float NewWantWeapon)			{ WantWeapon = FClamp(NewWantWeapon, 0.0, 1.0); }
function float GetWantWeapon()						{ return WantWeapon; }

function SetWantShield(float NewWantShield)			{ WantShield = FClamp(NewWantShield, 0.0, 1.0); }
function float GetWantShield()						{ return WantShield; }

function SetWantHealth(float NewWantHealth)			{ WantHealth = FClamp(NewWantHealth, 0.0, 1.0); }
function float GetWantHealth()						{ return WantHealth; }

function SetWantStrength(float NewWantStrength)		{ WantStrength = FClamp(NewWantStrength, 0.0, 1.0); }
function float GetWantStrength()					{ return WantStrength; }

function SetWantRunePower(float NewWantRunePower)	{ WantRunePower = FClamp(NewWantRunePower, 0.0, 1.0); }
function float GetWantRunePower()					{ return WantRunePower; }

function SetOwnedWeaponScore(float NewOwnedWeaponScore)	{ OwnedWeaponScore = FClamp(NewOwnedWeaponScore, 0.0, 1.0); }
function float GetOwnedWeaponScore()					{ return OwnedWeaponScore; }

function SetOwnedShieldScore(float NewOwnedShieldScore)	{ OwnedShieldScore = FClamp(NewOwnedShieldScore, 0.0, 1.0); }
function float GetOwnedShieldScore()					{ return OwnedShieldScore; }

function SetInventoryTarget(Inventory NewInventoryTarget) { InventoryTarget = NewInventoryTarget; }
function Inventory GetInventoryTarget() { return InventoryTarget; }

function SetTargetNavZoneIndex(int NewTargetNavZoneIndex)	{ TargetNavZoneIndex = NewTargetNavZoneIndex; }
function int GetTargetNavZoneIndex() { return TargetNavZoneIndex; }

defaultproperties
{
	bTickBotObject=false
}