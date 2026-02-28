//==============================================================================
//	R_ArpgItemModifier_AttackSpeed
//  Adds + all skills
//==============================================================================
class R_ArpgItemModifier_AttackSpeed extends R_ArpgItemModifier abstract;

static function String GetItemModifierInspectionString(int Parameters)
{
    return "+" $ Parameters @ "to attack speed";
}