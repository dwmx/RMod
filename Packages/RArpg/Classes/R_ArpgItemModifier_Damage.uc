//==============================================================================
//	R_ArpgItemModifier_Damage
//  Adds + to damage
//==============================================================================
class R_ArpgItemModifier_Damage extends R_ArpgItemModifier abstract;

static function String GetItemModifierInspectionString(int Parameters)
{
    return "+" $ Parameters @ "to damage";
}