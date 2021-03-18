//=============================================================================
// ScriptPoint.
//=============================================================================
class ScriptPoint expands NavigationPoint;

/* Description:
	When a pawn is 'Scripting', he navigates to a ScriptPoint, executes the
	ScriptPoint's ReachOrders, then executes the ScriptPoint's NextOrders

*/

var(ProgOnly) name		ArriveState;		// Special State to go to upon arrival
var(ProgOnly) name		ArriveStateTag;		// Associated object
var(ProgOnly) name		ArriveStateLabel;	// Assoicated label
var(ScriptAnim) name	ArriveAnim;			// Animation to play upon arriving
var(ScriptAnim) float	ArrivePause;		// Time to wait upon arrival
var(ScriptSnd) Sound	ArriveSound;		// Sound to play upon arrival
var(ScriptVars) name	ArriveEvent;		// Event to trigger upon arrival (TODO: Change to use event)

var(ScriptVars) name	NextOrder;			// Order to execute after ReachOrder
var(ScriptVars) name	NextOrderTag;		// associated object

var(ScriptVars) bool	bWalkToThisPoint;	// Whether to walk or run to this point
var(ScriptVars) bool	bReleaseUponArrival;// Once point is reached, release to AI
var(ScriptVars) bool	bTurnToRotation;	// Turn to ScriptPoint's rotation
var(ScriptSync) name	LookTarget;			// Target to look at

defaultproperties
{
     bTurnToRotation=True
     bDirectional=True
     Texture=Texture'Engine.S_Point'
}
