//=============================================================================
// DealieFish.
// Do not add directly - rather add DealieFishSchools to the world
//=============================================================================
class DealieFish extends FlockPawn;


var float AirTime;
var vector OldSchoolDestination;
var DealieFishSchool School;
var bool bGlowing;
var actor Glow;

var vector SchoolOffset;


function PostBeginPlay()
{
	School = DealieFishSchool(Owner); 
	Super.PostBeginPlay();
	if ( School == None )
	{
		log("Warning - can't add Dealiefish independently from Dealiefish schools");
		destroy();
	}
	else
	{
		SchoolOffset.X = -FRand() * School.SchoolRadius;
		SchoolOffset.Y = (FRand() - 0.5) * School.SchoolRadius;
		SchoolOffset.Z = (FRand() - 0.5) * School.SchoolRadius;
	}
}

function Texture PainSkin(int BodyPart)
{
}

function bool JointDamaged( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType, int joint)
{
	local bool bAlreadyDead;

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = 0.4 * Vsize(momentum);
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;
	AddVelocity( momentum ); 
	Health -= Damage;
	if ( Health < -20 )
	{
//		Spawn(class'Bloodspurt');
//		Destroy();
		school.ReplentishOne();
		SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		Destroy();
	}
	else if ( !bAlreadyDead && (Health < 0) )
		Died(instigatedBy, damageType, hitLocation);
	return true;
}

function Landed(vector HitNormal, actor HitActor)
{
	local rotator newRotation;

	SetPhysics(PHYS_None);
	SetTimer(0.2 + FRand(), false);
	newRotation = Rotation;
	newRotation.Pitch = 0;
	newRotation.Roll = 16384;
	SetRotation(newRotation);
	GotoState('Flopping');
}

function PreSetMovement()
{
	bCanSwim = true;
	if (Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Falling);
	MinHitWall = -0.6;
}

function ZoneChange( ZoneInfo NewZone )
{
	local rotator newRotation;
	if (NewZone.bWaterZone)
	{
		if ( !Region.Zone.bWaterZone && (Physics != PHYS_Swimming) )
		{
			newRotation = Rotation;
			newRotation.Roll = 0;
			SetRotation(newRotation);
			MoveTimer = -1.0;
		}
		AirTime = 0;
		SetPhysics(PHYS_Swimming);
		if ( !IsInState('Swimming') ) 
			GotoState('Swimming');
	}
	else if (Physics != PHYS_Falling)
	{
		MoveTimer = -1;
		SetPhysics(PHYS_Falling);
	}
}

function FootZoneChange(ZoneInfo newFootZone)
{
	if ( (Level.TimeSeconds - SplashTime > 3) && 
	 	!FootRegion.Zone.bWaterZone && newFootZone.bWaterZone )
	{
		SplashTime = Level.TimeSeconds;
//		PlaySound(sound 'LSplash', SLOT_Interact, 0.4,,500);
//		Spawn(class 'WaterImpact',,,Location - CollisionHeight * vect(0,0,1));
	}
	
	if ( FootRegion.Zone.bPainZone )
	{
		if ( !newFootZone.bPainZone )
			PainTime = -1.0;
	}
	else if (newFootZone.bPainZone)
		PainTime = 0.01;
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local rotator newRot;

	newRot = Rotation;
	if ( FRand() < 0.5 )
		newRot.Roll = 16384;
	else 
		newRot.Roll = -16384;
	SetRotation(newRot);
	SetPhysics(PHYS_Falling);
	SetCollision(true,false,false);
	Buoyancy = 1.05 * mass;
	Velocity.Z = FMax(0, Velocity.Z);
	AnimRate = 0.0;

	school.FishDied();
	RemoteRole = ROLE_DumbProxy;
	GotoState('Dying');
}

