//==============================================================================
//	R_ArpgItemModifier_AllSkills
//  Adds + all skills
//==============================================================================
class R_ArpgItemModifier_AllSkills extends R_ArpgItemModifier abstract;

static function String GetItemModifierInspectionString(int Parameters)
{
    return "+" $ Parameters @ "to all skills";
}