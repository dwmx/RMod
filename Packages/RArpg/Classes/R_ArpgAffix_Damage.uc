//==============================================================================
//	R_ArpgAffix_Damage
//  Adds + to damage
//==============================================================================
class R_ArpgAffix_Damage extends R_ArpgAffix abstract;

static function String GetAffixInspectionString(int Parameters)
{
    return "+" $ Parameters @ "to damage";
}