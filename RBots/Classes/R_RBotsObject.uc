//==============================================================================
//	R_RBotsObject
//	Base class for most objects in RBots, other than those extending Actor
//==============================================================================
class R_RBotsObject extends Object abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'RBots';

// Common error strings used for logging throughout various objects
const CommonError_InvalidRBots = "Invalid RBotsServerActor reference";

var private R_RBotsServerActor RBots;

var bool bLogCreation;

const InvalidIndex = -1;
const InvalidKey = 'None';

//------------------------------------------------------------------------------
// Variants -- One struct which can hold multiple types
// Used extensively throughout behavior related classes

const TypeCodeInvalid	= -1;
const TypeCodeInt 		= 0;
const TypeCodeFloat 	= 1;
const TypeCodeVector 	= 2;
const TypeCodeActor 	= 3;
const TypeCodeClass 	= 4;
const TypeCodeObject 	= 5;

const TypeCodeValidMin = 0;
const TypeCodeValidMax = 5;

struct R_Variant
{
	var int TypeCode;
	var int IntData;
	var float FloatData[3];
	var Object ObjectRef;
};

struct R_KeyValuePair
{
	var Name Key;
	var R_Variant Value;
};

//------------------------------------------------------------------------------
// Events
// All RBotObjects can receive events via ReceiveEvent function

struct R_EventPayload
{
	var Object HostObject;
	var Name HostTag;
};

//------------------------------------------------------------------------------

final function SetRBotsServerActor(R_RBotsServerActor NewRBots) { RBots = NewRBots; }
final function R_RBotsServerActor GetRBotsServerActor() { return RBots; }

final function BaseCreated()
{
	if(bLogCreation)
	{
		Utilities.Static.RLog("Created" @ String(Self.Class) @ "with Outer" @ Outer, LogCategory);
	}
	Created();
}

//------------------------------------------------------------------------------

function Created();
function Initialize();
function ReceiveEvent(Name EventName, bool bContainsPaylod, out R_EventPayload InPayload);

//------------------------------------------------------------------------------
// Variant functions

static function bool InitializeVariant(int TypeCode, out R_Variant OutVariant)
{
	local String LogString;

	if(TypeCode < TypeCodeValidMin || TypeCode > TypeCodeValidMax)
	{
		LogString = "Invalid TypeCode:" @ TypeCode;
		GoTo FailWithLogString;
	}

	OutVariant.TypeCode = TypeCode;
	return true;

FailWithLogString:
	LogString = "MakeVariant failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	OutVariant.TypeCode = TypeCodeInvalid;
	return false;
}

static function R_Variant MakeIntVariant(int Value)
{
	local R_Variant Result;
	Result.TypeCode = TypeCodeInt;
	Result.IntData = Value;
	return Result;
}

static function R_Variant MakeFloatVariant(float Value)
{
	local R_Variant Result;
	Result.TypeCode = TypeCodeFloat;
	Result.FloatData[0] = Value;
	return Result;
}

static function R_Variant MakeVectorVariant(Vector Value)
{
	local R_Variant Result;
	Result.TypeCode = TypeCodeVector;
	Result.FloatData[0] = Value.X;
	Result.FloatData[1] = Value.Y;
	Result.FloatData[2] = Value.Z;
	return Result;
}

static function R_Variant MakeActorVariant(Actor Ref)
{
	local R_Variant Result;
	Result.TypeCode = TypeCodeActor;
	Result.ObjectRef = Ref;
	return Result;
}

static function R_Variant MakeClassVariant(Class Ref)
{
	local R_Variant Result;
	Result.TypeCode = TypeCodeClass;
	Result.ObjectRef = Ref;
	return Result;
}

static function R_Variant MakeObjectVariant(Object Ref)
{
	local R_Variant Result;
	Result.TypeCode = TypeCodeObject;
	Result.ObjectRef = Ref;
	return Result;
}

//------------------------------------------------------------------------------

static function int GetIntVariant(R_Variant Variant)
{
	if(Variant.TypeCode == TypeCodeInt) { return Variant.IntData; }
	return 0;
}

static function float GetFloatVariant(R_Variant Variant)
{
	if(Variant.TypeCode == TypeCodeFloat) { return Variant.FloatData[0]; }
	return 0.0;
}

static function Vector GetVectorVariant(R_Variant Variant)
{
	local Vector Result;
	if(Variant.TypeCode == TypeCodeVector)
	{
		Result.X = Variant.FloatData[0];
		Result.Y = Variant.FloatData[1];
		Result.Z = Variant.FloatData[2];
		return Result;
	}
	return Vect(0,0,0);
}

static function Actor GetActorVariant(R_Variant Variant)
{
	if(Variant.TypeCode == TypeCodeActor) { return Actor(Variant.ObjectRef); }
	return None;
}

static function Class GetClassVariant(R_Variant Variant)
{
	if(Variant.TypeCode == TypeCodeClass) { return Class(Variant.ObjectRef); }
	return None;
}

static function Object GetObjectVariant(R_Variant Variant)
{
	if(Variant.TypeCode == TypeCodeObject) { return Variant.ObjectRef; }
	return None;
}

//------------------------------------------------------------------------------

static function bool MatchVariantType(R_Variant A, R_Variant B)
{
	return A.TypeCode == B.TypeCode;
}

static function bool MatchVariantValue(R_Variant A, R_Variant B)
{
	if(A.TypeCode == B.TypeCode)
	{
		switch(A.TypeCode)
		{
		case TypeCodeInt:	return A.IntData == B.IntData;
		case TypeCodeFloat:	return A.FloatData[0] == B.FloatData[0];
		case TypeCodeVector:
			return A.FloatData[0] == B.FloatData[0]
				&& A.FloatData[1] == B.FloatData[1]
				&& A.FloatData[2] == B.FloatData[2];
		case TypeCodeActor:
		case TypeCodeClass:
		case TypeCodeObject:
			return A.ObjectRef == B.ObjectRef;
		}
	}
	return false;
}

//------------------------------------------------------------------------------
//	KeyValuePair functions

static function bool IsValidKey(Name Key)
{
	return Key != '' && Key != InvalidKey;
}

//------------------------------------------------------------------------------

defaultproperties
{
	bLogCreation=false
}