
//==============================================================================
//	R_RBotsDebug_StringManager
//	Class for managing the organization and drawing of debug strings
//==============================================================================
class R_RBotsDebug_StringManager extends Object;

const Utilities = Class'RBots.R_BotUtilities';
const DebugLib = Class'RBots.R_RBots_DebugLibrary';

const WhiteTexture = Texture'UWindow.WhiteTexture';

// Debug Categories -- all strings are associated with one category
var Name DebugCategoriesArray[64]; // Needs to match MAX_DEBUG_CATEGORIES
var int NumDebugCategories;
const MAX_DEBUG_CATEGORIES = 64;

// Color legend -- Each Category can have one color legend
struct LabeledColor
{
	var Color Color;
	var String Label;
};

struct ColorLegend
{
	var LabeledColor LabeledColors[16]; // Need to match MAX_LABELED_COLORS
	var int NumLabeledColors;
};
const MAX_LABELED_COLORS = 16;
var ColorLegend ColorLegendArray[64]; // Needs to match MAX_DEBUG_CATEGORIES

// Debug Strings
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

const COLOR_LEGEND_VERTICAL_SPACING = 10.0;
const DEBUG_STRING_VERTICAL_SPACING = 10.0;
const CATEGORY_SECTION_SPACING = 4.0;
const CATEGORY_SPACING = 12.0;

function Initialize()
{

}

// Adds category if it is not already added
function AddCategory(Name Category)
{
	local int i;

	// Add category to DebugCategories array
	for(i = 0; i < NumDebugCategories && i < MAX_DEBUG_CATEGORIES; ++i)
	{
		if(DebugCategoriesArray[i] == Category)
		{
			break;
		}
	}
	if(i == NumDebugCategories && i < MAX_DEBUG_CATEGORIES)
	{
		// Add Category and create a color legend for it
		DebugCategoriesArray[i] = Category;
		ColorLegendArray[i].NumLabeledColors = 0;
		++NumDebugCategories;
	}
}

function bool GetCategoryIndex(Name Category, out int OutCategoryIndex)
{
	local int i;

	for(i = 0; i < MAX_DEBUG_CATEGORIES; ++i)
	{
		if(DebugCategoriesArray[i] == Category)
		{
			OutCategoryIndex = i;
			return true;
		}
	}

	OutCategoryIndex = -1;
	return false;
}

// Add a color to the specified Categorie's color legend
function AddColor(Name Category, String Label, Color Color)
{
	local int CategoryIndex;
	local int LabeledColorIndex;

	// Ensure that the category has been added
	AddCategory(Category);
	
	if(!GetCategoryIndex(Category, CategoryIndex))
	{
		Utilities.Static.RLog("AddColor failed -- GetCategoryIndex failed when it should not have");
		return;
	}

	if(ColorLegendArray[CategoryIndex].NumLabeledColors >= MAX_LABELED_COLORS)
	{
		Utilities.Static.RLog("AddColor failed -- too many colors, max is" @ MAX_LABELED_COLORS);
		return;
	}

	LabeledColorIndex = ColorLegendArray[CategoryIndex].NumLabeledColors;
	ColorLegendArray[CategoryIndex].LabeledColors[LabeledColorIndex].Color = Color;
	ColorLegendArray[CategoryIndex].LabeledColors[LabeledColorIndex].Label = Label;
	ColorLegendArray[CategoryIndex].NumLabeledColors++;
}

