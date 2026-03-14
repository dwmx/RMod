//==============================================================================
//	R_ArpgAnimationSet
//==============================================================================
class R_ArpgAnimationSet extends R_ArpgObject;

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

static function Name GetStaticAnimationForMovementDirection(int MovementDirection);
static function Name GetStaticAttackAnimation(optional int Parameters);
static function Name GetStaticDeathAnimation(optional int Parameters);
static function bool GetStaticWhirlwindAnimation(out Name AnimSequence, out float Frame);