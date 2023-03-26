//==============================================================================
//  R_AWeapon
//  Abstract base weapon class which implements core RMod weapon functionality.
//==============================================================================
class R_AWeapon extends Weapon abstract;

var Class<R_AUtilities> UtilitiesClass;

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



state Throw
{
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
                // Weapon deflection during shield bash
                if(P.Shield != None && R_AShield(P.Shield) != None && P.AnimProxy.GetStateName() == 'Attacking' && P.Shield.GetStateName() == 'Swinging')
                {
                    R_AShield(P.Shield).PlayHitEffect(Self, HitLoc, Normal(Location - P.Shield.Location), 0, 0);
                    P.Shield.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Velocity*Mass, ThrownDamageType, 0);
                    Velocity = -Velocity;
                    Instigator = P;
                    SetOwner(P); // Necessary in order to hit the original thrower
                    return;
                }
                
                if(P.Shield != None && P.AnimProxy.GetStateName() == 'Defending')
                {
                    HitActor = P.Shield;
                }
                else if(P.Weapon != None && P.AnimProxy.GetStateName() == 'Attacking')
                {
                    HitActor = P.Weapon;
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

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
}