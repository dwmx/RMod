//=============================================================================
// PatrolPoint.
//=============================================================================
class PatrolPoint extends NavigationPoint;

#exec Texture Import File=Textures\Pathnode.pcx Name=S_Patrol Mips=Off Flags=2

var() name Nextpatrol; //next point to go to
var() float pausetime; //how long to pause here
var	 vector lookdir; //direction to look while stopped
var() name PatrolAnim;
var() sound PatrolSound;
var() byte numAnims;
var int	AnimCount;
var PatrolPoint NextPatrolPoint;


function PreBeginPlay()
{
	if (pausetime > 0.0)
		lookdir = 200 * vector(Rotation);

	//find the patrol point with the tag specified by Nextpatrol
	foreach AllActors(class 'PatrolPoint', NextPatrolPoint, Nextpatrol)
		break; 
	
	Super.PreBeginPlay();
}


// CONSTANTS AND ENUMERATIONS -------------------------------------------------

/*
const MAXPATROLLINKS = 4;
*/

// STRUCTURES -----------------------------------------------------------------

/*
struct PatrolLink
{
	var() name			NextPatrolName;
	var() float			NextPatrolChance;
	var PatrolPoint		NextPatrolPoint;
};
*/

// EDITABLE INSTANCE VARIABLES ------------------------------------------------

/*
var() PatrolLink	PLink[4];
var() float			pausetime;
					//how long to pause here

var() name			PatrolAnim;
var() sound			PatrolSound;
var() byte			numAnims;
*/

// INSTANCE VARIABLES ---------------------------------------------------------

/*
var int				AnimCount;
var PatrolPoint		NextPatrolPoint;
var vector			lookdir;
					// Direction to look while stopped.
*/

// FUNCTIONS ------------------------------------------------------------------

/*
function PreBeginPlay()
{
	local PatrolPoint patPoint;

	if(pausetime > 0.0)
	{
		lookdir = 200 * vector(Rotation);
	}

	//find the patrol point with the tag specified by Nextpatrol
	for(i = 0; i < MAXPATROLLINKS; i++)
	{
		foreach AllActors(class 'PatrolPoint', patPoint, PLink[i].NextPatrolName)
		{
			PLink[i].NextPatrolPoint = patPoint;
			break;
		}
	}

	Super.PreBeginPlay();
}
*/

defaultproperties
{
     bDirectional=True
     Texture=Texture'Engine.S_Patrol'
     SoundVolume=128
}
