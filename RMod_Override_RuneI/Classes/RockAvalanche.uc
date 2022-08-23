//=============================================================================
// RockAvalanche.
//=============================================================================
class RockAvalanche expands DecorationRune;

var(Sounds) sound ImpactSound;


//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_STONE;
}


/*	too expensive
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
	debristype = class'debrisstone';

	// Spawn cloud
	c = Spawn(class'DebrisCloud');
	c.SetRadius(Max(CollisionRadius,CollisionHeight));

	// Spawn debris
	numchunks = Clamp(Mass/10, 3, 15);

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
			d.LifeSpan = 0.5;
		}
	}
}
*/

function SpawnDebris()
{
	local debriscloud c;

	// Spawn cloud
	c = Spawn(class'DebrisCloud');
	c.SetRadius(Max(CollisionRadius,CollisionHeight));
}


auto state FallingRock
{
	function BeginState()
	{
		SetPhysics(PHYS_Falling);
		DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
//		RotationRate.Yaw = 50000;
		RotationRate.Yaw = RandRange(-50000, 50000);
		RotationRate.Pitch = RandRange(-50000, 50000);
		SetTimer(5, false);
	}

	function MakeHitSound(vector hitNormal, float speed)
	{
		local float f, m, v;
		local Sound snd;

		m = FClamp(Mass, 0, 200);
		if(hitNormal.Z < 0)
			hitNormal.Z = 0;
		f = FRand()*0.15 + hitNormal.Z*0.3 + m*0.00275;
		speed = FClamp(speed, 0, 400);
		v = f*0.2 + m*0.0015 + speed*0.00125;
		PlaySound(ImpactSound,, 0.2+v*0.8,,, 0.9+FRand()*0.2);
	}

	function Touch(actor Other)
	{
		local int damage;

		if(Other.IsA('ScriptPawn') && ScriptPawn(Other).bIsBoss)
			return; // Don't hurt bosses with falling rocks

		damage = (1-Velocity.Z/400)* Mass/Other.Mass;

		if(Owner != None && Owner.IsA('PlayerPawn') && PlayerPawn(Owner).Weapon != None)
		{ // Check to make sure that avalanches don't work in neutralzones/damage teammates, etc
			if(PlayerPawn(Owner).Weapon.CalculateDamage(Other) == 0)
				return;
		}
			
		if(Other != Owner)
			Other.JointDamaged(damage, Instigator, Location, 0.5*Velocity, 'crushed', 0);
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		HitWall(HitNormal, HitActor);
	}

	function HitWall(vector hitNormal, actor hitWall)
	{
		local float speed;

		speed = VSize(Velocity);

		Momentum = hitNormal * speed;
		MakeHitSound(hitNormal, speed);
		Destroy();
	}

	function Timer()
	{	// Explode into pieces
		bDestroyable=false;//temp
		Destroy();
	}

begin:
}

defaultproperties
{
     ImpactSound=Sound'MurmurSnd.Rocks.rock01'
     bDestroyable=True
     DestroyedSound=Sound'MurmurSnd.Rocks.rock08'
     bStatic=False
     DrawType=DT_SkeletalMesh
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     bCollideActors=True
     bCollideWorld=True
     bBounce=True
     bFixedRotationDir=True
     Mass=10.000000
     Skeletal=SkelModel'objects.Rocks'
}
