//==============================================================================
//  R_AWeapon
//  Abstract base weapon class which implements core RMod weapon functionality.
//==============================================================================
class R_AWeapon extends Weapon abstract;

var Class<R_AUtilities> UtilitiesClass;
var Class<R_AGameOptionsChecker> GameOptionsCheckerClass;

// Weapon tier, valid for values 1-5
// Tier1 weapons = hand axe, bone club, short sword
// Tier2...Tier3
// Tier5 weapons = battle axe, battle sword, battle hammer
// These are used to allow the GameOptions class to specify which weapons
// are throw-blockable, based on the weapon's size.
var int WeaponTier;

//==============================================================================
//  Additional sound variables that correspond with Weapon
var int NumIceSounds;
var(Sounds) Sound HitIce[3];
//==============================================================================

//==============================================================================
//  Hit effect classes for different matter types
//  Access via GetHitEffectClassForMatterType
var Class<Actor> HitFleshEffectClass;
var Class<Actor> HitWoodEffectClass;
var Class<Actor> HitStoneEffectClass;
var Class<Actor> HitMetalEffectClass;
var Class<Actor> HitDirtEffectClass;
var Class<Actor> HitShieldEffectClass;
var Class<Actor> HitWeaponEffectClass;
var Class<Actor> HitBreakableWoodEffectClass;
var Class<Actor> HitBreakableStoneEffectClass;
var Class<Actor> HitIceEffectClass;
var Class<Actor> HitWaterEffectClass;
//==============================================================================

//==============================================================================
//  Client-side simulation variables
//==============================================================================
struct FNetReplicatedWeaponRotator
{
    var bool bPerformedUpdate;
    var float Yaw;
    var float Pitch;
    var float Roll;
};

struct FNetReplicatedWeaponRotationState
{
    var bool bPerformedUpdate;
    var bool bRotateToDesired;
    var bool bFixedRotationDir;
};

var FNetReplicatedWeaponRotator AuthorityRotation;
var FNetReplicatedWeaponRotator AuthorityDesiredRotation;
var FNetReplicatedWeaponRotator AuthorityRotationRate;

var FNetReplicatedWeaponRotationState AuthorityRotationState;

var Vector AuthorityLocation;
var Name AuthorityStateName;
//==============================================================================

replication
{
    reliable if(Role == ROLE_Authority)
        AuthorityRotation,
        AuthorityDesiredRotation,
        AuthorityRotationRate,
        AuthorityRotationState,
        AuthorityLocation,
        AuthorityStateName;
}

/**
*   PostBeginPlay (override)
*   Overridden to implement ice hit sounds the same way all other matter hit
*   sounds are implemented in Engine.Weapon.
*/
event PostBeginPlay()
{
    local int i;

    Super.PostBeginPlay();

    for(i = 0; i < 3; ++i)
    {
        if(HitIce[i] != None)
        {
            ++NumIceSounds;
        }
    }
    
    SpawnWeaponSwipe();
}

/**
*   Tick (override)
*   Overridden to replicate variables for smooth simulation on clients
*/
simulated event Tick(float DeltaSeconds)
{
    if(Role < ROLE_Authority)
    {
        // Perform replication update for clients
        PerformReplicatedUpdate(DeltaSeconds);
    }
    else if(Role == ROLE_Authority && RemoteRole >= ROLE_SimulatedProxy)
    {
        AuthorityLocation = Location;
        AuthorityStateName = GetStateName();
    }
}

function ReplicateRotation()
{
    AuthorityRotation.Yaw = Rotation.Yaw;
    AuthorityRotation.Pitch = Rotation.Pitch;
    AuthorityRotation.Roll = Rotation.Roll;
    AuthorityRotation.bPerformedUpdate = false;
}

function ReplicateDesiredRotation()
{
    AuthorityDesiredRotation.Yaw = DesiredRotation.Yaw;
    AuthorityDesiredRotation.Pitch = DesiredRotation.Pitch;
    AuthorityDesiredRotation.Roll = DesiredRotation.Roll;
    AuthorityDesiredRotation.bPerformedUpdate = false;
}

function ReplicateRotationRate()
{
    AuthorityRotationRate.Yaw = RotationRate.Yaw;
    AuthorityRotationRate.Pitch = RotationRate.Pitch;
    AuthorityRotationRate.Roll = RotationRate.Roll;
    AuthorityRotationRate.bPerformedUpdate = false;
}

