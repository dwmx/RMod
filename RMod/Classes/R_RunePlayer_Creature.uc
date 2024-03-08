//==============================================================================
//  R_RunePlayer_Creature
//==============================================================================
class R_RunePlayer_Creature extends R_RunePlayer config(RMod);

// These are for dwarf skel
const SKELGROUP_TORSO = 1;
const SKELGROUP_HEAD = 2;
const SKELGROUP_NECK_CAP = 8;
const SKELGROUP_ARM_R = 3;
const SKELGROUP_SHOULDER_R = 4;
const SKELGROOP_ARM_CAP_R = 5;
const SKELGROUP_ARM_CAP_L = 6;
const SKELGROUP_SHOULDER_L = 7;
const SKELGROUP_LEG_R = 9;
const SKELGROUP_LEG_L = 10;
const SKELGROUP_ARM_L = 11;
const SKELGROUP_EARS_FACE = 12;

var Name AttachAxeJoint;
var Name AttachSwordJoint;
var Name AttachHammerJoint;

function InstantStow()
{
    Super.InstantStow();
}

function SpawnAnimProxy()
{
    AnimProxy = Spawn(Class'RMod.R_CreaturePlayerProxy', Self);
    ApplyOwnerAndProxySkelGroupFlags();
}

function PlayerRestart()
{
    Super.PlayerRestart();
    ApplyOwnerAndProxySkelGroupFlags();
    AnimProxy.DesiredColorAdjust = DesiredColorAdjust;
}

/**
*   ApplyOwnerAndProxySkelGroupFlags
*   Hides the upper skelgroups of Self, and hides the lower skelgroups
*   of the AnimProxy
*/
function ApplyOwnerAndProxySkelGroupFlags()
{
    local int LowerBodyGroups[2];
    local int UpperBodyGroups[10];
    local int i;

    // Only works with creature proxy
    if(R_CreaturePlayerProxy(AnimProxy) != None)
    {
        // These skelgroups are just for Dwarf at the moment
        // Upper body groups
        UpperBodyGroups[0] = SKELGROUP_TORSO;
        UpperBodyGroups[1] = SKELGROUP_HEAD;
        UpperBodyGroups[2] = SKELGROUP_NECK_CAP;
        UpperBodyGroups[3] = SKELGROUP_ARM_R;
        UpperBodyGroups[4] = SKELGROOP_ARM_CAP_R;
        UpperBodyGroups[5] = SKELGROUP_SHOULDER_R;
        UpperBodyGroups[6] = SKELGROUP_SHOULDER_L;
        UpperBodyGroups[7] = SKELGROUP_ARM_L;
        UpperBodyGroups[8] = SKELGROUP_ARM_CAP_L;
        UpperBodyGroups[9] = SKELGROUP_EARS_FACE;

        // Lower body groups
        LowerBodyGroups[0] = SKELGROUP_LEG_R;
        LowerBodyGroups[1] = SKELGROUP_LEG_L;

        // Hide self's upper body
        for(i = 0; i < 10; ++i)
        {
            SkelGroupFlags[UpperBodyGroups[i]] = POLYFLAG_INVISIBLE;
        }

        // Hide proxy's lower body
        for(i = 0; i < 2; ++i)
        {
            AnimProxy.SkelGroupFlags[LowerBodyGroups[i]] = POLYFLAG_INVISIBLE;
        }
    }
    
}



event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);
}

exec function AltFire( optional float F )
{
    PlayAltFiring();
}

function PlayAltFiring()
{
    if(AnimProxy != None)
    {
        AnimProxy.Defend();
    }
}

/*
function PlayFiring()
{
    if(AnimProxy != None)
    {
        AnimProxy.Attack();
    }

    if(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y >= 1000)
    {
        PlayMoving();
    }
}
*/

/*
function PlayFiring()
{
    if(UpperProxy != None)
    {
        UpperProxy.Attack();
    }

    if(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y >= 1000)
    {
        PlayMoving();
    }
}
*/

