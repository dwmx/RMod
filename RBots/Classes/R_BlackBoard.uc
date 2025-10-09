//==============================================================================
//	R_BlackBoard
//	Contains AI context state shared over multiple behaviors
//==============================================================================
class R_BlackBoard extends R_BotObject;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BlackBoard';

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
//------------------------------------------------------------------------------

// NEW IMPLEMENTATION -- IN BLACKBOARD_IMPLEMENTATION
function bool AddInt(Name Key);
function bool AddFloat(Name Key);
function bool AddVector(Name Key);
function bool AddActor(Name Key);

function bool GetInt(Name Key, out int OutValue);
function bool GetFloat(Name Key, out float OutValue);
function bool GetVector(Name Key, out Vector OutValue);
function bool GetActor(Name Key, out Actor OutValue);

function bool SetInt(Name Key, int Value);
function bool SetFloat(Name Key, float Value);
function bool SetVector(Name Key, Vector Value);
function bool SetActor(Name Key, Actor Value);

function int GetNumKeys();
function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutBlackBoardTypeCode);

function DumpBlackBoardToLog();

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------






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