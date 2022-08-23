//=============================================================================
// DarkDwarfBolt.
//=============================================================================
class DarkDwarfBolt expands Electricity;

var actor TargetActor;
var float Damage;
var vector TryToHitLocation;
var float BeamCloseTime;
var vector EndOfTrace;
var float alpha;


function SetTarget(actor Targ)
{	// called before firing
	TargetActor = Targ;
	ResetTargetting();
}

function ResetTargetting()
{
	if (TargetActor != None)
	{
		TryToHitLocation = TargetActor.Location;
		if (TargetActor.IsA('Pawn'))
			TryToHitLocation += vect(0,0,1)*Pawn(TargetActor).EyeHeight;
	}
	alpha = 0.1;
	UpdateTargetting(0);
}

function SetPowerLevel(int powerlevel)
{
	BeamThickness = 2 + powerlevel;
	Damage = 5 + powerlevel*2;
	amplitude = 10 + 10*powerlevel;
	BeamCloseTime = 3.0 - (powerlevel*0.5);
}

function DoDamage()
{
	local actor victim;
	local vector HitLoc, HitNormal;

	if (!bHidden && TargetActor!=None)
	{
		victim = Trace(HitLoc, HitNormal, EndOfTrace, Location, true, );
		if (victim != None)
		{
			victim.JointDamaged(Damage, Pawn(Owner), victim.Location, Normal(victim.Location-Location)*100, 'fire', 0);
			if (Pawn(Victim)!=None)
			{
				spawn(class'RuneI.SparkSystemHit', self,,Victim.Location+vect(0,0,1)*Pawn(Victim).EyeHeight, rotator(HitNormal));
			}
			else
			{
				spawn(class'RuneI.SparkSystemHit', self,,HitLoc, rotator(HitNormal));
			}
		}
	}
}

function UpdateTargetting(float DeltaTime)
{
	local vector HitNormal;
	local actor A;

	if (!bHidden)
	{	// Trace to target, set ending location
		alpha += DeltaTime;
		alpha = FClamp(alpha, 0.0, BeamCloseTime);
		TryToHitLocation = TryToHitLocation + ((alpha/BeamCloseTime)*(TargetActor.Location-TryToHitLocation));
		//EndOfTrace = Location + (TryToHitLocation-Location)*2;
		EndOfTrace=TryToHitLocation+2000*Normal(TryToHitLocation-Location);
		A=Trace(TargetLocation, HitNormal, EndOfTrace, Location, true,);
		bUseTargetLocation = true;
		if (A==None)
		{
			TargetLocation = EndOfTrace;
		}
		else if (!A.IsA('LevelInfo'))
		{
			Target = A;
			TargetJointIndex=1;
			bUseTargetLocation = false;
		}
	}
}

function Tick(float DeltaTime)
{	// update the endpoint location
	UpdateTargetting(DeltaTime);
}


simulated function Debug(Canvas canvas, int mode)
{
	local vector offset;

	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Bolt:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" Target:"@Target);
	Canvas.CurY -= 8;
	Canvas.DrawText(" TargetActor:"@TargetActor);
	Canvas.CurY -= 8;
	Canvas.DrawText(" Target.Location:"@Target.Location);
	Canvas.CurY -= 8;
	Canvas.DrawText(" TryToHitLocation:"@TryToHitLocation);
	Canvas.CurY -= 8;
	Canvas.DrawText(" TargetLocation:"@TargetLocation);
	Canvas.CurY -= 8;
	Canvas.DrawText(" bHidden:"@bHidden);
	Canvas.CurY -= 8;
	Canvas.DrawText(" alpha:"@alpha);
	Canvas.CurY -= 8;
	Canvas.DrawText(" bUseTargetLocation:"@bUseTargetLocation);
	Canvas.CurY -= 8;
	Canvas.DrawText(" BeamCloseTime:"@BeamCloseTime);
	Canvas.CurY -= 8;

	// TryToHitLocation
	offset = TryToHitLocation;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 255, 0, 0);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 255, 0, 0);
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset + vect(0, 0, -10), 255, 0, 0);

	// EndOfTrace
	offset = EndOfTrace;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 0, 0, 255);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 0, 0, 255);
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset + vect(0, 0, -10), 0, 0, 255);

	// Location -> EndOfTrace
	Canvas.DrawLine3D(Location, EndOfTrace, 0, 255, 0);
}

defaultproperties
{
     Damage=5.000000
     BeamCloseTime=1.000000
     Amplitude=20.000000
     ParticleCount=60
     ParticleTexture(0)=Texture'RuneFX.Beam2'
     NumConPts=20
     bUseTargetLocation=True
}
