//==============================================================================
//  R_AWeapon
//  Abstract base weapon class which implements core RMod weapon functionality.
//==============================================================================
class R_AWeapon extends Weapon abstract;

/** Corresponds with other matter sounds in Engine.Weapon */
var int NumIceSounds;
var(Sounds) Sound HitIce[3];

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
        default:
            Super.PlayHitMatterSound(Matter);
            break;
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