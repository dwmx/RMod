//==============================================================================
//	R_ArpgAffix
//==============================================================================
class R_ArpgAffix extends R_ArpgObject abstract;

// These need to be reflect in R_ArpgAttributeSet
const OPERATION_ADD = 1;
const OPERATION_ADD_FRACTION = 2;

static function String GetAffixInspectionString(int Parameters) { return ""; }

static function GetAttributeModifiers(
	int Parameters,
	out Name OutAttributeNames[8],
	out float OutMagnitudes[8],
	out int OutOperators[8],
	out int OutModifierCount)
{
	OutModifierCount = 0;
}