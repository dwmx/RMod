//=============================================================================
// StoneGuard.
//=============================================================================
class StoneGuard expands ScriptPawn;

//------------------------------------------------
//
// AttitudeToCreature
//
//------------------------------------------------
function eAttitude AttitudeToCreature(Pawn Other)
{
	if(Other.IsA('Goblin'))
		return ATTITUDE_Hate;
	else
		return Super.AttitudeToCreature(Other);
}

//================================================
//
// AfterSpawningInventory
//
// Used to spawn additional chained weapon
//================================================
function AfterSpawningInventory()
{
	Weapon = Spawn(class'zombieclaw');
	Weapon.SetOwner(self);
	AttachActorToJoint(Weapon, JointNamed(WeaponJoint));	// Attach to left hand
	Weapon.GotoState('Active');
}

//================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//================================================
function bool CanPickup(Inventory item)
{
	if(item.IsA('Weapon') && Weapon == None)
	{
		return(item.IsA('ZombieClaw'));
	}
}

function PlayWaiting(optional float tween)
{
	PlayAnim('base', 1.0, 0.1);
}

function PlayMoving(optional float tween)
{
	PlayAnim('base', 1.0, 0.1);
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return(MATTER_STONE);
}

//============================================================
//
// DamageBodyPart
//
// StoneGuards are immortal
//============================================================

function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
{
	return(false);
}

defaultproperties
{
     FightOrFlight=1.000000
     FightOrDefend=1.000000
     HighOrLow=0.500000
     HighOrLowBlock=0.500000
     BlockChance=1.000000
     LungeRange=100.000000
     PaceRange=100.000000
     TimeBetweenAttacks=0.100000
     MeleeRange=100.000000
     CombatRange=180.000000
     GroundSpeed=0.000000
     AccelRate=0.000000
     JumpZ=0.000000
     MaxStepHeight=0.000000
     AirControl=0.100000
     WalkingSpeed=0.000000
     ClassID=22
     Health=9999
     BodyPartHealth(1)=9999
     BodyPartHealth(3)=9999
     BodyPartHealth(5)=9999
     Intelligence=BRAINS_HUMAN
     WeaponJoint=attach_hand
     ShieldJoint=attach_shielda
     StabJoint=spineb
     bCanLook=True
     bHeadLookUpDouble=True
     LookDegPerSec=10.000000
     CollisionRadius=24.000000
     CollisionHeight=46.000000
     Buoyancy=400.000000
     RotationRate=(Pitch=0,Yaw=0,Roll=0)
     SkelMesh=23
     Skeletal=SkelModel'Players.Ragnar'
}
