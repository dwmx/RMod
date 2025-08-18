
//==============================================================================
//	R_RBotsDebug_StringManager
//	Class for managing the organization and drawing of debug strings
//==============================================================================
class R_RBotsDebug_StringManager extends Object;

const Utilities = Class'RBots.R_BotUtilities';

const StringType_String = 'StringType_String';
const StringType_Warning = 'StringType_Warning';
const StringType_Bool = 'StringType_Bool';
const StringType_Int = 'StringType_Int';
const StringType_Vector = 'StringType_Vector';
const StringType_Actor = 'StringType_Actor';
const StringType_Object = 'StringType_Object';
const StringType_Class = 'StringType_Class';

struct DebugString
{
	var Name DebugCategory;
	var String DebugString;
	var String Label;
	var Name StringType;
	var int MetaData;
};
var private DebugString DebugStringArray[1024];
var private int NumDebugStrings;
const DEBUG_STRING_ARRAY_SIZE = 1024;

var Name DebugCategoriesArray[1024];
var int NumDebugCategories;
const DEBUG_CATEGORIES_ARRAY_SIZE = 1024;

var Color CategoryColor;
var Color LabelColor;
var Color StringColor;
var Color WarningLabelColor;
var Color WarningStringColor;
var Color BoolColorTrue;
var Color BoolColorFalse;
var Color IntColor;
var Color VectorColor;
var Color ActorColor;
var Color ActorColorNone;
var Color ObjectColor;
var Color ObjectColorNone;
var Color ClassColor;
var Color ClassColorNone;

function Initialize()
{

}

function AddString(Name Category, String DebugString, optional String Label, optional Name StringType, optional int MetaData)
{
	local int i;

	if(NumDebugStrings >= DEBUG_STRING_ARRAY_SIZE)
	{
		Utilities.Static.RLog("StringManager debug string array full, cannot add string" @ DebugString);
		return;
	}

	// Add category to DebugCategories array
	for(i = 0; i < NumDebugCategories && i < DEBUG_CATEGORIES_ARRAY_SIZE; ++i)
	{
		if(DebugCategoriesArray[i] == Category)
		{
			break;
		}
	}
	if(i == NumDebugCategories && i < DEBUG_CATEGORIES_ARRAY_SIZE)
	{
		DebugCategoriesArray[i] = Category;
		++NumDebugCategories;
	}

	// Add string
	DebugStringArray[NumDebugStrings].DebugCategory = Category;
	DebugStringArray[NumDebugStrings].DebugString = DebugString;
	DebugStringArray[NumDebugStrings].Label = Label;
	DebugStringArray[NumDebugStrings].StringType = StringType;
	DebugStringArray[NumDebugStrings].MetaData = MetaData;
	++NumDebugStrings;
}

function AddWarning(Name Category, String WarningString)
{
	AddString(Category, WarningString, "Warning", StringType_Warning);
}

function AddBool(Name Category, String Label, bool bBoolValue)
{
	local int MetaData;
	local String BoolString;

	if(!bBoolValue)
	{
		MetaData = 0;
		BoolString = "false";
	}
	else
	{
		MetaData = 1;
		BoolString = "true";
	}

	AddString(Category, BoolString, Label, StringType_Bool, MetaData);
}

function AddInt(Name Category, String Label, int IntValue)
{
	local int MetaData;
	local String IntString;

	MetaData = IntValue;
	IntString = String(IntValue);

	AddString(Category, IntString, Label, StringType_Int, MetaData);
}

function AddVector(Name Category, String Label, Vector VectorValue)
{
	local String VectorString;

	VectorString = "(X=" $ VectorValue.X $ ",Y=" $ VectorValue.Y $ ",Z=" $ VectorValue.Z $ ")";
	//VectorString = String(VectorValue);

	AddString(Category, VectorString, Label, StringType_Vector, 0);
}

function AddActor(Name Category, String Label, Actor ActorRef)
{
	local int MetaData;
	local String ActorString;

	if(ActorRef == None)
	{
		MetaData = 0;
		ActorString = "None";
	}
	else
	{
		MetaData = 1;
		ActorString = String(ActorRef);
	}

	AddString(Category, ActorString, Label, StringType_Actor, MetaData);
}

function AddObject(Name Category, String Label, Object ObjectRef)
{
	local int MetaData;
	local String ObjectString;

	if(Actor(ObjectRef) != None)
	{
		AddActor(Category, Label, Actor(ObjectRef));
		return;
	}

	if(ObjectRef == None)
	{
		MetaData = 0;
		ObjectString = "None";
	}
	else
	{
		MetaData = 1;
		ObjectString = String(ObjectRef);
	}

	AddString(Category, ObjectString, Label, StringType_Object, MetaData);
}

