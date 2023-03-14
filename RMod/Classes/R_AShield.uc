//==============================================================================
//  R_AShield
//  Abstract base shield class which implements core RMod shield functionality.
//==============================================================================
class R_AShield extends Shield abstract;

var Vector SweepDirectionVector;
var Vector LastSweepPos1;
var Vector LastSweepPos2;
var float ShieldSweepExtent;

var Name ShieldDamageType;

var Sound ThroughAir[3];
var int NumThroughAirSounds;

var float PitchDeviation;

struct FShieldSwipeHit
{
    var Actor Actor;
    var int LowMask;
    var int HighMask;
};

const SWIPE_HIT_COUNT = 16;
var FShieldSwipeHit SwipeHitArray[16];

event BeginPlay()
{
	Super.BeginPlay();
	
	InitializeSoundArrays();
}

function InitializeSoundArrays()
{
	local int i;
	
	NumThroughAirSounds = 0;
	for(i = 0; i < 3; ++i)
	{
		if(ThroughAir[i] != None)	++NumThroughAirSounds;
	}
}

/**
*	ClearSwipeArray
*	Clears out all memory of struck actors, allowing actors to be struck again by this shield
*/
function ClearSwipeArray()
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
*	CheckDoesSwipeArrayContain
*	Returns true if the specified actor is currently in the swipe hit array
*/
function bool CheckDoesSwipeArrayContain(Actor A, int LowMask, int HighMask)
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
*	PushActorToSwipeArray
*	Places an actor into the swipe hit array
*/
function PushActorToSwipeArray(Actor A, int LowMask, int HighMask)
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
		}
		return;
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
{
	GotoState('Swinging');
}

/**
*	FinishAttack
*	Called from R_RunePlayer ShieldDeactivate function during shield attacks
*/
function FinishAttack()
{
	GotoState('Idle');
}

/**
*	PlaySwipeSound
*	Called from R_RunePlayerProxy ShieldActivate function during shield attacks
*/
function PlaySwipeSound()
{
	//Log("Playing swipe sound");
	PlaySound(ThroughAir[Rand(NumThroughAirSounds)], SLOT_None,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
}

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
	event BeginState()
	{
	}
}

/**
*	State Active (override)
*	Shield is currently equipped by the owner AND it is in the defend state
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
*	State Swinging
*	Shield is being used in an attack, needs to check for collisions
*/
state Swinging
{
	event BeginState()
	{
		ClearSwipeArray();
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
		if(CheckDoesSwipeArrayContain(A, LowMask, HighMask))
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
		
		PushActorToSwipeArray(A, LowMask, HighMask);
		
		//A.JointDamaged(5, Pawn(Owner), HitLoc, SweepMomentum, ShieldDamageType, 0);
		
		// For now, just do a hit stun
		P = Pawn(A);
		if(P != None && P.GetStateName() != 'Pain' && P.GetStateName() != 'pain')
		{
			P.NextStateAfterPain = P.GetStateName();
			P.PlayTakeHit(0.1, 50, HitLoc, 'blunt', SweepMomentum, 0);
			P.GotoState('Pain');
		}
	}
}

simulated function Debug(Canvas Canvas, int Mode)
{
	Super.Debug(Canvas, Mode);
	
	Canvas.DrawLine3D(LastSweepPos1, LastSweepPos2, 100, 255, 100);
}

defaultproperties
{
	SweepDirectionVector=(X=1.0)
	ShieldSweepExtent=32.0
	ThroughAir(0)=Sound'WeaponsSnd.Swings.bswing02'
	ThroughAir(1)=Sound'WeaponsSnd.Swings.bswing01'
	ThroughAir(2)=Sound'WeaponsSnd.Swings.bswing03'
	PitchDeviation=0.09
	ShieldDamageType='blunt'
}
