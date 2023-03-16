//==============================================================================
//  R_AWeapon
//  Abstract base weapon class which implements core RMod weapon functionality.
//==============================================================================
class R_AWeapon extends Weapon abstract;

var Class<R_AUtilities> UtilitiesClass;

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
            if(Matter == MATTER_SNOW)
            {
                // For now, treat snow like earth
                Matter = MATTER_EARTH;
            }
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