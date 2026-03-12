//==============================================================================
//	R_ArpgAnimationSet
//==============================================================================
class R_ArpgAnimationSet extends R_ArpgObject;

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

//	Movement Direction consts
//	These need to match the consts in R_ArpgPawn
const MOVEDIR_NEUTRAL			= 0x0000;
const MOVEDIR_FORWARD 			= 0x0001;
const MOVEDIR_BACKWARD			= 0x0010;
const MOVEDIR_RIGHT				= 0x0100;
const MOVEDIR_LEFT				= 0x1000;
const MOVEDIR_FORWARD_RIGHT		= 0x0101;
const MOVEDIR_FORWARD_LEFT		= 0x1001;
const MOVEDIR_BACKWARD_RIGHT	= 0x0110;
const MOVEDIR_BACKWARD_LEFT		= 0x1010;

//------------------------------------------------------------------------------

static function Name GetStaticAttackAnimation(optional int Parameters)
{
	return Default.AttackMoving;
}

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