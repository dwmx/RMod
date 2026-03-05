//==============================================================================
//	R_ArpgAffix_MaxHealthPercent
//  Increases MaxHealth by percent
//==============================================================================
class R_ArpgAffix_MaxHealthPercent extends R_ArpgAffix abstract;

static function String GetAffixInspectionString(int Parameters)
{
	return "Increase maximum health by" @ Parameters $"%";
}

static function GetAttributeModifiers(
	int Parameters,
	out Name OutAttributeNames[8],
	out float OutMagnitudes[8],
	out int OutOperators[8],
	out int OutModifierCount)
{
    OutAttributeNames[0] = 'MaxHealth';
    OutMagnitudes[0] = float(Parameters) / 100.0;
    OutOperators[0] = OPERATION_ADD_FRACTION;

	OutModifierCount = 1;
}