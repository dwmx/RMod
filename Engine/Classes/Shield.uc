//=============================================================================
// Shield.
//=============================================================================
class Shield expands Inventory
	abstract;

var() int Health;
var() int Rating;
var(Sounds) sound DestroyedSound;
var bool bMadeDropSound;
var bool bBreakable;

replication
{
	reliable if (Role==ROLE_Authority)
		Health;
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_SHIELD;
}

//-----------------------------------------------------------------------------
//
// DestroyEffect
//
// Used when shield is destroyed
//-----------------------------------------------------------------------------
function DestroyEffect()
{
}

//============================================================================
//
// GetUsePriority
//
// Returns the priority of the weapon, lower is better
//============================================================================

function int GetUsePriority()
{
	return(2);
}

//=============================================================================
//
// SpawnCopy
//
// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
// Also add Ammo to Other's inventory if it doesn't already exist
//
//=============================================================================

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	if( Level.Game.ShouldRespawn(self) )
	{
		Copy = spawn(Class,Other,,,rot(0,0,0));
		if (Copy == None)
			log(name@"cannot be spawned in spawncopy");
		Copy.Tag           = Tag;
		Copy.Event         = Event;
		GotoState('Sleeping');
	}
	else
		Copy = self;

	Copy.bTossedOut = true;
	Copy.RespawnTime = 0.0;
	Copy.GiveTo( Other );
	Copy.bHidden = false; // BecomeItem in Inventory automatically hides the item
	return Copy;
}

//=============================================================================
//
// [RMod]
// CheckIsShieldHitStunEnabled
//
// Returns whether or not hit stun is enabled for shields
//
//=============================================================================
function bool CheckIsShieldHitStunEnabled()
{
	return Level.Game.bShieldHitStun;
}

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
			POwner.PlayTakeHit(0.1, Damage, HitLoc, DamageType, Momentum, joint);
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

//=============================================================================
//
// TravelPostAccept
//
//=============================================================================

event TravelPostAccept()
{
	local PlayerPawn P;
	local int joint;

	Super.TravelPostAccept();

	if(Pawn(Owner) == None)
	{
		return;
	}

	if(self == Pawn(Owner).Shield)
	{
		joint = Owner.JointNamed(Pawn(Owner).ShieldJoint);
		Owner.AttachActorToJoint(self, joint);
		GotoState('Idle');
	}
}


//-----------------------------------------------------------------------------
//
// State Pickup
//
// Sitting on the ground waiting to be picked up
//-----------------------------------------------------------------------------

auto state Pickup
{
	ignores JointDamaged;

	function BeginState()
	{
		bSweepable=false;
		BecomePickup();
		bCollideWorld = true;
		if (bTossedOut && bExpireWhenTossed)	// If not a placed item, expire after some time
			LifeSpan=ExpireTime;
	}
	
	function EndState()
	{
		bSweepable=Default.bSweepable;
		BecomeItem();
		bCollideWorld = false;
		LifeSpan=0;				// Disallow expire, since someone picked me up
	}
	
	function Touch(Actor Other)
	{
		local inventory Copy;

		if(Other.IsA('Pawn'))
		{
			if(Pawn(Other).Health > 0 && Pawn(Other).CanPickUp(self))
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
				Copy = SpawnCopy(Pawn(Other));

				if(PickupMessageClass == None)
					Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
				else
					Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class);

				Copy.PlaySound (PickupSound);
				if ( Level.Game.Difficulty > 1 )
					Other.MakeNoise(0.1 * Level.Game.Difficulty);
				Pawn(Other).AcquireInventory(Copy);
				Copy.GotoState('Idle');
			}
		}
	}
	
begin:
	AmbientGlow = 0;
	SkelMesh = Default.SkelMesh;
}

//-----------------------------------------------------------------------------
//
// State BeingPickedUp
//
// About to be picked up by another actor
//
//-----------------------------------------------------------------------------
/*
state BeingPickedUp
{
	ignores JointDamaged;

	function BeginState()
	{
		Pawn(Owner).AcquireInventory(self);
		GotoState('Idle');
	}
	
begin:
}
*/

//-----------------------------------------------------------------------------
//
// State Idle
//
// Idle in the actor's hand, waiting to be used (not currently used)
//-----------------------------------------------------------------------------
state Idle
{

begin:
}

//-----------------------------------------------------------------------------
//
// State Active
//
// Active and absorbing damage
//-----------------------------------------------------------------------------

state Active
{
	function BeginState()
	{
		SetPhysics(PHYS_None);
	}
	
	function EndState()
	{
	}

begin:
}


//-----------------------------------------------------------------------------
//
// State Drop
//
// Was dropped
//-----------------------------------------------------------------------------

