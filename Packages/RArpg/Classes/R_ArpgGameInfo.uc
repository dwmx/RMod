//==============================================================================
//	R_ArpgGameInfo
//==============================================================================
class R_ArpgGameInfo extends R_GameInfo;

const ArpgLib = Class'RArpg.R_ArpgLibrary';
const TagLib = Class'RArpg.R_ArpgTagLibrary';

// ItemFactory
var private R_ArpgItemFactory ItemFactory;
var private R_ArpgData_WorldPresenceDataStore WorldPresenceDataStore;

function R_ArpgItemFactory GetItemFactory()
{
	return ItemFactory;
}

function R_ArpgData_WorldPresenceDataStore GetWorldPresenceDataStore()
{
	return WorldPresenceDataStore;
}

event PostBeginPlay()
{
	ItemFactory = R_ArpgItemFactory(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgItemFactory', Self));
	WorldPresenceDataStore = R_ArpgData_WorldPresenceDataStore(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgData_WorldPresenceDataStore', Self));
}

event PostLogin(PlayerPawn NewPlayer)
{
	local R_ArpgPlayerController PlayerController;

	Super.PostLogin(NewPlayer);

	// Spawn the controlled pawn for the new player
	PlayerController = R_ArpgPlayerController(NewPlayer);
	if(PlayerController != None)
	{
		SpawnPawnForPlayer(PlayerController);
	}
}

function SpawnPawnForPlayer(R_ArpgPlayerController PlayerController)
{
	local R_ArpgPawn NewPawn;

	if(PlayerController == None)
	{
		return;
	}

	NewPawn = Spawn(
		Class'RArpg.R_ArpgPawn_Hero',
		PlayerController,,
		PlayerController.Location + Vect(0,0,1) * 200.0,
		PlayerController.Rotation);
	PlayerController.SetControlledPawn(NewPawn);

	// Grant a couple of test items
	// TODO: Still need to implement the WorldPresence data store
	NewPawn.TryAddItem(ItemFactory.CreateItemFromTag(TagLib.Static.MakeTag('Item','Weapon','Sword','BroadSword')));
	NewPawn.TryAddItem(ItemFactory.CreateItemFromTag(TagLib.Static.MakeTag('Item','Shield','WoodShield')));
}

function Killed( pawn killer, pawn Other, name damageType )
{
	Super.Killed(Killer, Other, DamageType);

	if(R_ArpgPawn(Killer) != None && R_ArpgPawn(Other) != None)
	{
		R_ArpgPawn(Killer).IncrementExperience(50.0);
	}
}

defaultproperties
{
	RunePlayerClass=Class'RArpg.R_ArpgPlayerController'
	HUDType=Class'RArpg.R_UI_GameHUD'
}