class R_ArpgSkill_Whirlwind extends R_ArpgSkill;

var private Vector MoveDirection;
var private float SavedGroundSpeed;
var private float StartingYaw;
var private Class<Actor> ParticlesClass;
var private Actor Particles;

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
        local Vector LookDirection;

        OwnerPawn = GetArpgPawnOwner();
        if(OwnerPawn != None)
        {
            OwnerPawn.SetBlockMovementInput(true);
            OwnerPawn.SetLockDirection(true);
            LookDirection = OwnerPawn.GetLookDirection();
            MoveDirection = LookDirection;
            SavedGroundSpeed = OwnerPawn.GroundSpeed;
            OwnerPawn.GroundSpeed *= 0.5;
            StartingYaw = OwnerPawn.Rotation.Yaw;
            OwnerPawn.Weapon.Damage *= 0.5;
            OwnerPawn.SetCollision(false, true, true);
        }

        if(Particles != None)
        {
            ParticleSystem(Particles).ParticleCount = 32;
        }
    }

    event EndState()
    {
        local R_ArpgPawn OwnerPawn;

        OwnerPawn = GetArpgPawnOwner();
        if(OwnerPawn != None)
        {
			OwnerPawn.ClearPawnAnim(true, true);
            OwnerPawn.SetBlockMovementInput(false);
            OwnerPawn.SetLockDirection(false);
            MoveDirection = Vect(0,0,0);
            OwnerPawn.GroundSpeed = SavedGroundSpeed;
            OwnerPawn.AnimRate = 1.0;
            OwnerPawn.Weapon.Damage *= 2.0;
            OwnerPawn.SetCollision(true, true, true);
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
            OwnerPawn.Acceleration = MoveDirection * 1000.0;

            NewRotation = OwnerPawn.Rotation;
            NewRotation.Yaw += 65535 * DeltaSeconds * 5.0;
            if(OwnerPawn.Rotation.Yaw <= StartingYaw && NewRotation.Yaw >= StartingYaw)
            {
                OwnerPawn.Weapon.ClearSwipeArray();
            }
            OwnerPawn.SetRotation(NewRotation);

            //OwnerPawn.AnimSequence = 'X5_AttackB';
            //OwnerPawn.AnimRate = 0.0;
            //OwnerPawn.AnimFrame = 0.52;
			//SetFullBodyAnim('X5_AttackB', 0.0, 0.52);
			OwnerPawn.SetPawnAnim('X5_AttackB', true, true, 0.52, 0.0);
            OwnerPawn.Weapon.FrameNotify(0.52);
            
            if(Particles != None)
            {
                Particles.SetLocation(OwnerPawn.Location);
            }
            //OwnerPawn.AnimFrame = 0.2;
            //OwnerPawn.AnimRate = 0.2;
            //Log(OwnerPawn.AnimFrame);
        }
    }

Begin:
    Sleep(3.0);
    GotoState('Idle');
}

defaultproperties
{
    ParticlesClass=Class'RuneI.GroundDust'
}