//==============================================================================
//	R_BehaviorActionInstance
//==============================================================================
class R_BehaviorActionInstance extends R_RBotsObject;

const LogCategory = 'BehaviorActionInstance';

var private R_BehaviorAction BehaviorAction;

const KeyValueStoreClass = Class'RBots.R_KeyValueStore_Implementation';
var private R_KeyValueStore KeyValueStore;

//------------------------------------------------------------------------------

function SetBehaviorAction(R_BehaviorAction NewBehaviorAction)
{
	BehaviorAction = NewBehaviorAction;
}

function R_BehaviorAction GetBehaviorAction()
{
	return BehaviorAction;
}

//------------------------------------------------------------------------------

function Initialize()
{
	Super.Initialize();
	InitializeKeyValueStore();
}

function InitializeKeyValueStore()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{
		LogString = CommonError_InvalidRBots;
		GoTo FailWithLogString;
	}

	KeyValueStore = R_KeyValueStore(LocalRBots.CreateRBotsObject(KeyValueStoreClass, Self));
	if(KeyValueStore == None)
	{
		LogString = "Failed to instantiate KeyValueStore";
		GoTo FailWithLogString;
	}

	return;

FailWithLogString:
	LogString = "InitializeKeyValueStore failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

//------------------------------------------------------------------------------

function bool AddParameter(Name ParamName, int TypeCode)
{
	return KeyValueStore.Add(ParamName, TypeCode);
}

function bool GetParameter(Name ParamName, out R_Variant OutValue)
{
	return KeyValueStore.Get(ParamName, OutValue);
}

function bool SetParameter(Name ParamName, R_Variant Value)
{
	return KeyValueStore.Set(ParamName, Value);
}

//------------------------------------------------------------------------------
//	Parameter Helpers
//	Parameters are stored on Instances as Variant types, referenced by Keys
//	These are here to simplify Action's code for accessing these parameters
//
//	All functions return false if they could not retrieve the parameter

function bool GetNameParameter(Name Key, out Name OutValue, optional Name OptionalDefault)
{
	local R_Variant Variant;
	if(GetParameter(Key, Variant))
	{
		OutValue = GetNameVariant(Variant);
		return true;
	}
	OutValue = OptionalDefault;
	return false;
}

function bool GetIntParameter(Name Key, out int OutValue, optional int OptionalDefault)
{
	local R_Variant Variant;
	if(GetParameter(Key, Variant))
	{
		OutValue = GetIntVariant(Variant);
		return true;
	}
	OutValue = OptionalDefault;
	return false;
}

function bool GetFloatParameter(Name Key, out float OutValue, optional float OptionalDefault)
{
	local R_Variant Variant;
	if(GetParameter(Key, Variant))
	{
		OutValue = GetFloatVariant(Variant);
		return true;
	}
	OutValue = OptionalDefault;
	return false;
}

function bool GetVectorParameter(Name Key, out Vector OutValue, optional Vector OptionalDefault)
{
	local R_Variant Variant;
	if(GetParameter(Key, Variant))
	{
		OutValue = GetVectorVariant(Variant);
		return true;
	}
	OutValue = OptionalDefault;
	return false;
}

function bool GetActorParameter(Name Key, out Actor OutRef, optional Actor OptionalDefault)
{
	local R_Variant Variant;
	if(GetParameter(Key, Variant))
	{
		OutRef = GetActorVariant(Variant);
		return true;
	}
	OutRef = OptionalDefault;
	return false;
}

function bool GetClassParameter(Name Key, out Class OutRef, optional Class OptionalDefault)
{
	local R_Variant Variant;
	if(GetParameter(Key, Variant))
	{
		OutRef = GetClassVariant(Variant);
		return true;
	}
	OutRef = OptionalDefault;
	return false;
}

function bool GetObjectParameter(Name Key, out Object OutRef, optional Object OptionalDefault)
{
	local R_Variant Variant;
	if(GetParameter(Key, Variant))
	{
		OutRef = GetObjectVariant(Variant);
		return true;
	}
	OutRef = OptionalDefault;
	return false;
}