function LoopAnimWithProxy(Name AnimName, float Rate, float Tween)
{
    LoopAnim(AnimName, Rate, Tween);
    if(AnimProxy != None)
    {
        AnimProxy.TryLoopAnim(AnimName, Rate, Tween);
    }
}

function PlayAnimWithProxy(Name AnimName, float Rate, float Tween)
{
    PlayAnim(AnimName, Rate, Tween);
    if(AnimProxy != None)
    {
        AnimProxy.TryPlayAnim(AnimName, Rate, Tween);
    }
}

function PlayWaiting(optional float tween)
{
    LoopAnimWithProxy('idleA', RandRange(0.8, 1.2), tween);
}

function PlayMoving(optional float tween)
{
    local MovementDir_e dir;
    local Name anim;

    dir = GetAnimationMovementDirection();

    switch(dir)
    {
    case MD_FORWARD:
        anim = 'runA';
        break;
    case MD_FORWARDRIGHT:
        anim = 'straferight';
        break;
    case MD_FORWARDLEFT:
        anim = 'strafeleft';
        break;
    case MD_BACKWARD:
        anim = 'backupA';
        break;
    case MD_BACKWARDRIGHT:
        anim = 'straferight';
        break;
    case MD_BACKWARDLEFT:
        anim = 'strafeleft';
        break;
    case MD_RIGHT:
        anim = 'straferight';
        break;
    case MD_LEFT:
        anim = 'strafeleft';
        break;
    default:
        break;
    }

    LoopAnimWithProxy(anim, 1.0, 0.1);
}

function PlayJump()
{
    PlayAnimWithProxy('fallingA', 1.0, 0.1);
}

function PlayDuck(optional float tween)
{
    LoopAnimWithProxy('duck', 1.0, 0.1);
}

/*
function PlayFiring()
{
    //Log("Play Firing");
    PlayAnim('attackA',   1.0, 0.1);
}
*/

//function PlayCower(optional float tween)      { LoopAnim  ('cower',     1.0, tween);  Log("PlayCower");  }
//function PlayThrowing(optional float tween)   { PlayAnim  ('throwB',   1.0, tween); Log("PlayThrowing"); }
//function PlayTaunting(optional float tween)   { PlayAnim  ('pain',      1.0, tween);  Log("PlayTaunting");  }
function PlayInAir(optional float tween)
{
    LoopAnim  ('fallingA',  1.0, tween);
}
function LongFall()
{
    if (AnimSequence != 'fallingC')
        LoopAnim  ('fallingC',  1.0, 0.1);
}
function PlayLanding(optional float tween)
{
    if (AnimSequence == 'fallingC')
        PlayAnim('landingC', 1.0, 0.1);
    else if (AnimSequence == 'fallingB')
        PlayAnim('landingB', 1.0, 0.1);
    else
        PlayAnim('landingA', 1.0, 0.1);
}

/**
*   GetAttachmentParentActor
*   Return the actor that Inventory actors should attach to
*/
function Actor GetAttachmentParentActor()
{
    if(AnimProxy != None)
    {
        // Should always return the AnimProxy for creatures
        return AnimProxy;
    }
    return Self;
}

