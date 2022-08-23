//=============================================================================
// VerticalCurrent.
//=============================================================================
class VerticalCurrent extends Keypoint;

var() vector ApplyVelocity;
var int TouchingCount;


function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function Touch(actor Other)
{
	TouchingCount++;
	SetTimer(0.1, true);
}

function UnTouch(actor Other)
{
	TouchingCount--;
	if (TouchingCount <= 0)
	{
		TouchingCount = 0;
		SetTimer(0, false);
	}
}

function Timer()
{
	local actor A;

	if (TouchingCount <= 0)
		return;

	foreach TouchingActors( class'actor', A)
	{
		A.Velocity += ApplyVelocity;
	}
}

defaultproperties
{
     ApplyVelocity=(Z=500.000000)
     bStatic=False
     CollisionRadius=100.000000
     CollisionHeight=300.000000
     bCollideActors=True
     bCollideWorld=True
}
