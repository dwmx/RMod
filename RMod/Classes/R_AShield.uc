//==============================================================================
//  R_AShield
//  Abstract base shield class which implements core RMod shield functionality.
//==============================================================================
class R_AShield extends Shield abstract;

var Class<R_AGameOptionsChecker> GameOptionsCheckerClass;

// Weapon-like collision detection vars
var Vector SweepDirectionVector;
var Vector LastSweepPos1;
var Vector LastSweepPos2;
var float ShieldSweepExtent;
var Name ShieldDamageType;

struct FShieldSwipeHit
{
    var Actor Actor;
    var int LowMask;
    var int HighMask;
};

const SWIPE_HIT_COUNT = 16;
var FShieldSwipeHit SwipeHitArray[16];

// Sounds
var Sound ThroughAir[3];        var int NumThroughAirSounds;
var Sound HitFlesh[3];          var int NumHitFleshSounds;
var Sound HitWood[3];           var int NumHitWoodSounds;
var Sound HitStone[3];          var int NumHitStoneSounds;
var Sound HitMetal[3];          var int NumHitMetalSounds;
var Sound HitDirt[3];           var int NumHitDirtSounds;
var Sound HitShield[3];         var int NumHitShieldSounds;
var Sound HitWeapon[3];         var int NumHitWeaponSounds;
var Sound HitBreakableWood[3];  var int NumHitBreakableWoodSounds;
var Sound HitBreakableStone[3]; var int NumHitBreakableStoneSounds;

var float PitchDeviation;

// Effects
var Class<Actor> HitFleshEffectClass;
var Class<Actor> HitWoodEffectClass;
var Class<Actor> HitStoneEffectClass;
var Class<Actor> HitMetalEffectClass;
var Class<Actor> HitDirtEffectClass;
var Class<Actor> HitShieldEffectClass;
var Class<Actor> HitWeaponEffectClass;
var Class<Actor> HitBreakableWoodEffectClass;
var Class<Actor> HitBreakableStoneEffectClass;

event BeginPlay()
{
    Super.BeginPlay();
    
    InitializeSoundArrays();
}

function InitializeSoundArrays()
{
    local int i;
    
    NumThroughAirSounds = 0;
    NumHitFleshSounds = 0;
    NumHitWoodSounds = 0;
    NumHitStoneSounds = 0;
    NumHitMetalSounds = 0;
    NumHitDirtSounds = 0;
    NumHitShieldSounds = 0;
    NumHitWeaponSounds = 0;
    NumHitBreakableWoodSounds = 0;
    NumHitBreakableStoneSounds = 0;
    
    for(i = 0; i < 3; ++i)
    {
        if(ThroughAir[i] != None)           ++NumThroughAirSounds;
        if(HitFlesh[i] != None)             ++NumHitFleshSounds;
        if(HitWood[i] != None)              ++NumHitWoodSounds;
        if(HitStone[i] != None)             ++NumHitStoneSounds;
        if(HitMetal[i] != None)             ++NumHitMetalSounds;
        if(HitDirt[i] != None)              ++NumHitDirtSounds;
        if(HitShield[i] != None)            ++NumHitShieldSounds;
        if(HitWeapon[i] != None)            ++NumHitWeaponSounds;
        if(HitBreakableWood[i] != None)     ++NumHitBreakableWoodSounds;
        if(HitBreakableStone[i] != None)    ++NumHitBreakableStoneSounds;
    }
}

/**
*   SwipeArray_Clear
*   Clears out all memory of struck actors, allowing actors to be struck again by this shield
*/
function SwipeArray_Clear()
{
    local int i;
    
    for(i = 0; i < SWIPE_HIT_COUNT; ++i)
    {
        SwipeHitArray[i].Actor = None;
        SwipeHitArray[i].LowMask = 0;
        SwipeHitArray[i].HighMask = 0;
    }
}

/**
*   SwipeArray_CheckContains
*   Returns true if the specified actor is currently in the swipe hit array
*/
function bool SwipeArray_CheckContains(Actor A, int LowMask, int HighMask)
{
    local int i;
    
    if(A == None)
    {
        return false;
    }
    
    for(i = 0; i < SWIPE_HIT_COUNT; ++i)
    {
        if(SwipeHitArray[i].Actor == A)
        {
            return true;
        }
    }
    
    return false;
}

