
//==============================================================================
//	R_RBotsDebug_StringManager
//	Class for managing the organization and drawing of debug strings
//==============================================================================
class R_RBotsDebug_StringManager extends Object;

const Utilities = Class'RBots.R_BotUtilities';

struct DebugString
{
	var Name DebugCategory;
	var String DebugString;
};
var private DebugString DebugStringArray[1024];
var private int NumDebugStrings;
const DEBUG_STRING_ARRAY_SIZE = 1024;

var Name DebugCategoriesArray[1024];
var int NumDebugCategories;
const DEBUG_CATEGORIES_ARRAY_SIZE = 1024;

function Initialize()
{

}

function AddString(Name Category, String DebugString)
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
	++NumDebugStrings;
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
				C.SetPos(XPos, YPos);
				C.DrawText(DebugStringArray[j].DebugString);
				YPos += 10.0;
			}
		}

		YPos += 12.0;
	}
}