/**
*   DropWeapon (override)
*   Overridden to detach weapon from AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function DropWeapon()
{
    local Actor ParentActor;
    local int AttachedJoint;
    local Vector X, Y, Z;

    if(Weapon == None)
    {
        return;
    }

    if(Weapon.bPoweredUp)
    {
        Weapon.PowerupEnd();
    }

    ParentActor = GetAttachmentParentActor();
    AttachedJoint = ParentActor.JointNamed(WeaponJoint);

    if(AttachedJoint != 0)
    {
        ParentActor.DetachActorFromJoint(AttachedJoint);

        GetAxes(Rotation, X, Y, Z);
        Weapon.DropFrom(GetJointPos(AttachedJoint));

        if(Weapon != None)
        {
            Weapon.SetPhysics(PHYS_Falling);
            Weapon.Velocity = Y * 100 + X * 75;
            Weapon.Velocity.Z = 50;
            Weapon.GotoState('Drop');
            Weapon.DisableSwipeTrail();

            DeleteInventory(Weapon);
        }
    }
}

/**
*   DropShield (override)
*   Overridden to detach shield from AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function DropShield()
{
    local Actor ParentActor;
    local int AttachedJoint;
    local Vector X, Y, Z;

    if(Shield == None)
    {
        return;
    }

    ParentActor = GetAttachmentParentActor();
    AttachedJoint = ParentActor.JointNamed(ShieldJoint);

    if(AttachedJoint != 0)
    {
        ParentActor.DetachActorFromJoint(AttachedJoint);

        GetAxes(Rotation, X, Y, Z);

        Shield.DropFrom(GetJointPos(AttachedJoint));
        Shield.SetPhysics(PHYS_Falling);
        Shield.Velocity = Y * 100 + X * 75;
        Shield.Velocity.Z = 50;
        Shield.GoToState('Drop');

        DeleteInventory(Shield);
    }
}

/**
*   SelectWeapon (override)
*   Overridden to attach selected weapons to the AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function SelectWeapon(Weapon NewWeapon)
{
    local Actor ParentActor;
    local int AttachJoint;

    Weapon = NewWeapon;

    ParentActor = GetAttachmentParentActor();

    AttachJoint = ParentActor.JointNamed(WeaponJoint);
    if(AttachJoint != 0)
    {
        ParentActor.AttachActorToJoint(Weapon, AttachJoint);
    }
}

/**
*   StowWeapon (override)
*   Overridden to attach stowed weapons to the AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function StowWeapon(Weapon OldWeapon)
{
    local Actor ParentActor;
    local int StowAttachJoint;
    local int EquipAttachJoint;
    local int StowIndex;

    if(Weapon == None)
    {
        return;
    }

    ParentActor = GetAttachmentParentActor();

    switch(Weapon.MeleeType)
    {
    case MELEE_SWORD:   
        StowAttachJoint = ParentActor.JointNamed(AttachSwordJoint);
        break;
    case MELEE_AXE:
        StowAttachJoint = ParentActor.JointNamed(AttachAxeJoint);
        break;
    case MELEE_HAMMER:
        StowAttachJoint = ParentActor.JointNamed(AttachHammerJoint);
        break;
    default:
        StowAttachJoint = 0;
        break;
    }

    EquipAttachJoint = ParentActor.JointNamed(WeaponJoint);

    if(StowAttachJoint != 0 && EquipAttachJoint != 0)
    {
        ParentActor.DetachActorFromJoint(EquipAttachJoint);
        ParentActor.AttachActorToJoint(Weapon, StowAttachJoint);

        if(R_RunePlayerProxy(AnimProxy) != None)
        {
            StowIndex = R_RunePlayerProxy(AnimProxy).GetStowIndex(Weapon);
        }
        SetStowedWeapon(StowIndex, Weapon);
        Weapon.GoToState('Stow');
        Weapon = None;
    }
}

/**
*   RetrieveWeapon (override)
*   Overridden to attach retrieved weapons to the AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function RetrieveWeapon(int StowIndex)
{
    local Actor ParentActor;
    local int StowAttachJoint;
    local Weapon CurrentWeapon;
    local Weapon NextWeapon;

    ParentActor = GetAttachmentParentActor();

    switch(StowIndex)
    {
    case 0: // MELEE_SWORD
        StowAttachJoint = ParentActor.JointNamed(AttachSwordJoint); // Compensate for a spelling error...  for now.
        break;
    case 1: // MELEE_HAMMER
        StowAttachJoint = ParentActor.JointNamed(AttachHammerJoint);
        break;
    case 2: // MELEE_AXE
        StowAttachJoint = ParentActor.JointNamed(AttachAxeJoint);
        break;
    default:
        StowAttachJoint = 0;
        break;
    }

    CurrentWeapon = GetStowedWeapon(StowIndex);
    if(StowAttachJoint != 0 && CurrentWeapon != None)
    {
        ParentActor.DetachActorFromJoint(StowAttachJoint);
        SelectWeapon(CurrentWeapon);

        SetStowedWeapon(StowIndex, None);
        NextWeapon = GetNextWeapon(CurrentWeapon);
        if(NextWeapon != None && NextWeapon != CurrentWeapon)
        {
            ParentActor.AttachActorToJoint(NextWeapon, StowAttachJoint);
            NextWeapon.bHidden = false;
            SetStowedWeapon(StowIndex, NextWeapon);
        }
    }
}

/**
*   SwapStowToNext (override)
*   Overridden to attach stowed weapons to the AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function SwapStowToNext(int StowIndex)
{
    local Actor ParentActor;
    local int StowAttachJoint;
    local Weapon StowedWeapon;
    local Weapon NextWeapon;

    ParentActor = GetAttachmentParentActor();

    StowedWeapon = GetStowedWeapon(StowIndex);
    if(StowedWeapon != None)
    {
        NextWeapon = GetNextWeapon(StowedWeapon);
        if(NextWeapon != None && NextWeapon != StowedWeapon)
        {
            StowedWeapon.bHidden = true;
            NextWeapon.bHidden = false;

            switch(StowIndex)
            {
            case 0: // MELEE_SWORD
                StowAttachJoint = ParentActor.JointNamed(AttachSwordJoint); // Compensate for a spelling error...  for now.
                break;
            case 1: // MELEE_HAMMER
                StowAttachJoint = ParentActor.JointNamed(AttachHammerJoint);
                break;
            case 2: // MELEE_AXE
                StowAttachJoint = ParentActor.JointNamed(AttachAxeJoint);
                break;
            default:
                StowAttachJoint = 0;
                break;
            }

            if(StowAttachJoint != 0)
            {
                ParentActor.DetachActorFromJoint(StowAttachJoint);
                ParentActor.AttachActorToJoint(NextWeapon, StowAttachJoint);
                SetStowedWeapon(StowIndex, NextWeapon);
            }
        }
    }
}

defaultproperties
{
    GroundSpeed=240.000000
    AccelRate=1000.000000
    JumpZ=400.000000
    MaxStepHeight=30.000000
    WalkingSpeed=160.000000
    HitSound1=Sound'CreaturesSnd.Dwarves.hit02'
    HitSound2=Sound'CreaturesSnd.Dwarves.word26'
    HitSound3=Sound'CreaturesSnd.Dwarves.hit07'
    Die=Sound'CreaturesSnd.Dwarves.death09'
    Die2=Sound'CreaturesSnd.Dwarves.death10'
    Die3=Sound'CreaturesSnd.Dwarves.death12'
    FootStepWood(0)=None
    FootStepWood(1)=None
    FootStepWood(2)=None
    FootStepMetal(0)=Sound'FootstepsSnd.Metal.footmetal10'
    FootStepMetal(1)=Sound'FootstepsSnd.Metal.footmetal11'
    FootStepMetal(2)=Sound'FootstepsSnd.Metal.footmetal12'
    FootStepStone(0)=Sound'FootstepsSnd.Earth.footgravel13'
    FootStepStone(1)=Sound'FootstepsSnd.Earth.footgravel12'
    FootStepStone(2)=Sound'FootstepsSnd.Earth.footgravel13'
    FootStepIce(0)=Sound'FootstepsSnd.Ice.footice04'
    FootStepIce(1)=Sound'FootstepsSnd.Ice.footice05'
    FootStepIce(2)=Sound'FootstepsSnd.Ice.footice06'
    FootStepEarth(0)=Sound'FootstepsSnd.Earth.footgravel03'
    FootStepEarth(1)=Sound'FootstepsSnd.Earth.footgravel05'
    FootStepEarth(2)=Sound'FootstepsSnd.Earth.footgravel06'
    FootStepSnow(0)=Sound'FootstepsSnd.Snow.footsnow10'
    FootStepSnow(1)=Sound'FootstepsSnd.Snow.footsnow11'
    FootStepSnow(2)=Sound'FootstepsSnd.Snow.footsnow12'
    WeaponJoint=attach_hand
    ShieldJoint=attach_shielda
    CollisionRadius=35.000000
    CollisionHeight=33.000000
    Skeletal=SkelModel'creatures.Dwarf'
    SpawnableAnimationProxyClass=None
    bFrameNotifies=true
    AttachAxeJoint=attach_axe
    AttachSwordJoint=attatch_sword
    AttachHammerJoint=attach_hammer
}

/*
var R_CreatureProxy CreatureProxyBase;
var R_CreatureProxy CreatureProxyUpper;
var R_CreatureProxy CreatureProxyLower;

replication
{
    reliable if(Role == ROLE_Authority)
        CreatureProxyBase,
        CreatureProxyUpper,
        CreatureProxyLower;
}

function PlayJump()
{
    PlayAnim('fallingA', 1.0, 0.1);
}

function PlayDuck(optional float tween)
{
    LoopAnim('duck', 1.0, 0.1);
}

/*
function PlayFiring()
{
    //Log("Play Firing");
    PlayAnim('attackA',   1.0, 0.1);
}
*/


