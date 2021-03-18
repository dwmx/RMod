//=============================================================================
// ProjectileGenerator.
//=============================================================================
class ProjectileGenerator expands Keypoint;

var() bool			bTrackPlayer;
var() bool			bLeadPlayer;
var() bool			bInitiallyActive;
var() class<Projectile>	ProjectileClass;
var() float			DelayMin;
var() float			DelayMax;
var() float			AttackRadius;

// INSTANCE VARIABLES ---------------------------------------------------------

// FUNCTIONS ------------------------------------------------------------------

// STATES ---------------------------------------------------------------------

auto state Waiting
{
	function BeginState()
	{
		if (bInitiallyActive)
		{
			bInitiallyActive = false;
			Trigger(self, None);
		}
	}

	function Trigger(actor other, pawn eventInstigator)
	{
		GotoState('FireProjectiles');
	}
}


state FireProjectiles
{
	function Trigger(actor other, pawn eventInstigator)
	{
		GotoState('Waiting');
	}

	function LaunchProjectile()
	{
		local PlayerPawn P;
		local projectile proj;
		local vector vec, jitter;
		local rotator rot;

		if(bTrackPlayer)
		{
			// Find the first player in a given radius
			foreach VisibleActors(class'PlayerPawn', P, AttackRadius, Location)
			{ // Grab the first player visible
				if(P.Health > 0)					
					break;				
			}

			if(P == None)
				return; // No player found, so don't launch a projectile

			// Compute a slight bit of jitter for the projectile direction
			jitter = VRand() * 25;

			// Lead the player			
			if(bLeadPlayer)
			{
				jitter.X += P.Velocity.X * 0.6;
				jitter.Y += P.Velocity.Y * 0.6;
			}

			// Compute the vector to the player
			vec = Normal((P.Location + jitter) - Location);
			rot = rotator(vec);			
		}
		else
		{
			rot = Rotation;
			vec = vector(rot);
		}

		proj = Spawn(ProjectileClass, self,, Location, rot);

		if(proj != None)
			proj.Velocity = vec * proj.Speed;
	}

begin:
	LaunchProjectile();
	Sleep(RandRange(DelayMin, DelayMax));
	Goto('begin');
}

defaultproperties
{
     bTrackPlayer=True
     bLeadPlayer=True
     bInitiallyActive=True
     DelayMin=1.000000
     DelayMax=1.000000
     AttackRadius=2000.000000
     bStatic=False
     bDirectional=True
     CollisionRadius=32.000000
     CollisionHeight=8.000000
}
