//==============================================================================
//	R_ArpgAnimationSet_Ragnar
//	Base class for Ragnar SkelModel animations
//	Subclass and override the default properties to implement a new AnimSet
//==============================================================================
class R_ArpgAnimationSet_Ragnar extends R_ArpgAnimationSet;

//------------------------------------------------------------------------------

// Death animations
const A_DTH_ALL_death1_AN0N = 'DTH_ALL_death1_AN0N';	// Death, fall to his right
const A_DeathB				= 'DeathB';					// Death, fall backward holding gut

const A_S4_Powerupidle		= 'S4_Powerupidle';			// Loop, holding weapon up in the air

//------------------------------------------------------------------------------

var Name Idle;
var Name Forward;
var Name Backward;
var Name Forward45Right;
var Name Forward45Left;
var Name Backward45Right;
var Name Backward45Left;
var Name StrafeRight;
var Name StrafeLeft;

var Name AttackMoving;
var Name AttackIdle;

//------------------------------------------------------------------------------

static function Name GetStaticAnimationForMovementDirection(int MovementDirection)
{
	switch(MovementDirection)
	{
	case MOVEDIR_NEUTRAL:			return Default.Idle;
	case MOVEDIR_FORWARD:			return Default.Forward;
	case MOVEDIR_BACKWARD:			return Default.Backward;
	case MOVEDIR_RIGHT:				return Default.StrafeRight;
	case MOVEDIR_LEFT:				return Default.StrafeLeft;
	case MOVEDIR_FORWARD_RIGHT:		return Default.Forward45Right;
	case MOVEDIR_FORWARD_LEFT:		return Default.Forward45Left;
	case MOVEDIR_BACKWARD_RIGHT:	return Default.Backward45Right;
	case MOVEDIR_BACKWARD_LEFT:		return Default.Backward45Left;
	}

	return '';
}

static function Name GetStaticAttackAnimation(optional int Parameters)
{
	return Default.AttackMoving;
}

static function Name GetStaticDeathAnimation(optional int Parameters)
{
	local Name Options[2];
	Options[0] = A_DTH_ALL_death1_AN0N;
	Options[1] = A_DeathB;
	return Options[Rand(ArrayCount(Options))];
}

static function Name GetStaticPainAnimation(optional int Parameters)
{
	local Name PainAnimations[2];
	PainAnimations[0] = 'N_PainFront';
	PainAnimations[1] = 'N_PainBack';
	return PainAnimations[Rand(ArrayCount(PainAnimations))];
}

static function bool GetStaticWhirlwindAnimation(out Name AnimSequence, out float Frame)
{
	AnimSequence = 'X5_AttackB';
	Frame = 0.52;
	return true;
}

//------------------------------------------------------------------------------

defaultproperties
{
    Idle=neutral_idle
    Forward=MOV_ALL_run1_AA0N
    Backward=MOV_ALL_runback1_AA0S
    Forward45Right=MOV_ALL_rstrafe1_AA0S
    Forward45Left=MOV_ALL_lstrafe1_AA0S
    Backward45Right=MOV_ALL_lstrafe1_AA0S
    Backward45Left=MOV_ALL_rstrafe1_AA0S
    StrafeRight=MOV_ALL_rstrafe1_AN0N
    StrafeLeft=MOV_ALL_lstrafe1_AN0N
}