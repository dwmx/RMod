//==============================================================================
//	R_CreaturePlayer_DwarfMech
//	Playable DwarfMech
//==============================================================================
class R_CreaturePlayer_DwarfMech extends R_CreaturePlayer;

// RDwarfMech.scm is Rune's original MechaDwarf model reimported with upper/lower joint
// groups necessary for AnimProxy to control upper body animation
#exec SKELETAL IMPORT NAME=RDwarfMech FILE=..\RCreatures\Models\RDwarfMech.scm
#exec SKELETAL ORIGIN NAME=RDwarfMech X=0 Y=0 Z=-50 Pitch=0 Yaw=-64 Roll=-64

// Animation names for the DwarfMech SkelModel
const A_Idle 		= 'Idle';
const A_Walk 		= 'Walk';
const A_Run 		= 'run';
const A_AttackA 	= 'AttackA';
const A_AttackB 	= 'attackB';
const A_PropAntic 	= 'prop_antic';		// Contains root motion
const A_PropCycle 	= 'prop_cycle';
const A_Plant 		= 'plant';
const A_PlantIdle 	= 'plant_idle';
const A_FireWindup 	= 'fire_windup';
const A_FireCycle 	= 'fire_cycle';
const A_FireIdle 	= 'fire_idle';
const A_Unplant 	= 'unplant';
const A_SawCycle 	= 'saw_cycle';
const A_SpinCycle 	= 'spin_cycle';
const A_HighTran 	= 'high_tran';		// Single frame pose
const A_LowTran 	= 'low_tran';		// Single frame pose
const A_Death 		= 'Death';
const A_StartBlowUp	= 'StartBlowUp';
const A_BlowUpCycle = 'BlowUpCycle';

function PlayMoving(optional float Tween)
{
	local MovementDir_e Dir;
	local Rotator RotationOffset;
	local Vector ViewVector;
	local Rotator UpperRot;

	Dir = GetAnimationMovementDirection();
	switch(Dir)
	{
	case MD_FORWARD:
        RotationOffset.Yaw = 0;
        break;
    case MD_FORWARDRIGHT:
        RotationOffset.Yaw = 65535 * 0.825;
        break;
    case MD_RIGHT:
        RotationOffset.Yaw = 65535 * 0.75;
        break;
    case MD_BACKWARDRIGHT:
        RotationOffset.Yaw = 65535 * 0.625;
        break;
    case MD_BACKWARD:
        RotationOffset.Yaw = 65535 * 0.5;
        break;
    case MD_BACKWARDLEFT:
        RotationOffset.Yaw = 65535 * 0.375;
        break;
    case MD_LEFT:
        RotationOffset.Yaw = 65535 * 0.25;
        break;
    case MD_FORWARDLEFT:
        RotationOffset.Yaw = 65535 * 0.125;
        break;
	}

	ViewVector = Vector(ViewRotation);
	ViewVector.Z = 0.0;
	ViewVector = Normal(ViewVector);
	ViewVector = ViewVector << RotationOffset;
	UpperRot = Rotator(ViewVector);
	SetJointRot(0, RotationOffset);
	SetJointRot(2, UpperRot);
	LoopAnimWithProxy(A_Run, 1.0, Tween);

	//LoopAnim('run', 1.0, Tween);
	if(AnimProxy != None)
	{
		//AnimProxy.LoopAnim('spin_cycle', 1.0, 0.5);
		//AnimProxy.PlayAnim('fire_windup', 1.0, 0.1);
	}
}

function PlayWaiting(optional float tween)
{
	LoopAnimWithProxy(A_Idle, 1.0, Tween);
}

function PlayAltFiring()
{
	LoopAnimWithProxy(A_SpinCycle, 1.0, 0.5);
}

function PlayDuck(optional float tween)
{
	LoopAnimWithProxy(A_SawCycle, 1.0, 0.1);
}

exec function Throw()
{
	if(AnimProxy.GetStateName() == 'Aiming')
	{
		AnimProxy.GotoState('UnAiming');
		return;
	}
	AnimProxy.GotoState('Aiming');
}

/**
*	SelectDirectionalAttackAnimation (override)
*	Select DwarfMesh-specific attack animations
*/
function Name SelectDirectionalAttackAnimation(int AttackDirection, int AttackChainIndex)
{
	switch(AttackDirection)
	{
		case AD_Forward:
		case AD_Backward:
		case AD_Neutral:
			return A_AttackA;
		case AD_Left:
			return A_AttackB;
		case AD_Right:
			return A_AttackB;
	}
	return 'None';
}

defaultproperties
{
	Skeletal=SkelModel'RCreatures.RDwarfMech'
	CollisionRadius=50.000000
	CollisionHeight=47.000000
	Mass=250.000000
    Buoyancy=200.000000
}