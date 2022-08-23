//=============================================================================
// TreeGrow.
//=============================================================================
class TreeGrow extends TreePt;


var() bool bPreGrow;				// Grow to full size before gameplay starts
var() float GrowthRate;				// Units per second of branch growth
var() float BlossomRate;			// Drawscale units per second of blossom growth
var() float MatureBranchLength;		// Max length for branches before sprouting
var() int ComplexityOrder;			// max branches from a parent [1..5]
var() int Fertility;				// inherited fertility, when this reaches 0, tree dies
var int Generation;

//--------------------------------------------------------
// Functions
//--------------------------------------------------------


// A point spawns a new bud
function Sprout()
{
	local TreeGrow child;
	local int i,numbranches,PortionOfFertility;

	if (Fertility <= 0)
		return;

	if (Generation < 2)
		numbranches = 1;
	else
		numbranches = int(RandRange(2, ComplexityOrder));

	PortionOfFertility = Fertility / numbranches;
	for (i=0; i<numbranches; i++)
	{
		child = Spawn(class'TreeGrow',,,Location);
		child.Parent = self;
		child.GravDir = Normal(VRand()+vect(0,0,1));
		child.BranchLength = 1;
		child.Target = self;
		child.bPreGrow = bPreGrow;
		child.Generation = Generation + 1;
		if (Generation > 1)
		{	// Not root
			child.bAffectsParent=True;
		}
		child.Fertility = PortionOfFertility;

		if (child.bPreGrow)
			child.GotoState('PreGrowing');
		else
			child.GotoState('Growing');
		DrawType=DT_ParticleSystem;		// Whither from blossum to normal branch
		bLeaf = false;
	}
}



//--------------------------------------------------------
// States
//--------------------------------------------------------

// These used to grow trees (move to subclass)
auto State Seed
{
	ignores Tick;

	function BeginState()
	{
		if (bPreGrow)
			GotoState('PreGrowing');
	}

	function Trigger(actor Other, Pawn EventInstigator)
	{
		GotoState('Growing');
	}

Begin:
}


State Growing
{
	function Tick(float DeltaTime)
	{
		local TreePt point;

		if (DrawScale < 1.0)
		{	// Grow blossoms
			DrawScale += BlossomRate*DeltaTime;
		}

		if (BranchLength < MatureBranchLength)
		{	// Grow branches
			BranchLength += GrowthRate*DeltaTime;
		}
		else
		{
			Sprout();
			GotoState('Active');
		}

		if (bLeaf)
		{
			point = self;
			while (point != None)
			{
				ApplySwing(point.Parent, point, DeltaTime);
				point = point.Parent;
			}
		}
	}
	
	function BeginState()
	{
		if (Parent==None)
		{	// Root
			DrawType = DT_None;
			DrawScale = 1.0;
			BranchLength = MatureBranchLength;
			Sprout();
			GotoState('Active');
		}
		else
		{
			SetPhysics(PHYS_PROJECTILE);
		}
	}

	function EndState()
	{
	}

Begin:

}


State PreGrowing
{
	ignores Tick;

Begin:
	DrawScale = 1.0;
	BranchLength = MatureBranchLength;
	Sprout();
	Velocity=vect(0,0,1);	// Disallow going inactive immediately
	GotoState('Active');
}

defaultproperties
{
     GrowthRate=50.000000
     BlossomRate=0.500000
     MatureBranchLength=40.000000
     ComplexityOrder=2
     Fertility=5
     bAffectsParent=False
     BranchLength=1.000000
     ParticleCount=6
     ParticleTexture(0)=Texture'RuneFX.bark2'
     NumConPts=2
     BeamThickness=2.000000
     Physics=PHYS_None
     DrawType=DT_SkeletalMesh
     DrawScale=0.100000
     Skeletal=SkelModel'objects.Leaf'
}