function ReplicateRotationState()
{
    AuthorityRotationState.bRotateToDesired = bRotateToDesired;
    AuthorityRotationState.bFixedRotationDir = bFixedRotationDir;
    AuthorityRotationState.bPerformedUpdate = false;
}

simulated function PerformReplicatedUpdate(float DeltaSeconds)
{
    PerformReplicatedUpdate_Rotators(DeltaSeconds);
    PerformReplicatedUpdate_Location(DeltaSeconds);
}

simulated function PerformReplicatedUpdate_Rotators(float DeltaSeconds)
{
    local Rotator NewRotation;
    
    if(!AuthorityRotation.bPerformedUpdate)
    {
        NewRotation.Yaw = AuthorityRotation.Yaw;
        NewRotation.Pitch = AuthorityRotation.Pitch;
        NewRotation.Roll = AuthorityRotation.Roll;
        SetRotation(NewRotation);
        AuthorityRotation.bPerformedUpdate = true;
    }
    
    if(!AuthorityDesiredRotation.bPerformedUpdate)
    {
        DesiredRotation.Yaw = AuthorityDesiredRotation.Yaw;
        DesiredRotation.Pitch = AuthorityDesiredRotation.Pitch;
        DesiredRotation.Roll = AuthorityDesiredRotation.Roll;
        AuthorityDesiredRotation.bPerformedUpdate = true;
    }
    
    if(!AuthorityRotationRate.bPerformedUpdate)
    {
        RotationRate.Yaw = AuthorityRotationRate.Yaw;
        RotationRate.Pitch = AuthorityRotationRate.Pitch;
        RotationRate.Roll = AuthorityRotationRate.Roll;
        AuthorityRotationRate.bPerformedUpdate = true;
    }
    
    if(!AuthorityRotationState.bPerformedUpdate)
    {
        bRotateToDesired = AuthorityRotationState.bRotateToDesired;
        bFixedRotationDir = AuthorityRotationState.bFixedRotationDir;
        AuthorityRotationState.bPerformedUpdate = true;
    }
}

simulated function PerformReplicatedUpdate_Location(float DeltaSeconds)
{
    local Vector Delta;
    local float DeltaLength;
    local Vector AdjustedLocation;
    
    Delta = AuthorityLocation - Location;
    
    //if(AuthorityStateName == 'Throw')
    //{
    //    // During throws, only adjust if it's really bad
    //    DeltaLength = VSize(Delta);
    //    if(DeltaLength > 64.0)
    //    {
    //        AdjustedLocation = AuthorityLocation;
    //        SetLocation(AdjustedLocation);
    //    }
    //}
    //else if(AuthorityStateName == 'Settling')
    //{
    //    // During settling, ease towards the location
    //    AdjustedLocation = Location + (Delta * DeltaSeconds * 10.0);
    //    SetLocation(AdjustedLocation);
    //}
    
}

/**
*   SpawnWeaponSwipe
*   Spawns the multiplayer-compatible weapon swipe actor. See R_WeaponSwipe for more details
*/
function SpawnWeaponSwipe()
{
    if(Role == ROLE_Authority)
    {
        Spawn(Class'RMod.R_WeaponSwipe', Self);
    }
}

/**
*   NotifySubstitutedForInstance
*   Called to notify this Actor that it was spawned as a substitution for
*   another actor. This is where any important property copying should occur.
*/
function NotifySubstitutedForInstance(Actor InActor)
{
    // Disable collide world for correct actor placement
    bCollideWorld = false;

    // Perform important copying
    SetRotation(InActor.Rotation);
    SetLocation(InActor.Location);
    
    bCollideWorld = InActor.bCollideWorld;
}

/**
*   GetMatterTypeForHitActor
*   Returns the matter type for the specified Actor, used during collisions
*/
function EMatterType GetMatterTypeForHitActor(Actor HitActor, Vector HitLoc, int LowMask, int HighMask)
{
    local int i;
    
    if(HitActor == None)
    {
        return MATTER_NONE;
    }
    
    if((HitActor.Skeletal) != None && (LowMask != 0 || HighMask != 0))
    {
        for(i = 0; i < HitActor.NumJoints(); ++i)
        {
            // Copied from Weapon code
            if (((i <  32) && ((LowMask & (1 << i)) != 0)) || ((i >= 32) && (i < 64) && ((HighMask & (1 << (i - 32))) != 0)))
            {   // Joint i was hit
                return HitActor.MatterForJoint(i);
            }
        }   
    }
    else if(HitActor.IsA('LevelInfo'))
    {
        return HitActor.MatterTrace(HitLoc, Owner.Location, WeaponSweepExtent);
    }
    else
    {
        return HitActor.MatterForJoint(0);
    }
}