function PlayAttack1(optional float tween)  { PlayAnim('attackA',   1.0, tween);   Log("PlayAttack1");  }
function PlayAttack2(optional float tween)  { PlayAnim('attackB',   1.0, tween);   Log("PlayAttack2");  }
function PlayAttack3(optional float tween)  { PlayAnim('attackC',   1.0, tween);   Log("PlayAttack3");  }

function PlayCower(optional float tween)      { LoopAnim  ('cower',     1.0, tween);  Log("PlayCower");  }
function PlayThrowing(optional float tween)   { PlayAnim  ('throwB',   1.0, tween); Log("PlayThrowing"); }
function PlayTaunting(optional float tween)   { PlayAnim  ('pain',      1.0, tween);  Log("PlayTaunting");  }
function PlayInAir(optional float tween)
{
    LoopAnim  ('fallingA',  1.0, tween);
}
function LongFall()
{
    if (AnimSequence != 'fallingC')
        LoopAnim  ('fallingC',  1.0, 0.1);
}
function PlayLanding(optional float tween)
{
    if (AnimSequence == 'fallingC')
        PlayAnim('landingC', 1.0, 0.1);
    else if (AnimSequence == 'fallingB')
        PlayAnim('landingB', 1.0, 0.1);
    else
        PlayAnim('landingA', 1.0, 0.1);
}