/**
*   SwipeArray_Push
*   Places an actor into the swipe hit array
*/
function SwipeArray_Push(Actor A, int LowMask, int HighMask)
{
    local int i;
    
    if(A == None)
    {
        return;
    }
    
    for(i = 0; i < SWIPE_HIT_COUNT; ++i)
    {
        if(SwipeHitArray[i].Actor == None)
        {
            SwipeHitArray[i].Actor = A;
            SwipeHitArray[i].LowMask = LowMask;
            SwipeHitArray[i].HighMask = HighMask;
            return;
        }
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
*   JointDamaged (override)
*   Overridden to implement shield hit stun
*/
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
    local vector AdjMomentum;
    local Pawn P;
    local Pawn POwner;
    local bool bShieldHitStunEnabled;

    PlayHitSound(DamageType);

    // Check if shield hit stun is enabled
    bShieldHitStunEnabled = false;
    if(GameOptionsCheckerClass != None)
    {
        bShieldHitStunEnabled = GameOptionsCheckerClass.Static.GetGameOption_ShieldHitStun(Self);
    }

    // Cause the owner to enter into HitStun
    // Copy from Pawn.DamageBodyPart, to avoid modifying Pawn
    if(Owner != None && Pawn(Owner) != None && bShieldHitStunEnabled && GetStateName() != 'Active' && GetStateName() != 'Swinging')
    {
        POwner = Pawn(Owner);
        if (POwner.GetStateName() != 'Pain' && POwner.GetStateName() != 'pain')
        {
            POwner.NextStateAfterPain = POwner.GetStateName();

            // Play pain anim
            //POwner.PlayTakeHit(0.1, Damage, HitLoc, DamageType, Momentum, joint);
            POwner.PlayTakeHit(0.1, Damage, HitLoc, 'ShieldHit', Momentum, joint);
            POwner.GotoState('Pain');
        }
    }

    if (bBreakable)
    {
        if (Pawn(Owner)!=None && PlayerPawn(Owner)==None && FRand()*Level.Game.Difficulty < 0.2)
        {   // Pawns drop shields once in a while on easier skill levels
            Pawn(Owner).DropShield();
            return false;
        }
            
        Health -= Damage * 0.6;
    }

    // Apply momentum to the shield owner (TODO:  Scale by a percentage?)
    // NOTE:  This code is duplicated in Shield.Idle state, as well as in Pawn
    if(Owner != None)
    {
        AdjMomentum = momentum / Owner.Mass;
        if(Owner.Mass < VSize(AdjMomentum) && Owner.Velocity.Z <= 0)
        {           
            AdjMomentum.Z += (VSize(AdjMomentum) - Owner.Mass) * 0.5;
        }

        P = Pawn(Owner);
        P.AddVelocity(AdjMomentum);

/* CJR TEST -- Recoil animation when hit in the shield
        if(P.CanGotoPainState() && Health > 0)
        { // Recoil from being hit in the shield
            P.NextState = P.GetStateName();
            P.PlayAnim('h3_defendPain', 1.0, 0.01);
            P.GotoState('Pain');
        }
*/
    }

    if(Health <= 0)
    {
        GotoState('Smashed');
        return(true);
    }

    return(false);
}

/**
*   StartAttack
*   Called from R_RunePlayer ShieldActivate function during shield attacks
*/
function StartAttack()
{
    GotoState('Swinging');
}

/**
*   FinishAttack
*   Called from R_RunePlayer ShieldDeactivate function during shield attacks
*/
function FinishAttack()
{
    GotoState('Idle');
}

/**
*   PlaySwipeSound
*   Called from R_RunePlayerProxy ShieldActivate function during shield attacks
*/
function PlaySwipeSound()
{
    //Log("Playing swipe sound");
    PlaySound(ThroughAir[Rand(NumThroughAirSounds)], SLOT_None,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
}

/**
*   ShieldFire
*   Called from R_RunePlayerProxy ShieldActivate function during shield attacks
*   Weapon class appears to use this function only for rune power behavior, so
*   for the moment it does nothing here
*/
function ShieldFire()
{}

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
        return HitActor.MatterTrace(HitLoc, Owner.Location, ShieldSweepExtent);
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
    }
    
    // Conditional fall-backs
    if(Result == None)
    {
        if(MatterType == MATTER_BREAKABLEWOOD)          Result = HitWoodEffectClass;
        else if(MatterType == MATTER_WOOD)              Result = HitBreakableWoodEffectClass;
        else if(MatterType == MATTER_BREAKABLESTONE)    Result = HitStoneEffectClass;
        else if(MatterType == MATTER_STONE)             Result = HitBreakableStoneEffectClass;
        
        // Default
        else                                            Result = HitWoodEffectClass;
    }
    
    return Result;
}