// Add a string to the specified category
function AddString(Name Category, String DebugString, optional String Label, optional Name StringType, optional int MetaData)
{
	local int i;

	if(NumDebugStrings >= DEBUG_STRING_ARRAY_SIZE)
	{
		Utilities.Static.RLog("StringManager debug string array full, cannot add string" @ DebugString);
		return;
	}

	// Ensure that the category has been added
	AddCategory(Category);

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
	local int i;

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
		YPos += DEBUG_STRING_VERTICAL_SPACING;	// Add string size
		YPos += CATEGORY_SECTION_SPACING;		// Add section spacing

		// Draw the category's color legend if it has one
		if(DrawColorLegend(C, XPos, YPos, ColorLegendArray[i]))
		{
			YPos += CATEGORY_SECTION_SPACING; // Add section spacing after color legend
		}

		// Draw all strings for this category
		for(j = 0; j < NumDebugStrings; ++j)
		{
			if(DebugStringArray[j].DebugCategory == DebugCategoriesArray[i])
			{
				if(DrawDebugString(C, XPos, YPos, DebugStringArray[j]))
				{
					YPos += DEBUG_STRING_VERTICAL_SPACING;
				}
			}
		}

		YPos += CATEGORY_SPACING;
	}
}

function bool DrawColorLegend(Canvas C, out float InOutXPos, out float InOutYPos, out ColorLegend InColorLegend)
{
	local int i;
	local float XPos, YPos;
	local float RGB[3];

	if(InColorLegend.NumLabeledColors == 0)
	{
		return false;
	}

	DebugLib.Static.InitializeCanvasForDebugDrawing(C);

	XPos = InOutXPos;
	YPos = InOutYPos;
	for(i = 0; i < InColorLegend.NumLabeledColors; ++i)
	{
		// Draw Color rect
		C.DrawColor = InColorLegend.LabeledColors[i].Color;
		C.SetPos(XPos+1, YPos+1);
		C.DrawRect(WhiteTexture, COLOR_LEGEND_VERTICAL_SPACING-2, COLOR_LEGEND_VERTICAL_SPACING-2);

		// Draw Label text
		XPos += COLOR_LEGEND_VERTICAL_SPACING + 4.0;
		C.DrawColor = LabelColor;
		C.SetPos(XPos, YPos);
		C.DrawText(InColorLegend.LabeledColors[i].Label);

		// Adjust for next entry
		XPos = InOutXPos;
		YPos += COLOR_LEGEND_VERTICAL_SPACING;
	}

	// Update where the drawing ended
	InOutYPos = YPos;
	return true;
}

function bool DrawDebugString(Canvas C, float XPos, float YPos, out DebugString InDebugString)
{
	local float StrW, StrH;
	local String LabelString;

	DebugLib.Static.InitializeCanvasForDebugDrawing(C);

	StrW = 0.0;
	StrH = 0.0;

	if(InDebugString.Label != "")
	{
		LabelString = InDebugString.Label $ ": ";
		C.StrLen(LabelString, StrW, StrH);
		
		if(InDebugString.StringType == StringType_Warning)
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
	if(InDebugString.StringType == StringType_Warning)
	{
		C.DrawColor = WarningStringColor;
	}
	else if(InDebugString.StringType == StringType_Bool)
	{	// Bool
		if(InDebugString.MetaData == 0)
		{
			C.DrawColor = BoolColorFalse;
		}
		else
		{
			C.DrawColor = BoolColorTrue;
		}
	}
	else if(InDebugString.StringType == StringType_Int)
	{	// Int
		C.DrawColor = IntColor;
	}
	else if(InDebugString.StringType == StringType_Vector)
	{	// Vector
		C.DrawColor = VectorColor;
	}
	else if(InDebugString.StringType == StringType_Actor)
	{	// Actor
		if(InDebugString.MetaData == 0)
		{
			C.DrawColor = ActorColorNone;
		}
		else
		{
			C.DrawColor = ActorColor;
		}
	}
	else if(InDebugString.StringType == StringType_Object)
	{	// Object
		if(InDebugString.MetaData == 0)
		{
			C.DrawColor = ObjectColorNone;
		}
		else
		{
			C.DrawColor = ObjectColor;
		}
	}
	else if(InDebugString.StringType == StringType_Class)
	{	// Class
		if(InDebugString.MetaData == 0)
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
	C.DrawText(InDebugString.DebugString);
	return true;
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