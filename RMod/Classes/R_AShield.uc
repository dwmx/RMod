//==============================================================================
//  R_AShield
//  Abstract base shield class which implements core RMod shield functionality.
//==============================================================================
class R_AShield extends Shield abstract;

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
*   CheckIsShieldHitStunEnabled
*   Server-side check of game options to see if shield hit stun is enabled.
*/
function bool CheckIsShieldHitStunEnabled()
{
    local R_GameInfo RGI;
    local R_GameOptions RGO;

    if(Role == ROLE_Authority)
    {
        RGI = R_GameInfo(Level.Game);
        if(RGI != None)
        {
            RGO = RGI.GameOptions;
            if(RGO != None)
            {
                return RGO.bOptionShieldHitStun;
            }
        }
    }

	return false;
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

	PlayHitSound(DamageType);

	// [RMod]
	// Cause the owner to enter into HitStun
	// Copy from Pawn.DamageBodyPart, to avoid modifying Pawn
	if(Owner != None && Pawn(Owner) != None && CheckIsShieldHitStunEnabled())
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
		{	// Pawns drop shields once in a while on easier skill levels
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
*	StartAttack
*	Called from R_RunePlayer ShieldActivate function during shield attacks
*/
function StartAttack()
{}

/**
*	FinishAttack
*	Called from R_RunePlayer ShieldDeactivate function during shield attacks
*/
function FinishAttack()
{}

/**
*	PlaySwipeSound
*	Called from R_RunePlayerProxy ShieldActivate function during shield attacks
*/
function PlaySwipeSound()
{}

/**
*	ShieldFire
*	Called from R_RunePlayerProxy ShieldActivate function during shield attacks
*	Weapon class appears to use this function only for rune power behavior, so
*	for the moment it does nothing here
*/
function ShieldFire()
{}

/**
*	State Idle (override)
*	Shield is currently equipped by the owner
*/
state Idle
{
	
}

/**
*	State Active (override)
*	Shield is currently equipped by the owner AND it is in the defend state
*/
state Active
{
	event Tick(float DeltaSeconds)
	{
		Super.Tick(DeltaSeconds);
	}
}

defaultproperties
{
}