/**
*   GetHitSoundForMatterType
*   Helper function that returns the hit sound that corresponds to the matter type struck
*/
function Sound GetHitSoundForMatterType(EMatterType MatterType)
{
    local Sound Result;
    
    // Base selection
    switch(MatterType)
    {
    case MATTER_FLESH:          Result = HitFlesh[Rand(NumHitFleshSounds)];                   break;
    case MATTER_WOOD:           Result = HitWood[Rand(NumHitWoodSounds)];                     break;
    case MATTER_STONE:          Result = HitStone[Rand(NumHitStoneSounds)];                   break;
    case MATTER_METAL:          Result = HitMetal[Rand(NumHitMetalSounds)];                   break;
    case MATTER_EARTH:          Result = HitDirt[Rand(NumHitDirtSounds)];                     break;
    case MATTER_SHIELD:         Result = HitShield[Rand(NumHitShieldSounds)];                 break;
    case MATTER_WEAPON:         Result = HitWeapon[Rand(NumHitWeaponSounds)];                 break;
    case MATTER_BREAKABLEWOOD:  Result = HitBreakableWood[Rand(NumHitBreakableWoodSounds)];   break;
    case MATTER_BREAKABLESTONE: Result = HitBreakableStone[Rand(NumHitBreakableStoneSounds)]; break;
    }
    
    // Conditional fall-backs
    if(Result == None)
    {
        if(MatterType == MATTER_BREAKABLEWOOD)          Result = HitWood[Rand(NumHitWoodSounds)];
        else if(MatterType == MATTER_WOOD)              Result = HitBreakableWood[Rand(NumHitBreakableWoodSounds)];
        else if(MatterType == MATTER_BREAKABLESTONE)    Result = HitStone[Rand(NumHitStoneSounds)]; 
        else if(MatterType == MATTER_STONE)             Result = HitBreakableStone[Rand(NumHitBreakableStoneSounds)];
        
        // Default
        else                                            Result = HitWood[Rand(NumHitWoodSounds)];
    }
    
    return Result;
}

