//==============================================================================
//	R_CreaturePlayer_Dwarf
//	Playable Dwarf
//==============================================================================
class R_CreaturePlayer_Dwarf extends R_CreaturePlayer;

// RDwarf.scm is Rune's original Dwarf model reimported with upper/lower joint
// groups necessary for AnimProxy to control upper body animation
#exec SKELETAL IMPORT NAME=RDwarf FILE=..\RCreatures\Models\RDwarf.scm
#exec SKELETAL ORIGIN NAME=RDwarf X=0 Y=0 Z=-4 Pitch=0 Yaw=-64 Roll=-64

// Animation names for the Dwarf SkelModel
const A_IdleA 		= 'idleA';
const A_IdleB 		= 'dd_idleB';
const A_RunForward 	= 'runA';
const A_RunRight 	= 'straferight';
const A_RunLeft 	= 'strafeleft';
const A_RunBackward = 'backupA';
const A_FallingA 	= 'fallingA';
const A_FallingB 	= 'fallingB';
const A_FallingC 	= 'fallingC';
const A_LandingA 	= 'landingA';
const A_LandingB 	= 'landingB';
const A_LandingC 	= 'landingC';
const A_Duck 		= 'duck';
const A_Damage 		= 'Damage';
const A_Drown 		= 'drown';
const A_DeathA 		= 'deathA';
const A_DeathF 		= 'DeathF';
const A_DeathS 		= 'Deaths';
const A_DeathR 		= 'DeathR';
const A_DeathL 		= 'deathL';
const A_DrownDeath 	= 'drown_death';
const A_TalkA 		= 'talkA';
const A_TalkB 		= 'talkB';
const A_GetWeapon 	= 'GetWeapon';
const A_Throw 		= 'Throw';
const A_ThrowB 		= 'ThrowB';
const A_AttackA		= 'AttackA';
const A_AttackB		= 'AttackB';
const A_AttackC		= 'AttackC';
const A_Block		= 'block';
const A_ToBlock 	= 'TOblock';

//==============================================================================
//	Animation related functions
//==============================================================================
/**
*	GetDwarfAnimationForMovementDirection
*	Returns a Dwarf animation for the associated movement direction enum
*/
function Name GetDwarfAnimationForMovementDirection(MovementDir_e MovementDir)
{
    switch(MovementDir)
    {
    case MD_FORWARD:
        return A_RunForward;
    case MD_BACKWARD:
        return A_RunBackward;
    case MD_FORWARDLEFT:
    case MD_LEFT:
    case MD_BACKWARDLEFT:
        return A_RunLeft;
    case MD_FORWARDRIGHT:
    case MD_RIGHT:
    case MD_BACKWARDRIGHT:
        return A_RunRight;
    }

    return A_IdleA;
}

/**
*   SelectTauntAnim (override)
*   Select a random Dwarf animation to play when the player wants to taunt
*/
function Name SelectTauntAnim()
{
    local Name AnimToPlay;
    local int RandIndex;

    RandIndex = RandRange(0, 3);
    switch(RandIndex)
    {
    case 0:
        AnimToPlay = A_TalkA;
        break;
    case 1:
        AnimToPlay = A_TalkB;
        break;
    case 2:
        AnimToPlay = A_IdleB;
        break;
    }

    return AnimToPlay;
}

/**
*   SelectThrowAnim (override)
*   Called by anim proxy to select the throw animation to play
*   when throwing the current weapon.
*/
function Name SelectThrowAnim()
{
    if(Weapon != None && Shield == None)
    {
        if(Weapon.A_Defend == 'None')
        {
            return A_ThrowB;
        }
    }
    return A_Throw;
}

/**
*	SelectPickupAnim (override)
*/
function SelectPickupAnim(out Name OutAnimToPlay, out float OutAnimRate)
{
    if(UseActor != None)
    {
        if(Shield(UseActor) != None || Runes(UseActor) != None)
        {
            OutAnimToPlay = A_ToBlock;
            OutAnimRate = 1.0;
            return;
        }
    }

    OutAnimToPlay = A_GetWeapon;
    OutAnimRate = 1.5;
}

/**
*	SelectDirectionalAttackAnimation (override)
*	Select Dwarf-specific attack animations
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
			return A_AttackC;
	}
	return 'None';
}

/**
*	SelectDefendAnimation (override)
*	Select Dwarf-specific defend animation
*/
function Name SelectDefendAnimation()
{
	return A_Block;
}

//==============================================================================
//	PlayAnimation function overrides
//==============================================================================
function PlayWaiting(optional float Tween)
{
    LoopAnimWithProxy(A_IdleA, RandRange(0.8, 1.2), Tween);
}

function PlayMoving(optional float Tween)
{
    local MovementDir_e MovementDir;
    local Name MovingAnim;

    MovementDir = GetAnimationMovementDirection();
    MovingAnim = GetDwarfAnimationForMovementDirection(MovementDir);

    LoopAnimWithProxy(MovingAnim, 1.0, 0.1);
}

function PlayJump()
{
    PlayAnimWithProxy(A_FallingA, 1.0, 0.1);
}

function PlayDuck(optional float tween)
{
    LoopAnimWithProxy(A_Duck, 1.0, 0.1);
}

function PlayInAir(optional float Tween)
{
    LoopAnimWithProxy(A_FallingA, 1.0, Tween);
}

function PlayFalling(optional float Tween)
{
    if(Velocity.Z < -1000.0)
    {
        LoopAnimWithProxy(A_FallingC, 1.0, Tween);
    }
}

function PlayLongFalling(optional float Tween)
{
    LoopAnimWithProxy(A_FallingC, 1.0, 0.1);
}

function PlayLanding(optional float Tween)
{
    if(AnimSequence == A_FallingC)
    {
        PlayAnimWithProxy(A_LandingC, 1.0, 0.1);
    }
    else if(AnimSequence == A_FallingB)
    {
        PlayAnimWithProxy(A_LandingB, 1.0, 0.1);
    }
    else
    {
        PlayAnimWithProxy(A_LandingA, 1.0, 0.1);
    }
}

function PlayFellDeath(Name DamageType)
{
    local Name AnimToPlay;

    if(AnimSequence == A_FallingB)
    {
        AnimToPlay = A_LandingB;
    }
    else
    {
        AnimToPlay = A_LandingC;
    }

    PlayAnimWithProxy(AnimToPlay, 1.0, 0.1);
}

function PlayDeath(Name DamageType)
{
    local Name AnimToPlay;
    local int RandIndex;

    RandIndex = RandRange(0, 5);
    switch(RandIndex)
    {
    case 0: AnimToPlay = A_DeathS; break;
    case 1: AnimToPlay = A_DeathF; break;
    case 2: AnimToPlay = A_DeathA; break;
    case 3: AnimToPlay = A_DeathR; break;
    case 4: AnimToPlay = A_DeathL; break;
    }

    PlayAnimWithProxy(AnimToPlay, 1.0, 0.1);
}

function PlayDrownDeath(Name DamageType)
{
    PlayAnimWithProxy(A_DrownDeath, 1.0, 0.1);
}

function PlayFrontHit(optional float Tween)
{
    PlayAnimWithProxy(A_Damage, 1.0, 0.1);
}

function PlayDrowning(optional float Tween)
{
    PlayAnimWithProxy(A_Drown, 1.0, 0.1);
}
//==============================================================================

defaultproperties
{
    Skeletal=SkelModel'RMod.RDwarf'
    SkelMesh=2
}