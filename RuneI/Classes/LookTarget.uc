//=============================================================================
// LookTarget.
//=============================================================================
class LookTarget expands Keypoint;

var() bool bInitiallyActive;

function PreBeginPlay()
{
	if(!bInitiallyActive)
		bHidden = true;
	else
		bHidden = false;		
}

function Trigger(actor Other, pawn EventInstigator)
{
	// Toggle hidden value (which will toggle between it being visible to Ragnar
	if(bHidden)
		bHidden = false;
	else
		bHidden = true;
}

defaultproperties
{
     bInitiallyActive=True
     bHidden=False
     bSpecialRender=True
     bLookFocusPlayer=True
     Texture=Texture'RuneFX.EyeCon'
}
