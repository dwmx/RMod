//=============================================================================
// Performer.
//=============================================================================
class Performer extends Cinematography;

// All performers in a movie are linked.  Singly linked list terminated
// by None.  The head of the list is the camera performer.
var Performer Next;

defaultproperties
{
     DrawType=DT_SkeletalMesh
}