/**
*   GetHitEffectClassForMatterType
*   Helper function that returns the hit effect class that corresponds to the matter type struck
*/
function Class<Actor> GetHitEffectClassForMatterType(EMatterType MatterType)
{
    local Class<Actor> Result;
    
    // Base selection
    switch(MatterType)
    {
    case MATTER_FLESH:          Result = HitFleshEffectClass;           break;
    case MATTER_WOOD:           Result = HitWoodEffectClass;            break;
    case MATTER_STONE:          Result = HitStoneEffectClass;           break;
    case MATTER_METAL:          Result = HitMetalEffectClass;           break;
    case MATTER_EARTH:          Result = HitDirtEffectClass;            break;
    case MATTER_SHIELD:         Result = HitShieldEffectClass;          break;
    case MATTER_WEAPON:         Result = HitWeaponEffectClass;          break;
    case MATTER_BREAKABLEWOOD:  Result = HitBreakableWoodEffectClass;   break;
    case MATTER_BREAKABLESTONE: Result = HitBreakableStoneEffectClass;  break;
    case MATTER_ICE:            Result = HitIceEffectClass;             break;
    case MATTER_WATER:          Result = HitWaterEffectClass;           break;
    }
    
    // Conditional fall-backs
    if(Result == None)
    {
        if(MatterType == MATTER_BREAKABLEWOOD)          Result = HitWoodEffectClass;
        else if(MatterType == MATTER_WOOD)              Result = HitBreakableWoodEffectClass;
        else if(MatterType == MATTER_BREAKABLESTONE)    Result = HitStoneEffectClass;
        else if(MatterType == MATTER_STONE)             Result = HitBreakableStoneEffectClass;
    }
    
    return Result;
}

