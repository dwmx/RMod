//=============================================================================
// LightningPowerupBall.
//=============================================================================
class LightningPowerupBall expands Projectile;

var(Sounds) Sound LightningFireSound[3];
var float Time;
var float ZapRadius;
var Electricity Electricity[3];
var int ZapDamage;
var float ScaleSpeed;

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay(); 

	SetTimer(0.25, true);

	for(i = 0; i < ArrayCount(Electricity); i++)
	{
		Electricity[i] = Spawn(class'Electricity', Owner,, Location);
		Electricity[i].SetBase(self);
		Electricity[i].Target = None;
		Electricity[i].RemoteRole = ROLE_None;
	}
}

simulated function ClearZapList()
{
	local int i;

	for(i = 0; i < ArrayCount(Electricity); i++)
	{
		Electricity[i].Target = None;
		Electricity[i].TargetJointIndex = 0;
		Electricity[i].bHidden = true;
	}
}

//===================================================================
//
// IssueZapDamage
//
// Server-side joint damage function
//===================================================================
function IssueZapDamage(Actor A)
{
	A.JointDamaged(ZapDamage, Pawn(Owner), A.Location, vect(0,0,0), MyDamageType, 0);
}

simulated function SetZapTarget(int index, actor A)
{
	if(index < 0 || index >= ArrayCount(Electricity))
		return;

	Electricity[index].bHidden = false;
	Electricity[index].Target = A;
	if(A.Skeletal != None)
	{ // Jump the electricity around on random joints
		Electricity[index].TargetJointIndex = Rand(A.NumJoints());
	}

	// Damage this actor that is being zapped
	if(Rand(3) > 1)
	{
		PlaySound(LightningFireSound[Rand(3)], SLOT_Interface);
	}
	
	IssueZapDamage(A);
}

simulated function Timer()
{
	local actor A;
	local int count;

	// Clear list of actors being currently zapped
	ClearZapList();

	// Then look for all possible targets in a given radius
	count = 0;
	foreach VisibleActors(class'Actor', A, ZapRadius, Location)
	{
		if(A == self || A == Owner || A.Owner == Owner)
			continue;

		if (ScriptPawn(A)!=None && ScriptPawn(A).bIsBoss)
			continue;

		if(A.IsA('Pawn') || A.IsA('Mover') || A.IsA('Polyobj') || A.IsA('Carcass')
			|| (A.IsA('DecorationRune') && DecorationRune(A).bDestroyable))
		{
			SetZapTarget(count, A);		
			count++;
		}
	}
}

simulated function Tick(float DeltaTime)
{
	ScaleGlow += DeltaTime * ScaleSpeed;
	if(ScaleGlow > 2.0)
	{
		ScaleGlow = 2.0;
		ScaleSpeed = -ScaleSpeed;
	}
	else if(ScaleGlow < 0.5)
	{
		ScaleGlow = 0.5;
		ScaleSpeed = -ScaleSpeed;
	}

	Time -= DeltaTime;
	if(Time <= 0)
		Explode(Location, vect(0, 0, 1));
}

simulated function HitWall(vector HitNormal, actor Wall)
{ // Bounce!
	Velocity = Velocity - 2 * HitNormal * (Velocity Dot HitNormal);
}

simulated function Landed(vector HitNormal, actor HitActor)
{
	HitWall(HitNormal, HitActor);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{	
	local int i;

	for(i = 0; i < ArrayCount(Electricity); i++)
	{
		if(Electricity[i] != None)
			Electricity[i].Destroy();
	}

	Destroy();
}

defaultproperties
{
     LightningFireSound(0)=Sound'WeaponsSnd.PowerUps.aelec01'
     LightningFireSound(1)=Sound'WeaponsSnd.PowerUps.aelec02'
     LightningFireSound(2)=Sound'WeaponsSnd.PowerUps.aelec03'
     Time=3.000000
     ZapRadius=350.000000
     ZapDamage=3
     ScaleSpeed=1.000000
     MaxSpeed=100.000000
     Damage=20.000000
     MyDamageType=magic
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=FireTexture'RuneFX2.lightningstart'
     DrawScale=0.500000
     ScaleGlow=0.500000
     AmbientGlow=50
     SpriteProjForward=5.000000
     CollisionRadius=20.000000
     CollisionHeight=20.000000
     bCollideActors=False
     bBounce=True
}