function PlayDodgeLeft(optional float tween)  { PlayAnim  ('runA',   1.0, tween);  Log("PlayDodgeLeft");  }
function PlayDodgeRight(optional float tween) { PlayAnim  ('runA',   1.0, tween);  Log("PlayDodgeRight");  }
function PlayDodgeForward(optional float tween){PlayAnim  ('runA',   1.0, tween);  Log("PlayDodgeForward");  }
function PlayDodgeBack(optional float tween)  { PlayAnim  ('runA',   1.0, tween);  Log("PlayDodgeBack");  }
function PlayDodgeBackflip(optional float tween){PlayAnim ('jump',   1.0, tween);  Log("PlayDodgeBackflip");  }
function PlayDodgeDuck(optional float tween)  { PlayAnim  ('duck',   1.0, tween);  Log("PlayDodgeDuck");  }
function PlayBlockHigh(optional float tween)  { LoopAnim  ('duck',   1.0, tween);  Log("PlayBlockHigh");  }
function PlayBlockLow(optional float tween)   { LoopAnim  ('block',  1.0, tween);  Log("PlayBlockLow");  }

function PlayFrontHit(float tweentime){}
function PlayHeadHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);  Log("PlayHeadHit");  }
function PlayBodyHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);  Log("PlayBodyHit");  }
function PlayLArmHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);  Log("PlayLArmHit");  }
function PlayRArmHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);   Log("PlayRArmHit"); }
function PlayLLegHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);  Log("PlayLLegHit");  }
function PlayRLegHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);  Log("PlayRLegHit");  }
function PlayDrowning(optional float tween)   { LoopAnim  ('drown',  1.0, tween);   }

