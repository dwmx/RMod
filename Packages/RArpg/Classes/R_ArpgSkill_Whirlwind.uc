class R_ArpgSkill_Whirlwind extends R_ArpgSkill;

var private Vector MoveDirection;
var private float SavedGroundSpeed;
var private float StartingYaw;
var private Class<Actor> ParticlesClass;
var private Actor Particles;
var private float HitFrequency;
var private float HitTimeStamp;

event PostBeginPlay()
{
    if(ParticlesClass != None)
    {
        Particles = Spawn(ParticlesClass, Self);
        ParticleSystem(Particles).bSystemOneShot = false;
        ParticleSystem(Particles).bOneShot = false;
        ParticleSystem(Particles).AlphaStart=200;
    }
}

function ActivateSkill()
{
    GotoState('SkillActive');
}

auto state Idle
{
    
}

state SkillActive
{
    event BeginState()
    {
        local R_ArpgPawn OwnerPawn;

        OwnerPawn = GetArpgPawnOwner();
        if(OwnerPawn != None)
        {
			OwnerPawn.LockMovement();
            //OwnerPawn.SetBlockMovementInput(true);
            //OwnerPawn.SetLockDirection(true);
            //MoveDirection = OwnerPawn.GetLookDirection();
            MoveDirection = Vector(OwnerPawn.Rotation);
            SavedGroundSpeed = OwnerPawn.GroundSpeed;
            OwnerPawn.GroundSpeed *= 0.5;
            StartingYaw = OwnerPawn.Rotation.Yaw;
            //OwnerPawn.Weapon.Damage *= 0.5;
            OwnerPawn.SetCollision(false, true, true);

            OwnerPawn.GetAnimInterface().SetAnimParameter('WhirlwindAlpha', 1.0);
        }

        if(Particles != None)
        {
            ParticleSystem(Particles).ParticleCount = 32;
        }

        HitTimeStamp = 0.0;
    }

    event EndState()
    {
        local R_ArpgPawn OwnerPawn;

        OwnerPawn = GetArpgPawnOwner();
        if(OwnerPawn != None)
        {
			OwnerPawn.UnlockMovement();
           // OwnerPawn.SetBlockMovementInput(false);
            //OwnerPawn.SetLockDirection(false);
            MoveDirection = Vect(0,0,0);
            OwnerPawn.GroundSpeed = SavedGroundSpeed;
            OwnerPawn.AnimRate = 1.0;
            //OwnerPawn.Weapon.Damage *= 2.0;
            OwnerPawn.SetCollision(true, true, true);

            OwnerPawn.GetAnimInterface().SetAnimParameter('WhirlwindAlpha', 0.0);
        }

        if(Particles != None)
        {
            ParticleSystem(Particles).ParticleCount = 0;
        }
    }

    event Tick(float DeltaSeconds)
    {
        local R_ArpgPawn OwnerPawn;
        local Rotator NewRotation;

        OwnerPawn = GetArpgPawnOwner();
        if(OwnerPawn != None)
        {
            TickCollision(DeltaSeconds);

            OwnerPawn.Acceleration = MoveDirection * 1000.0;

            if(Particles != None)
            {
                Particles.SetLocation(OwnerPawn.Location);
            }
        }
    }

    function TickCollision(float DeltaSeconds)
    {
        local R_ArpgObserver_Collision Observer;
        local R_ArpgPawn PawnOwner, PawnIt;
        local Vector CollisionOrigin;
        local float CollisionRadius;
        local R_ArpgPawn RadiusPawns[32];
        local int RadiusPawnCount;

        if(1.0 / HitFrequency > Level.TimeSeconds - HitTimeStamp)
        {
            return;
        }
        HitTimeStamp = Level.TimeSeconds;

        PawnOwner = GetArpgPawnOwner();
		if(PawnOwner == None)
		{
			return;
		}

        CollisionOrigin = PawnOwner.Location;
        CollisionRadius = 64.0;

        RadiusPawnCount = 0;
        foreach RadiusActors(Class'RArpg.R_ArpgPawn', PawnIt, CollisionRadius, CollisionOrigin)
        {
			if(!IsValidTarget(PawnIt))
			{
				continue;
			}
            if(RadiusPawnCount >= ArrayCount(RadiusPawns))
            {
                break;
            }

            RadiusPawns[RadiusPawnCount] = PawnIt;
            ++RadiusPawnCount;
        }

        // Select a random pawn to damage every tick
        if(RadiusPawnCount > 0)
        {
            PawnIt = RadiusPawns[Rand(RadiusPawnCount)];
			PawnOwner.ArpgStruckOther(PawnIt, 20.0);
        }
        
        Observer = GetObserver_Collision();
        if(Observer != None)
        {
            Observer.ClearCollisionSpheres();
            Observer.AddCollisionSphere(CollisionOrigin, CollisionRadius);
        }
    }

Begin:
    Sleep(3.0);
    GotoState('Idle');
}

defaultproperties
{
    ParticlesClass=Class'RuneI.GroundDust'
    HitFrequency=20.0;
}