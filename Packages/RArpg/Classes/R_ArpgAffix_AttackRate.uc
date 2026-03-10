//==============================================================================
//	R_ArpgAffix_AttackRate
//  Increase attack rate by an additive multiplier
//==============================================================================
class R_ArpgAffix_AttackRate extends R_ArpgAffix abstract;

static function float CalculateRateFromParameters(int Parameters)
{
    return float(Parameters) / 100.0;
}

static function String GetAffixInspectionString(int Parameters)
{
    local float PercentValue;
    local String FloatString;

    PercentValue = CalculateRateFromParameters(Parameters) * 100.0;
    FloatString = UtilityLib.Static.FloatToString(PercentValue, 1);
    return "+" $ FloatString $ "% to attack rate";
}

static function GetAttributeModifiers(
	int Parameters,
	out Name OutAttributeNames[8],
	out float OutMagnitudes[8],
	out int OutOperators[8],
	out int OutModifierCount)
{
    OutAttributeNames[0] = 'AttackRate';
    OutMagnitudes[0] = CalculateRateFromParameters(Parameters);
    OutOperators[0] = OPERATION_ADD_FRACTION;

	OutModifierCount = 1;
}