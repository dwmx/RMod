//==============================================================================
//	R_ArpgData_ItemInstructionsDataStore
//==============================================================================
class R_ArpgData_ItemInstructionsDataStore extends R_ArpgDataStore;

const DataStoreClass = Class'RArpgCore.R_ArpgDataStoreArray';
var private R_ArpgDataStore DataStore;

//------------------------------------------------------------------------------

function bool GetItemInstructions(
	R_ArpgTag InstructionsTag,
	out R_ArpgData_ItemInstructions OutItemInstructions)
{
	local R_ArpgObject Data;
	local bool bResult;

	bResult = DataStore.GetData(InstructionsTag, Data);
	OutItemInstructions = R_ArpgData_ItemInstructions(Data);
	return bResult;
}

//------------------------------------------------------------------------------

function InitializeArpgObject()
{
	Log("Loading Item Instructions Data Store from class" @ Self.Class);
	DataStore = R_ArpgDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass, Self));
	PopulateDataStore();
}

function R_ArpgData_ItemInstructions CreateItemInstructions(
	R_ArpgTag ItemInstructionsTag,
	String ItemInstructionsString)
{
	local R_ArpgData_ItemInstructions Data;

	Data = R_ArpgData_ItemInstructions(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgData_ItemInstructions', Self));
	Data.InstructionsTag = ItemInstructionsTag;
	Data.InstructionsString = ItemInstructionsString;
	return Data;
}

function PopulateDataStore()
{
	PopulateUniqueData();
}

function PopulateUniqueData()
{
	local R_ArpgTag Tag;
	local R_ArpgData_ItemInstructions Data;

	// Odin's Blade
	Tag = TagLib.Static.MakeTag('Instruction','Unique','Weapon','OdinsBlade');
	Data = CreateItemInstructions(Tag, "Odin's Blade");
	Data.AddAffixInstruction(Class'RArpg.R_ArpgAffix_AllSkills', 2, 3);
	Data.AddAffixInstruction(Class'RArpg.R_ArpgAffix_MaxHealthPercent', 25, 25);
	Data.AddAffixInstruction(Class'RArpg.R_ArpgAffix_AttackRate', 100, 200);
	DataStore.AddData(Tag, Data);
}
