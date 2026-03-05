//==============================================================================
//	R_ArpgAffix_MaxHealth
//  Increases MaxHealth by flat amount
//==============================================================================
class R_ArpgAffix_MaxHealth extends R_ArpgAffix abstract;

static function String GetAffixInspectionString(int Parameters)
{
    return "+" $ Parameters $ " to maximum health";
}

static function GetAttributeModifiers(
	int Parameters,
	out Name OutAttributeNames[8],
	out float OutMagnitudes[8],
	out int OutOperators[8],
	out int OutModifierCount)
{
    OutAttributeNames[0] = 'MaxHealth';
    OutMagnitudes[0] = float(Parameters);
    OutOperators[0] = OPERATION_ADD;

	OutModifierCount = 1;
}