class R_CreaturePlayer_Goblin extends R_RunePlayer_Creature;

const SKELGROUP_GOBLIN_HEAD = 1;
const SKELGROUP_GOBLIN_ARM_L = 2;
const SKELGROUP_GOBLIN_LEG_L = 3;
const SKELGROUP_GOBLIN_LEG_R = 4;
const SKELGROUP_GOBLIN_ARM_CAP_R = 5;
const SKELGROUP_GOBLIN_EYE = 6;
const SKELGROUP_GOBLIN_TORSO = 7;
const SKELGROUP_GOBLIN_SHOULDER_L = 8;
const SKELGROUP_GOBLIN_ARM_CAP_L = 9;
const SKELGROUP_GOBLIN_HEAD_BACK = 11;
const SKELGROUP_GOBLIN_ARM_R = 11;

function SetSkelGroupFlags()
{
    // Hide Self's upper body
    SkelGroupFlags[SKELGROUP_GOBLIN_HEAD] = 1;
    SkelGroupFlags[SKELGROUP_GOBLIN_ARM_L] = 1;
    SkelGroupFlags[SKELGROUP_GOBLIN_ARM_CAP_R] = 1;
    SkelGroupFlags[SKELGROUP_GOBLIN_EYE] = 1;
    SkelGroupFlags[SKELGROUP_GOBLIN_TORSO] = 1;
    SkelGroupFlags[SKELGROUP_GOBLIN_SHOULDER_L] = 1;
    SkelGroupFlags[SKELGROUP_GOBLIN_ARM_CAP_L] = 1;
    SkelGroupFlags[SKELGROUP_GOBLIN_HEAD_BACK] = 1;
    SkelGroupFlags[SKELGROUP_GOBLIN_ARM_R] = 1;

    // Hide Proxy's lower body
    UpperProxy.SkelGroupFlags[SKELGROUP_GOBLIN_LEG_L] = 1;
    UpperProxy.SkelGroupFlags[SKELGROUP_GOBLIN_LEG_R] = 1;
}

function PlayWaiting(optional float tween)
{
    LoopAnimWithProxy('idleA', RandRange(0.8, 1.2), tween);
}

function PlayMoving(optional float tween)
{
    local MovementDir_e dir;
    local Rotator RotationOffset;

    dir = GetAnimationMovementDirection();

    switch(dir)
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
    SetJointRot(0, RotationOffset);
    UpperProxy.SetJointRot(0, RotationOffset);
    LoopAnimWithProxy('w_gallopB', 1.0, 0.1);
}

function PlayInAir(optional float tween)
{
    LoopAnimWithProxy('blockhigh', 1.0, tween);
}

function PlayJump()
{
    PlayAnimWithProxy('jump', 1.0, 0.1);
}

function PlayDodge(eDodgeDir DodgeMove)
{
    local Rotator RotationOffset;

    RotationOffset.Yaw = 0;
    RotationOffset.Pitch = 0;
    RotationOffset.Roll = 0;
    SetJointRot(0, RotationOffset);
    UpperProxy.SetJointRot(0, RotationOffset);

    switch(DodgeMove)
    {
    case EDodgeDir.DODGE_Forward:
        PlayAnimWithProxy('hopA', 1.0, 0.1);
        break;
    case EDodgeDir.DODGE_Back:
        PlayAnimWithProxy('dodgeback', 1.0, 0.1);
        break;
    case EDodgeDir.DODGE_Left:
        PlayAnimWithProxy('rollright', 1.0, 0.1);
        break;
    case EDodgeDir.DODGE_Right:
        PlayAnimWithProxy('rollleft', 1.0, 0.1);
        break;
    }
}

defaultproperties
{
    Skeletal=SkelModel'creatures.Goblin'
}