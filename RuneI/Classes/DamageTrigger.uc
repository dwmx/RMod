//=============================================================================
// DamageTrigger.
//=============================================================================
class DamageTrigger expands Trigger;

var() int DamageAmount;
var() name DamageType;

//--------------------------------------------------------
//
// Fired
//
//--------------------------------------------------------

function Fired(actor Other)
{
	Other.JointDamaged(DamageAmount, Instigator, Other.Location, vect(0, 0, 0), DamageType, 0);
}

defaultproperties
{
}