function AddClass(Name Category, String Label, Class ClassRef)
{
	local int MetaData;
	local String ClassString;

	if(ClassRef == None)
	{
		MetaData = 0;
		ClassString = "None";
	}
	else
	{
		MetaData = 1;
		ClassString = String(ClassRef);
	}

	AddString(Category, ClassString, Label, StringType_Class, MetaData);
}

function Clear()
{
	NumDebugStrings = 0;
	NumDebugCategories = 0;
}

function DrawStringManager(Canvas C)
{
	local float XPos, YPos;
	local int i, j;

	C.Font = C.MedFont;
	

	XPos = 16.0;
	YPos = 16.0;

	for(i = 0; i < NumDebugCategories; ++i)
	{
		// Category color
		C.DrawColor.R = 80;
		C.DrawColor.G = 255;
		C.DrawColor.B = 80;

		// Print category
		C.SetPos(XPos, YPos);
		C.DrawText("" $ DebugCategoriesArray[i]);
		YPos += 14.0;

		// Strings color
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;

		for(j = 0; j < NumDebugStrings; ++j)
		{
			if(DebugStringArray[j].DebugCategory == DebugCategoriesArray[i])
			{
				DrawDebugString(C, XPos, YPos, DebugStringArray[j]);
				YPos += 10.0;
			}
		}

		YPos += 12.0;
	}
}

function DrawDebugString(Canvas C, float XPos, float YPos, out DebugString DebugString)
{
	local float StrW, StrH;
	local String LabelString;

	StrW = 0.0;
	StrH = 0.0;

	if(DebugString.Label != "")
	{
		LabelString = DebugString.Label $ ": ";
		C.StrLen(LabelString, StrW, StrH);
		
		if(DebugString.StringType == StringType_Warning)
		{
			C.DrawColor = WarningLabelColor;
		}
		else
		{
			C.DrawColor = LabelColor;
		}
		C.SetPos(XPos, YPos);
		C.DrawText(LabelString);
	}

	// Select draw color based on string type
	if(DebugString.StringType == StringType_Warning)
	{
		C.DrawColor = WarningStringColor;
	}
	else if(DebugString.StringType == StringType_Bool)
	{	// Bool
		if(DebugString.MetaData == 0)
		{
			C.DrawColor = BoolColorFalse;
		}
		else
		{
			C.DrawColor = BoolColorTrue;
		}
	}
	else if(DebugString.StringType == StringType_Int)
	{	// Int
		C.DrawColor = IntColor;
	}
	else if(DebugString.StringType == StringType_Vector)
	{	// Vector
		C.DrawColor = VectorColor;
	}
	else if(DebugString.StringType == StringType_Actor)
	{	// Actor
		if(DebugString.MetaData == 0)
		{
			C.DrawColor = ActorColorNone;
		}
		else
		{
			C.DrawColor = ActorColor;
		}
	}
	else if(DebugString.StringType == StringType_Object)
	{	// Object
		if(DebugString.MetaData == 0)
		{
			C.DrawColor = ObjectColorNone;
		}
		else
		{
			C.DrawColor = ObjectColor;
		}
	}
	else if(DebugString.StringType == StringType_Class)
	{	// Class
		if(DebugString.MetaData == 0)
		{
			C.DrawColor = ClassColorNone;
		}
		else
		{
			C.DrawColor = ClassColor;
		}
	}
	else
	{	// Default -- goes back to StringType_String
		C.DrawColor = StringColor;
	}

	C.SetPos(XPos + StrW, YPos);
	C.DrawText(DebugString.DebugString);
}

defaultproperties
{
	CategoryColor=(R=80,G=255,B=80)
	LabelColor=(R=255,G=255,B=255)
	StringColor=(R=120,G=180,B=180)
	WarningLabelColor=(R=255,G=255,B=80)
	WarningStringColor=(R=128,G=128,B=40)
	BoolColorTrue=(R=80,G=255,B=80)
	BoolColorFalse=(R=255,G=80,B=80)
	IntColor=(R=255,G=255,B=80)
	VectorColor=(R=255,G=255,B=80)
	ActorColor=(R=80,G=80,B=255)
	ActorColorNone=(R=255,G=80,B=80)
	ObjectColor=(R=120,G=180,B=180)
	ObjectColorNone=(R=255,G=80,B=80)
	ClassColor=(R=153,G=5,B=86)
	ClassColorNone=(R=255,G=80,B=80)
}