/**
*   PlayHitEffect
*   Spawn effect when the shield attack hits an actor
*/
function PlayHitEffect(Actor HitActor, Vector HitLoc, Vector HitNorm, int LowMask, int HighMask)
{
    local EMatterType HitMatterType;
    local Sound HitSound;
    local Class<Actor> HitEffectClass;
    
    HitMatterType = GetMatterTypeForHitActor(HitActor, HitLoc, LowMask, HighMask);
    
    // Play hit sound
    HitSound = GetHitSoundForMatterType(HitMatterType);
    if(HitSound != None)
    {
        PlaySound(HitSound, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
    }
    
    // Play hit effect
    HitEffectClass = GetHitEffectClassForMatterType(HitMatterType);
    if(HitEffectClass != None)
    {
        Spawn(HitEffectClass,,, HitLoc, Rotator(HitNorm));
    }
}

/**
*   State Idle (override)
*   Shield is currently equipped by the owner
*/
state Idle
{
    event BeginState()
    {
    }
}

/**
*   State Active (override)
*   Shield is currently equipped by the owner AND it is in the defend state
*/
state Active
{
    event BeginState()
    {
    }
    
    event EndState()
    {
    }
}

/**
*   State Swinging
*   Shield is being used in an attack, needs to check for collisions
*/
state Swinging
{
    event BeginState()
    {
        SwipeArray_Clear();
        LastSweepPos1 = GetJointPos(0) + SweepDirectionVector * 32.0f * 1.0f;
        LastSweepPos2 = GetJointPos(0) + SweepDirectionVector * 32.0f * -1.0f;
    }
    
    event EndState()
    {
    }
    
    event FrameNotify(int framepassed)
    {
        local Vector NewSweepPosition1, NewSweepPosition2, ShieldVector;
        
        NewSweepPosition1 = GetJointPos(0) + SweepDirectionVector * 32.0f * 1.0f;
        NewSweepPosition2 = GetJointPos(0) + SweepDirectionVector * 32.0f * -1.0f;
        ShieldVector = SweepDirectionVector * (VSize(NewSweepPosition2 - NewSweepPosition1));
        
        FrameSweep(framepassed, ShieldVector, LastSweepPos1, LastSweepPos2);
    }
    
    event FrameSwept(Vector B1, Vector E1, Vector B2, Vector E2)
    {
        local Actor A;
        local Vector HitLoc, HitNorm;
        local int LowMask, HighMask;
        
        foreach SweepActors(Class'Actor', A, B1, E1, B2, E2, ShieldSweepExtent, HitLoc, HitNorm, LowMask, HighMask)
        {
            if(CheckShouldActorBeStruckBySwipe(A, LowMask, HighMask))
            {
                HandleSweepCollision(A, LowMask, HighMask, HitLoc, HitNorm);
            }
        }
    }
    
    function bool CheckShouldActorBeStruckBySwipe(Actor A, int LowMask, int HighMask)
    {
        local Actor OwnerIterator;
        
        // Ignore non-sweepables
        if(!A.bSweepable)
        {
            return false;
        }
        
        // Ignore anything that has already been struck
        if(SwipeArray_CheckContains(A, LowMask, HighMask))
        {
            return false;
        }
        
        // Recursively ignore anything owned by this shield's owner
        OwnerIterator = Self;
        while(OwnerIterator != None)
        {
            if(A == OwnerIterator || (A.Owner != None && A.Owner == OwnerIterator))
            {
                return false;
            }
            OwnerIterator = OwnerIterator.Owner;
        }
        
        return true;
    }
    
    function HandleSweepCollision(Actor A, int LowMask, int HighMask, Vector HitLoc, Vector HitNorm)
    {
        local Pawn P;
        local Vector SweepMomentum;
        
        SwipeArray_Push(A, LowMask, HighMask);
        
        //A.JointDamaged(5, Pawn(Owner), HitLoc, SweepMomentum, ShieldDamageType, 0);
        
        // For now, just do a hit stun
        P = Pawn(A);
        if(P != None && P.GetStateName() != 'Pain' && P.GetStateName() != 'pain')
        {
            P.Velocity = P.Velocity * 0.2;
            P.NextStateAfterPain = P.GetStateName();
            P.PlayTakeHit(0.1, 50, HitLoc, 'blunt', SweepMomentum, 0);
            P.GotoState('Pain');
        }
        else if(Weapon(A) != None)
        {
            HandleSweepCollision_Weapon(Weapon(A), LowMask, HighMask, HitLoc, HitNorm);
        }
        
        // Play hit effects (sound and vfx)
        PlayHitEffect(A, HitLoc, HitNorm, LowMask, HighMask);
    }
    
    function HandleSweepCollision_Weapon(Weapon W, int LowMask, int HighMask, Vector HitLoc, Vector HitNorm)
    {
        // Inversion of weapon throw occurs in R_AWeapon.Throw.Touch
    }
}

simulated function Debug(Canvas Canvas, int Mode)
{
    Super.Debug(Canvas, Mode);
    
    Canvas.DrawLine3D(LastSweepPos1, LastSweepPos2, 100, 255, 100);
}

defaultproperties
{
    GameOptionsCheckerClass=Class'RMod.R_AGameOptionsChecker'
    SweepDirectionVector=(X=1.0)
    ShieldSweepExtent=8.0
    ShieldDamageType='blunt'
    ThroughAir(0)=Sound'WeaponsSnd.Swings.bswing02'
    ThroughAir(1)=Sound'WeaponsSnd.Swings.bswing01'
    ThroughAir(2)=Sound'WeaponsSnd.Swings.bswing03'
    HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshhammer02'
    HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood13'
    HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone12'
    HitMetal(0)=Sound'WeaponsSnd.ImpWood.impactcombo03'
    HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth07'
    HitShield(0)=Sound'WeaponsSnd.Shields.shield09'
    HitWeapon(0)=Sound'WeaponsSnd.Swords.sword09'
    HitBreakableWood(0)=Sound'WeaponsSnd.ImpWood.impactwood12'
    HitBreakableStone(0)=Sound'WeaponsSnd.ImpStone.impactstone13'
    PitchDeviation=0.09
    HitFleshEffectClass=Class'BloodMist'
    HitWoodEffectClass=Class'HitStone'
    HitStoneEffectClass=Class'HitStone'
    HitMetalEffectClassClass'HitMetal'
    HitDirtEffectClass=Class'GroundDust'
    HitShieldEffectClass=Class'HitStone'
    HitWeaponEffectClass=Class'HitMetal'
    HitBreakableWoodEffectClass=Class'HitStone'
    HitBreakableStoneEffectClass=Class'HitStone'
}