Auto State Swimming
{
	function BeginState()
	{
		SetTimer(1, false);
	}

	function Timer()
	{
		if(bGlowing)
		{
			bGlowing = false;
			if(Glow != None)
			{
				Glow.bHidden = true;
				SetTimer(2.5 + FRand(), false);
			}
		}
		else
		{
			bGlowing = true;
			if(Glow == None)
			{
				Glow = Spawn(Class'DealieLight');
				AttachActorToJoint(Glow, JointNamed('head'));
			}

			Glow.bHidden = false;
			Glow.DrawScale = 0.15 + FRand() * 0.1;			

			SetTimer(0.5 + FRand(), false);
		}
	}

	function PickDestination()
	{
		local vector vec;
		local rotator rot;
		local vector X, Y, Z;

		if(School == None)
			return;

		if(School.IsInState('Stasis') && !PlayerCanSeeMe())
		{
			School.Remove(self);
			return;
		}

		vec = Normal(School.Location - OldSchoolDestination);
		rot = rotator(vec);
		OldSchoolDestination = School.Location;

		GetAxes(rot, X, Y, Z);
		Destination = School.Location + X * SchoolOffset.X + Y * SchoolOffset.Y + Z * SchoolOffset.Z;
				
/*
		if ( School.validDest )
			OldSchoolDestination = School.Location;
		Destination = OldSchoolDestination +
			 0.5 * School.schoolradius * ( Normal(Location - School.Location) + VRand());
*/
	}
/*
	function Touch(Actor Other)
	{
		if ( Pawn(Other) == School.Enemy )
			Other.TakeDamage(2, self, location, vect(0,0,0), 'bitten');
	}
*/		
Begin:
	Disable('Touch');
//	if (!Region.Zone.bWaterZone)
//		GotoState('Flopping');
	SetPhysics(PHYS_Swimming);
Swim:
	Enable('HitWall');
	LoopAnim('Swim', 0.7 + FRand());

	PickDestination();
	MoveTo(Destination);
School:
	if(School != None)
	{
		if((FRand() < 0.85) && (OldSchoolDestination == School.Location) 
			&& ((School.Enemy == None) || !School.Enemy.Region.Zone.bWaterZone) 
			&& !School.IsInState('SplinePath'))
		{
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			Sleep(1.5 * FRand()); // was 3.3
			Goto('School');
		}

		if(!School.IsInState('SplinePath'))
		{
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			Sleep(0.7 * FRand());
		}
	}

	Goto('Swim');
}

State Flopping
{

	function Landed(vector HitNormal, actor HitActor)
	{
		local rotator newRotation;

		SetPhysics(PHYS_None);
		SetTimer(0.3 + 0.3 * AirTime * FRand(), false);
		newRotation = Rotation;
		newRotation.Pitch = 0;
		newRotation.Roll = 16384;
		SetRotation(newRotation);
	}
		
	function Timer()
	{
		AirTime += 1;
		if (AirTime > 25 + 20 * FRand())
			GotoState('Dying');
		else
		{
			SetPhysics(PHYS_Falling);
			Velocity = 200 * VRand();
			Velocity.Z = 60 + 160 * FRand();
			DesiredRotation.Pitch = Rand(8192) - 4096;
			DesiredRotation.Yaw = Rand(65535);
		}		
	}

	function AnimEnd()
	{
		PlayAnim('Swim', 0.1 * FRand());
	}

	function BeginState()
	{
		SetPhysics(PHYS_Falling);
	}
}

State Dying
{
	ignores zonechange, headzonechange, falling, hitwall;

	function Landed(vector HitNormal, actor HitActor)
	{
		SetPhysics(PHYS_None);
	}	

	function Timer()
	{
		if ( !PlayerCanSeeMe() )
			Destroy();
	}

Begin:
	Sleep(12);
	SetTimer(4.0, true);
}			
		

simulated function Debug(canvas Canvas, int mode)
{
	Canvas.DrawText("Dealie: ");
	Canvas.CurY -= 8;
	Canvas.DrawText(" SchoolSize: "$School.SchoolSize);
	Canvas.CurY -= 8;
	Canvas.DrawText(" ActiveFish: "$School.ActiveFish);
	Canvas.CurY -= 8;
}

defaultproperties
{
     bCanStrafe=True
     WaterSpeed=250.000000
     AccelRate=700.000000
     SightRadius=3000.000000
     Health=5
     ReducedDamageType=exploded
     ReducedDamagePct=0.900000
     UnderWaterTime=-1.000000
     DrawType=DT_SkeletalMesh
     DrawScale=2.500000
     LODDistMax=500.000000
     LODCurve=LOD_CURVE_ULTRA_AGGRESSIVE
     bPointLight=True
     TransientSoundRadius=800.000000
     CollisionRadius=8.000000
     CollisionHeight=6.000000
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     Buoyancy=5.000000
     RotationRate=(Pitch=8192,Yaw=128000,Roll=16384)
     Skeletal=SkelModel'creatures.dealie'
}
