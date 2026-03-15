//==============================================================================
//	R_ArpgPawn_Goblin
//==============================================================================
class R_ArpgPawn_Goblin extends R_ArpgPawn;

event PostBeginPlay()
{
	local R_ArpgAnimationController LocalAnimController;
	
	Super.PostBeginPlay();

	LocalAnimController = GetAnimController();
	if(LocalAnimController != None)
	{
		LocalAnimController.SetAnimationSetClass(Class'RArpg.R_ArpgAnimationSet_Goblin');
	}

	AddSkill(Class'RArpg.R_ArpgSkill_Attack', 'Attack');
}

event Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);

	//SetRotation(Rotator(Velocity * Vect(1,1,0)));
}

function int GetMovementDirection()
{
	if(VSize(Velocity * Vect(1,1,0)) <= 8.0)
	{
		return MOVEDIR_NEUTRAL;
	}

	return MOVEDIR_FORWARD;
}

defaultproperties
{
	Skeletal=SkelModel'creatures.Goblin'
	CollisionRadius=16.000000
    CollisionHeight=32.000000
	GroundSpeed=60.0
	Mass=50.000000
    Buoyancy=35.000000
	HitSound1=Sound'CreaturesSnd.Goblin.goblinhit08'
    HitSound2=Sound'CreaturesSnd.Goblin.goblinhit16'
    HitSound3=Sound'CreaturesSnd.Goblin.goblinhit28'
	Die=Sound'CreaturesSnd.Goblin.goblindeath06'
    Die2=Sound'CreaturesSnd.Goblin.goblindeath13'
    Die3=Sound'CreaturesSnd.Goblin.goblindeath16'
	DisplayNameString="Goblin"
}