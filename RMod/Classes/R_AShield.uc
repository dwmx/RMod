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

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local vector AdjMomentum;
	local Pawn P;

	PlayHitSound(DamageType);

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

	// Hitstun pawn owner
	if(Pawn(Owner) != None)
	{
		//Pawn(Owner).DamageBodyPart(
                //    20, Pawn(Owner), HitLoc, Momentum, 'Blunt', 0);
		Pawn(Owner).JointDamaged(5, EventInstigator, HitLoc, Momentum, DamageType, 0);
	}
/*
// CJR TEST -- Recoil animation when hit in the shield
		if(P.CanGotoPainState() && Health > 0)
		{ // Recoil from being hit in the shield
			P.NextState = P.GetStateName();
			//P.PlayAnim('h3_defendPain', 1.0, 0.01);
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

defaultproperties
{
}