/**
*   PlayHitMatterSound (override)
*   Overridden to implement ice hit sounds.
*/
function PlayHitMatterSound(EMatterType Matter)
{
    local int i;

    switch(Matter)
    {
        case MATTER_ICE:
            i = Rand(NumIceSounds);
            PlaySound(HitIce[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
            break;
        case MATTER_SNOW: // Tread snow like dirt for now
        i = Rand(NumIceSounds);
            PlaySound(HitDirt[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
            break;
        default:
            Super.PlayHitMatterSound(Matter);
            break;
    }
}

/**
*   SpawnHitEffect (override)
*   Overridden to clean up and add additional hit effects for matter types that are ignored
*   by original game code.
*/
function SpawnHitEffect(Vector HitLoc, Vector HitNorm, int LowMask, int HighMask, Actor HitActor)
{
    local EMatterType MatterType;
    local Class<Actor> HitEffectClass;
    
    MatterType = GetMatterTypeForHitActor(HitActor, HitLoc, LowMask, HighMask);
    
    // Play sound
    PlayHitMatterSound(MatterType);
    
    // Spawn hit effect
    HitEffectClass = GetHitEffectClassForMatterType(MatterType);
    if(HitEffectClass != None)
    {
        Spawn(HitEffectClass, Self,, HitLoc, Rotator(HitNorm));
    }
    
    // Apply blood texture to weapon
    if(MatterType == MATTER_FLESH)
    {
        SkelGroupSkins[1] = BloodTexture;
    }
}

function InitializeStateRotation()
{

}
    
state Drop
{
    event BeginState()
    {
        RemoteRole = ROLE_SimulatedProxy;
        Super.BeginState();
        InitializeStateRotation();
        ReplicateRotationState();
        ReplicateRotation();
        ReplicateRotationRate();
    }
    
    event EndState()
    {
        RemoteRole = Self.Default.RemoteRole;
        Super.EndState();
    }
}

state Throw
{
    event BeginState()
    {
        RemoteRole = ROLE_SimulatedProxy;
        Super.BeginState();
        bRotateToDesired = false; // Fixes issue where weapons fail to rotate
        ReplicateRotationState();
        ReplicateRotation();
        ReplicateRotationRate();
    }
    
    event EndState()
    {
        RemoteRole = Self.Default.RemoteRole;
        Super.EndState();
    }
    
    //=========================================================================
    //
    // Touch
    // 
    // Touched an actor, does a simple check to see which joints the weapon struck
    //=========================================================================
    function Touch(Actor Other)
    {
        local int hitjoint;
        local vector HitLoc;
        local int DamageAmount;
        local int LowMask, HighMask;
        local actor HitActor;
        local PlayerPawn P;
        local vector VectOther;
        local float dp;
        local bool bThrowBlockable;
        local R_RunePlayer RP;

        if (Other == Owner)
            return;
        if (Owner == None)
            return; // Already hit wall, no more damage after that
        if (Other.IsA('Inventory') && Other.GetStateName() == 'Pickup' && !Other.IsA('Lizard'))
            return;

        AmbientSound = None;

        HitActor = Other;
        DamageAmount = CalculateDamage(HitActor);

        if(Other.IsA('PlayerPawn') && Other.AnimProxy != None)
        {
            P = PlayerPawn(Other);
            // Determine the direction the player is attempting to move
            VectOther = Normal((self.Location - Other.Location) * vect(1, 1, 0));
            dp = vector(P.Rotation) dot VectOther;

            if(dp > 0)
            {
                RP = R_RunePlayer(Other);
                if(RP != None && RP.CheckIsPerformingShieldAttack())
                {
                    // Deflect weapons during a shield bash attack
                    R_AShield(P.Shield).PlayHitEffect(Self, HitLoc, Normal(Location - P.Shield.Location), 0, 0);
                    P.Shield.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Velocity*Mass, ThrownDamageType, 0);
                    Velocity = -Velocity;
                    Instigator = P;
                    SetOwner(P); // Necessary in order to hit the original thrower
                    return;
                }
                else if(P.Shield != None && P.AnimProxy.GetStateName() == 'Defending')
                {
                    // If the struck pawn is defending with a shield, block anything and everything
                    HitActor = P.Shield;
                }
                else if(P.Weapon != None && P.AnimProxy.GetStateName() == 'Attacking')
                {
                    // If the struck pawn is attacking with a weapon, check the throw block rules (based on weapon tier)
                    bThrowBlockable = true;
                    if(GameOptionsCheckerClass != None)
                    {
                        bThrowBlockable = GameOptionsCheckerClass.Static.GetGameOption_WeaponTierBlockable(Self, WeaponTier);
                    }
                    
                    if(bThrowBlockable)
                    {
                        HitActor = P.Weapon;
                    }
                }
            }
        }

        if(SwipeArrayCheck(HitActor, 0, 0))
        {
            if(HitActor.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Velocity*Mass, ThrownDamageType, 0))
            {   // Hit something solid, bounce
            }

            SpawnHitEffect(HitLoc, Normal(Location - HitActor.Location), 0, 0, HitActor);

            SetPhysics(PHYS_Falling);
            RotationRate.Yaw = VSize(Velocity) * 2000 / Mass;
            RotationRate.Pitch = VSize(Velocity) * 2000 / Mass;
            Velocity = -0.1 * Velocity;
        }
    }
}

state Settling
{
    event BeginState()
    {
        RemoteRole = ROLE_SimulatedProxy;
        Super.BeginState();
        ReplicateRotationState();
        ReplicateRotation();
        ReplicateRotationRate();
        ReplicateDesiredRotation();
    }
    
    event EndState()
    {
        RemoteRole = Self.Default.RemoteRole;
        Super.EndState();
    }
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
    GameOptionsCheckerClass=Class'RMod.R_AGameOptionsChecker'
    HitFleshEffectClass=Class'RMod.R_Effect_HitFlesh'
    HitWoodEffectClass=Class'RMod.R_Effect_HitWood'
    HitStoneEffectClass=Class'RMod.R_Effect_HitStone'
    HitMetalEffectClass=Class'RuneI.HitMetal'
    HitDirtEffectClass=Class'RuneI.GroundDust'
    HitShieldEffectClass=Class'RuneI.HitWood'
    HitWeaponEffectClass=Class'RuneI.HitMetal'
    HitBreakableWoodEffectClass=Class'RuneI.HitWood'
    HitBreakableStoneEffectClass=Class'RuneI.HitStone'
    HitIceEffectClass=Class'RMod.R_Effect_HitIce'
    HitWaterEffectClass=None
    WeaponTier=WT_TierNone
}