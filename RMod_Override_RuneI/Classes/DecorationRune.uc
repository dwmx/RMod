//=============================================================================
// DecorationRune.
//=============================================================================
class DecorationRune extends Decoration
	abstract;

var() bool bDestroyable;
var vector Momentum;
var(Sounds) sound DestroyedSound;
var(Advanced) bool        bBurnable;			// RUNE: Can be set on fire


function SetOnFire(Pawn EventInstigator, int joint)
{
	local PawnFire F;

	if (bBurnable)
	{
		if (ActorAttachedTo(joint) == None)
		{
			F = Spawn(class'PawnFire',EventInstigator);
			AttachActorToJoint(F, joint);
		}
	}
}

function EMatterType MatterForJoint(int joint)
{
	return MATTER_WOOD;
}

/*
function AddVelocity(vector NewVelocity)
{
	if (Physics != PHYS_Falling)
		SetPhysics(PHYS_Falling);
	Velocity += NewVelocity;
}
*/

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Mom, name DamageType, int joint)
{
	local EMatterType matter;
	local bool bDamage;

	if (DamageType == 'fire')
	{
		return Super.JointDamaged(Damage, EventInstigator, HitLoc, Mom, DamageType, joint);
	}

	if (bDestroyable)
	{
		Momentum = Mom;
		Destroy();

/* CJR - changed this so all weapons can destroy all decorations, so that creatures can smash objects at will
		matter = MatterForJoint(joint);
		switch(DamageType)
		{
			case 'sever':		// Sword
			case 'thrownweaponsever':
				bDamage = (matter==MATTER_FLESH || matter==MATTER_EARTH);
				break;
			case 'bluntsever':	// Axe
			case 'thrownweaponbluntsever':
				bDamage = (matter==MATTER_FLESH || matter==MATTER_WOOD || matter==MATTER_EARTH);
				break;
			case 'blunt':		// Hammer
			case 'thrownweaponblunt':
				bDamage = (matter==MATTER_FLESH || matter==MATTER_WOOD || matter==MATTER_STONE || matter==MATTER_EARTH);
				break;
			default:
				bDamage = false;
				break;
		}

		if (bDamage)
		{
			Momentum = Mom;
			Destroy();
		}
*/
	}

	return false;
}

function PlayDestroyedSound()
{
	local EMatterType matter;

	if (DestroyedSound != None)
	{	// Default behavior is to play matter based crash sounds unless a specific DestroyedSound is specified
		PlaySound(DestroyedSound, SLOT_Pain);
	}
	else
	{
		matter = MatterForJoint(0);
		switch(matter)
		{
			case MATTER_FLESH:
				PlaySound(Sound'WeaponsSnd.impflesh.impactflesh02', SLOT_Pain);
				break;
			case MATTER_WOOD:
				PlaySound(Sound'WeaponsSnd.impcrashes.crashwood01', SLOT_Pain);
				break;
			case MATTER_STONE:
				PlaySound(Sound'WeaponsSnd.impcrashes.crashxstone01', SLOT_Pain);
				break;
			case MATTER_EARTH:
				PlaySound(Sound'WeaponsSnd.impcrashes.crashwood03', SLOT_Pain);
				break;
			case MATTER_ICE:
				PlaySound(Sound'WeaponsSnd.impcrashes.crashglass02', SLOT_Pain);
				break;
		}
	}
}

function SpawnDebris()
{
	local EMatterType matter;
	local class<debris> debristype;
	local int i, numchunks, NumSourceGroups;
	local debris d;
	local debriscloud c;
	local vector loc;
	local float scale;

	// Determine type of debris
	matter = MatterForJoint(0);
	switch(matter)
	{
		case MATTER_FLESH:
			debristype = class'debrisflesh';
			break;
		case MATTER_WOOD:
			debristype = class'debriswood';
			break;
		case MATTER_STONE:
		case MATTER_EARTH:
			debristype = class'debrisstone';
			break;
		case MATTER_ICE:
			debristype = class'debrisice';
			break;
	}

	// Spawn cloud
	c = Spawn(class'DebrisCloud');
	c.SetRadius(Max(CollisionRadius,CollisionHeight));

	// Spawn debris
	if (debristype != None)
	{
		numchunks = Clamp(Mass/10, 2, 10)*Level.Game.DebrisPercentage;

		// Find appropriate size of chunks
		scale = (CollisionRadius*CollisionRadius*CollisionHeight) / (numchunks*500);
		scale = scale ** 0.3333333;
		for (NumSourceGroups=1; NumSourceGroups<16; NumSourceGroups++)
		{
			if (SkelGroupSkins[NumSourceGroups] == None)
				break;
		}

		for (i=0; i<numchunks; i++)
		{
			loc = Location;
			loc.X += (FRand()*2-1)*CollisionRadius;
			loc.Y += (FRand()*2-1)*CollisionRadius;
			loc.Z += (FRand()*2-1)*CollisionHeight;
			d = Spawn(debristype,,,loc);
			if (d != None)
			{
				d.SetSize(scale);
				d.SetTexture(SkelGroupSkins[i%NumSourceGroups]);
				d.SetMomentum(Momentum);
			}
		}
	}
}


function Destroyed()
{
	if (bDestroyable)
	{
		SpawnDebris();
		PlayDestroyedSound();
	}
	Super.Destroyed();
}

defaultproperties
{
     bSweepable=True
     Mass=100.000000
}
