//==============================================================================
//	R_ArpgAffix_AttackSpeed
//  Adds + all skills
//==============================================================================
class R_ArpgAffix_AttackSpeed extends R_ArpgAffix abstract;

static function String GetAffixInspectionString(int Parameters)
{
    return "+" $ Parameters @ "to attack speed";
}