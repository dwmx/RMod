//=============================================================================
// PawnFire.
//=============================================================================
class PawnFire expands Fire;


var() float DamagePerSecond;
var float ElapsedTime;


function PostBeginPlay()
{
	LifeSpan=RandRange(3, 4);
}

//TODO: Could make a single particle system that spawns particles at AttachParent joints
// for more centralized control
function Tick(float DeltaTime)
{
	ElapsedTime += DeltaTime;

	if (AttachParent != None)
	{
		if (ElapsedTime > 1)
		{
			ElapsedTime = 0;

			// Skinnify victim
			if (AttachParent.IsA('Pawn')||AttachParent.IsA('Carcass'))
			{
				if(!AttachParent.IsA('PlayerPawn') && AttachParent.DesiredFatness > 90)
					AttachParent.DesiredFatness -= 1;

				// Damage victim
				AttachParent.JointDamaged(DamagePerSecond, Pawn(Owner), AttachParent.Location, vect(0,0,0), 'fire', AttachParentJoint);
				if (AttachParent.bDeleteMe)
					SetTimer(0, false);
			}

		}
		
		// Darken victim
		if (AttachParent.Skeletal!=None && AttachParent.NumJoints() > 4)
		{
			if(AttachParent.ScaleGlow > 0.25)
				AttachParent.ScaleGlow -= 0.05 * DeltaTime;
		}
		else
		{
			if(AttachParent.ScaleGlow > 0.25)
				AttachParent.ScaleGlow -= 0.4 * DeltaTime;
		}
	}
}

defaultproperties
{
     DamagePerSecond=1.000000
     ParticleCount=8
     ShapeVector=(X=8.000000,Y=8.000000)
     VelocityMin=(Z=50.000000)
     VelocityMax=(Z=120.000000)
     ScaleMax=1.100000
     LifeSpanMax=0.600000
     bStasis=False
}
