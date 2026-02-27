class R_ArpgPawn_Hero extends R_ArpgPawn;

//var private R_ArpgInventorySet InventorySet;
var private R_ArpgItemContainerSet InventorySet;

event PostBeginPlay()
{
	local Weapon W;

	Super.PostBeginPlay();

	SubstituteMesh = SkelModel(DynamicLoadObject("VWCreatures.Giant", Class.Class));
	//SubstituteMesh = SkelModel'VWCreatures.Giant';

	W = Spawn(Class'RArpg.R_ArpgWeapon');
	AddInventory(W);
	AcquireInventory(W);

	AddSkill(Class'RArpg.R_ArpgSkill_Whirlwind');
	AddSkill(Class'RArpg.R_ArpgSkill_Orb');
	AddSkill(Class'RArpg.R_ArpgSkill_Attack');
}

function InitializeInventorySet()
{
	InventorySet = R_ArpgItemContainerSet(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgItemContainerSet_HeroInventory', Self));
}

function R_ArpgItemContainerSet GetInventorySet()
{
	return InventorySet;
}

function Input_Fire()
{
	ActivateSkill();
}

function ActivateSkill()
{
	if(GetSkill(0) != None)
	{
		GetSkill(0).ActivateSkill();
	}
}

event FrameNotify(int framepassed)
{
	GetSkill(0).OwnerFrameNotify(framepassed);
	Super.FrameNotify(framepassed);
}

defaultproperties
{
	//RemoteRole=ROLE_AutonomousProxy
	Skeletal=SkelModel'Players.Ragnar'
	SubstituteMesh=SkelModel'VWCreatures.Giant'
	SkelMesh=1
	CollisionRadius=18.000000
	CollisionHeight=42.000000
	WeaponJoint=attach_hand
	bFrameNotifies=true
}