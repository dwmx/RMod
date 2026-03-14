//==============================================================================
//	R_ArpgDBPlayerController
//	Debug version of ArpgPlayerController
//	Adds a bunch of useful debug exec functions
//==============================================================================
class R_ArpgDBPlayerController extends R_ArpgPlayerController;

exec function TestTakeDamage(float Amount)
{
	GetControlledPawn().ArpgTakeDamage(Amount);
}

exec function TrySetAttribute(Name AttributeName, float Value)
{
	Log("Attempting to set Attribute" @ AttributeName @ "to a value of" @ Value);
	GetControlledPawn().GetEntity().GetEntityAttributeSet().SetAttributeBaseValue(AttributeName, Value);
}

exec function TryAddModifier(Name AttributeName, int Operator, float Magnitude)
{
	GetControlledPawn().GetEntity().GetEntityAttributeSet().AddAttributeModifier(AttributeName, Magnitude, Operator, 100);
}

exec function TryRemoveAllModifiers()
{
	GetControlledPawn().GetEntity().GetEntityAttributeSet().RemoveAttributeModifiersBySource(100);
}

exec function TestTossFloat()
{
	R_ArpgPawn_Hero(GetControlledPawn()).TryTossFloatingItem();
}

exec function TestUICommand(Name UICommand)
{
	GetGameUI().InputCommand(UICommand);
}

exec function TestItemPickup()
{
	local Vector SpawnLocation;
	local R_ArpgItemActor_Pickup A;
	local R_ArpgGameInfo GI;
	local R_ArpgItemFactory ItemFactory;
	local R_ArpgItem NewItem;

	GI = R_ArpgGameInfo(Level.Game);
	ItemFactory = GI.GetItemFactory();
	NewItem = ItemFactory.CreateItemFromTag(TagLib.Static.MakeTag('Item','Weapon','Axe','BattleAxe'));

	SpawnLocation = GetControlledPawn().Location;
	A = Spawn(Class'RArpg.R_ArpgItemActor_Pickup',,,SpawnLocation);
	A.SetItem(NewItem);
}

exec function TestSkill(Name SkillName)
{
	GetControlledPawn().Input_Skill(SkillName);
}

exec function TestAnim(Name AnimName)
{
	GetControlledPawn().GetAnimInterface().TryPlayAnim(AnimName, 'UpperBody', 1.0, 0.1);
}

exec function TestCancelAnim()
{
	GetControlledPawn().GetAnimInterface().CancelCurrentAnim();
}

exec function TestAnimParam(Name AnimParameter, float Value)
{
	Log("TestAnimParam(" $ AnimParameter $ ", " $ Value $ ")");
	GetControlledPawn().GetAnimInterface().SetAnimParameter(AnimParameter, Value);
}