state Drop
{
	ignores JointDamaged;

	function BeginState()
	{
		SetPhysics(PHYS_Falling);
		SetCollision(true, false, false);
		bCollideWorld = true;
		bBounce = true;
		bFixedRotationDir = true;
		DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
		RotationRate.Yaw = 60000;
		DesiredRotation.Pitch = Rotation.Pitch + Rand(2000) - 1000;
		RotationRate.Pitch = 60000;
		bMadeDropSound = false;
	}
	
	function EndState()
	{
		bBounce = false;
		SetCollision(false, false, false);
		bCollideWorld = false;
		bBounce = false;		
		bFixedRotationDir = false;
	}
	
	function Landed(vector HitNormal, actor HitActor)
	{
		HitWall(HitNormal, HitActor);
	}
	
	function HitWall(vector HitNormal, actor HitActor)
	{
		local float speed;

		if (!bMadeDropSound && !Region.Zone.bWaterZone)
		{
			bMadeDropSound=true;
			PlaySound(DropSound, SLOT_Interact);
			MakeNoise(1.0);
		}

		speed = VSize(velocity);
		if((HitNormal.Z > 0.8) && (speed < 60))
		{
			if(DesiredRotation.Roll ~= Rotation.Roll
				&& DesiredRotation.Pitch ~= Rotation.Pitch)
			{
				SetPhysics(PHYS_None);
				bBounce = false;
				bFixedRotationDir = false;
			
				GotoState('Pickup');
			}
			else
			{
				DesiredRotation.Roll = 0;
				DesiredRotation.Pitch = 32768;
				RotationRate.Roll = 60000;
				RotationRate.Pitch = 80000;
				bRotateToDesired = true;
				bFixedRotationDir = false;

				Velocity.Z = 60;
			}
		}
		else
		{			
			SetPhysics(PHYS_Falling);
			RotationRate.Yaw = VSize(Velocity) * 150;
			RotationRate.Pitch = VSize(Velocity) * 100;
			
			Velocity = 0.7 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
			DesiredRotation = rotator(HitNormal);
		}
	}

/*	function Touch(Actor Other)
	{
		if(Other.IsA('Pawn'))
		{
			if(Pawn(Other).Health > 0 && Pawn(Other).CanPickUp(self))
			{
				SetOwner(Other);
				GotoState('BeingPickedUp');
			}
		}
	}
*/

	function Touch(Actor Other)
	{
		local inventory Copy;

		if(Other.IsA('Pawn'))
		{
			if(Pawn(Other).Health > 0 && Pawn(Other).CanPickUp(self))
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
				Copy = SpawnCopy(Pawn(Other));

				if(PickupMessageClass == None)
					Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
				else
					Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class);

				Copy.PlaySound (PickupSound);
				if ( Level.Game.Difficulty > 1 )
					Other.MakeNoise(0.1 * Level.Game.Difficulty);
				Pawn(Other).AcquireInventory(Copy);

				if(!Pawn(Other).IsInState('PlayerSwimming'))
					Copy.GotoState('Active');
			}
		}
	}

}

//-----------------------------------------------------------------------------
//
// State Smashed
//
// Shield was destroyed
//-----------------------------------------------------------------------------

state Smashed
{
	ignores JointDamaged;

	function BeginState()
	{
		local int joint;
		local Pawn ThePawn;

		ThePawn = Pawn(Owner);
		if (ThePawn != None)
		{
			joint = ThePawn.JointNamed(ThePawn.ShieldJoint);
			if (joint != 0)
			{
				ThePawn.DetachActorFromJoint(joint);
				ThePawn.DeleteInventory(self);
			}
		}

		DestroyEffect();
		PlaySound(DestroyedSound, SLOT_Pain);
		Destroy(); // remove self!
	}

begin:
}

//-----------------------------------------------------------------------------
//
// State Bashing
//
// Shield is bashing anything in front of it
//-----------------------------------------------------------------------------
/*
state Bashing
{
	function BeginState()
	{
		Enable('Tick');
	}

	function EndState()
	{
		Disable('Tick');
	}

	//-----------------------------------------------------------------------------
	//
	// BashActors
	//
	//-----------------------------------------------------------------------------

	function BashActors()
	{
		local actor a;
		local vector hitLoc, hitNorm;
		local vector extent;

		extent.x = 10;
		extent.y = 10;
		extent.z = 10;

		foreach TraceActors(class'actor', a, hitLoc, hitNorm,
			Location + vector(Owner.Rotation) * 80,, extent)
		{
			a.JointDamaged(2, Owner, hitLoc, vect(0, 0, 0), 'blunt', 0);
		}
	}

	function Tick()
	{
		BashActors
		
	}

begin:
}
*/
//=============================================================================
//
// DropFrom
//
//=============================================================================

function DropFrom(vector StartLocation)
{
	if(!SetLocation(StartLocation))
	{
		return;
	}
		
	SetPhysics(PHYS_Falling);
	SetCollision( true, false, false );
	bCollideWorld = true;
//	SetOwner(None);
	
	GotoState('Pickup');
}



//=============================================================================
//
// Sound Functions
//
//=============================================================================
function PlayHitSound(name DamageType)
{
}


simulated function Debug(canvas Canvas, int mode)
{
	Super.Debug(Canvas, mode);

	Canvas.DrawText("Shield:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" Health: "@Health);
	Canvas.CurY -= 8;
}

defaultproperties
{
     bBreakable=True
     RespawnTime=30.000000
     Buoyancy=4.000000
}