function PlayBackDeath(name DamageType)       { PlayAnim  ('deathf', 1.0, 0.1);    Log("PlayBackDeath");  }
function PlayLeftDeath(name DamageType)       { PlayAnim  ('deathl', 1.0, 0.1);    Log("PlayLeftDeath");  }
function PlayRightDeath(name DamageType)      { PlayAnim  ('deathr', 1.0, 0.1);    Log("PlayRightDeath");  }
function PlayHeadDeath(name DamageType)       { PlayAnim  ('deathf', 1.0, 0.1);    Log("PlayHeadDeath");  }
function PlayDeath(name DamageType)           { PlayAnim  ('deatha', 1.0, 0.1);    Log("PlayDeath");  }
function PlayDrownDeath(name DamageType)      { PlayAnim  ('drown_death', 1.0, 0.1);Log("PlayDrownDeath"); }
function PlaySkewerDeath(name DamageType)     { PlayAnim  ('deaths', 1.0, 0.1);    Log("PlaySkewerDeath");  }

defaultproperties
{
    GroundSpeed=240.000000
    AccelRate=1000.000000
    JumpZ=400.000000
    MaxStepHeight=30.000000
    WalkingSpeed=160.000000
    HitSound1=Sound'CreaturesSnd.Dwarves.hit02'
    HitSound2=Sound'CreaturesSnd.Dwarves.word26'
    HitSound3=Sound'CreaturesSnd.Dwarves.hit07'
    Die=Sound'CreaturesSnd.Dwarves.death09'
    Die2=Sound'CreaturesSnd.Dwarves.death10'
    Die3=Sound'CreaturesSnd.Dwarves.death12'
    FootStepWood(0)=None
    FootStepWood(1)=None
    FootStepWood(2)=None
    FootStepMetal(0)=Sound'FootstepsSnd.Metal.footmetal10'
    FootStepMetal(1)=Sound'FootstepsSnd.Metal.footmetal11'
    FootStepMetal(2)=Sound'FootstepsSnd.Metal.footmetal12'
    FootStepStone(0)=Sound'FootstepsSnd.Earth.footgravel13'
    FootStepStone(1)=Sound'FootstepsSnd.Earth.footgravel12'
    FootStepStone(2)=Sound'FootstepsSnd.Earth.footgravel13'
    FootStepIce(0)=Sound'FootstepsSnd.Ice.footice04'
    FootStepIce(1)=Sound'FootstepsSnd.Ice.footice05'
    FootStepIce(2)=Sound'FootstepsSnd.Ice.footice06'
    FootStepEarth(0)=Sound'FootstepsSnd.Earth.footgravel03'
    FootStepEarth(1)=Sound'FootstepsSnd.Earth.footgravel05'
    FootStepEarth(2)=Sound'FootstepsSnd.Earth.footgravel06'
    FootStepSnow(0)=Sound'FootstepsSnd.Snow.footsnow10'
    FootStepSnow(1)=Sound'FootstepsSnd.Snow.footsnow11'
    FootStepSnow(2)=Sound'FootstepsSnd.Snow.footsnow12'
    WeaponJoint=attach_hand
    ShieldJoint=attach_shielda
    CollisionRadius=35.000000
    CollisionHeight=33.000000
    Skeletal=SkelModel'creatures.Dwarf'
    SpawnableAnimationProxyClass=None
    bFrameNotifies=true
}
*/