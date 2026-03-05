//==============================================================================
//	R_ArpgAffix_AllSkills
//  Adds + all skills
//==============================================================================
class R_ArpgAffix_AllSkills extends R_ArpgAffix abstract;

static function String GetAffixInspectionString(int Parameters)
{
    return "+" $ Parameters @ "to all skills";
}