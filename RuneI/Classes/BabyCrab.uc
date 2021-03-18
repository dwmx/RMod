//=============================================================================
// BabyCrab.
//=============================================================================
class BabyCrab expands GiantCrab;

var() bool bLowDamageCrab;

//================================================
//
// AfterSpawningInventory
//
// Sets the babycrab to low damage if necessary
// This is only used on the first level so that players aren't
// immediately destroyed by the crabs while they are getting their
// bearing and getting used to the game.
//================================================

function AfterSpawningInventory()
{
	local Inventory inv;

	Super.AfterSpawningInventory();

	if(bLowDamageCrab)
	{
		for(inv = Inventory; inv != None; inv = inv.Inventory)
		{
			if(inv.IsA('Weapon'))
				Weapon(inv).Damage /= 3;
		}
	}
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_FLESH;
}


//============================================================
//
// BodyPartSeverable
//
//============================================================
function bool BodyPartSeverable(int BodyPart)
{
	return false;
}


//============================================================
//
// LimbPassThrough
//
// Determines what damage is passed through to body
//============================================================
function int LimbPassThrough(int BodyPart, int Blunt, int Sever)
{
	return Blunt+Sever;
}


//================================================
//
// SeveredLimbClass
//
//================================================
function class<Actor> SeveredLimbClass(int BodyPart)
{	// Just gibs
	return None;
}

//============================================================
//
// DamageBodyPart
//
//============================================================
function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
{
	return Super.DamageBodyPart(Damage, EventInstigator, HitLocation, Momentum, DamageType, BodyPart);
}


function PlayMoving(optional float tween)
{
	LoopAnim('moveforward', 4.0, 0.1);
}

function CrabAttack()
{
	local float choice;

	choice = FRand();
	if (choice < 0.3 && !BodyPartMissing(BODYPART_LARM1))
		PlayAnim('attackl', 1.5, 0.1);
	else if (choice < 0.6 && !BodyPartMissing(BODYPART_RARM1))
		PlayAnim('attackr', 1.5, 0.1);
	else
		PlayAnim('attackb', 1.5, 0.1);
}

function CrabWalking(vector src, vector dst, rotator rot)
{
	local vector X,Y,Z;
	local vector dir;
	local float XdotDir;

	dir = Normal(dst - src);
	GetAxes(Rotation, X,Y,Z);
	XdotDir = X dot dir;

	if (XdotDir < -0.8)
	{
		LoopAnim('movebackward', 4.0, 0.1);
	}
	else if (XdotDir > 0.8)
	{
		LoopAnim('moveforward', 4.0, 0.1);
	}
	else if ((X cross dir).Z < 0)
	{	// Moving left
		LoopAnim('moveleft', 4.0, 0.1);
	}
	else
	{	// Moving right
		LoopAnim('moveright', 4.0, 0.1);
	}
}

defaultproperties
{
     bFightHigh=False
     ThrowZ=300.000000
     AcquireSound=Sound'CreaturesSnd.Crab.crabamb03b'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Crab.crabamb01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Crab.crabdeath03b'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Crab.crabattack01b'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Crab.crabamb02b'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Crab.crabattack04b'
     AmbientWaitSoundDelay=18.000000
     AmbientFightSoundDelay=14.000000
     MeleeRange=40.000000
     GroundSpeed=300.000000
     MaxStepHeight=5.000000
     WalkingSpeed=300.000000
     Health=20
     HitSound1=Sound'CreaturesSnd.Crab.crabdeath02'
     HitSound2=Sound'CreaturesSnd.Crab.crabdeath01'
     HitSound3=Sound'CreaturesSnd.Crab.crabdeath04'
     DrawScale=0.500000
     TransientSoundVolume=0.500000
     TransientSoundRadius=600.000000
     CollisionRadius=22.500000
     CollisionHeight=16.000000
     Mass=150.000000
}
