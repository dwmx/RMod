//=============================================================================
// CineCamera.
//
// RUNE:  Cinematic Camera.  Controls the camera on players during in-game cutscenes
//=============================================================================
class CineCamera expands Keypoint;

const DIST_THRESH = 5;

var CineInterpolationPoint FirstNode;
var CineInterpolationPointTemp StartPt, EndPt;
var CineInterpolationPointTemp StartPt2, EndPt2;
var float StartSpeed;	// Speed to initially interpolate the camera to the CinePoint
var float EndSpeed; // Speed to interpolate the camera back to behind the player
var bool bInteruptable;


function BeginPlay()
{
	local RunePlayer P;
//	local name StateName;
	
	// When spawned, take control of the camera on all players in the game
	// TODO:  This takes the location/rotation from the last player in the game
	// Need a different scheme so that this doesn't pop the camera in netgames?
	foreach AllActors(class'RunePlayer', P)
	{
		if (P.Health > 0)
		{
			P.ViewTarget = self;
			SetLocation(P.SavedCameraLoc);
			SetRotation(P.SavedCameraRot);
			
			P.OrderObject = None;
			P.GotoState('Scripting');

			if(P.myHud != None)
			{
				P.myHud.GotoState('Cinematic', 'begin');
			}
		}
		else
		{
			Destroy();
			break;
		}
	}
}

//============================================================================
//
// ResetPath
//
// Reset the path to it's original state
//============================================================================
function ResetPath()
{
	// Reset the path to its original state
	if (FirstNode != None && EndPt != None)
	{
		FirstNode.Prev = EndPt.Prev;
		if(FirstNode.Prev != None)
		{
			FirstNode.Prev.Next = FirstNode;
		}
	}
	
	// Destroy the StartPoints
	if(StartPt != None)
	{
		StartPt.Destroy();
	}
	if(StartPt2 != None)
	{
		StartPt2.Destroy();
	}

	// Destroy the EndPoint
	if(EndPt != None)
	{
		EndPt.Destroy();
	}
				
	Destroy(); // Remove the CineCamera
}


//============================================================================
//
// FireLastPointEvent
//
//============================================================================
function FireLastPointEvent()
{
	local CineInterpolationPoint i;
	
	// Call the event of the last editor-placed point to cleanup
	foreach AllActors(class 'CineInterpolationPoint', i, Event)
	{
		if(i.Next != None && (i.Next.IsA('CineInterpolationPointTemp') || i.Next.Position == 0))
		{ // Found the last point that was editor-placed
			i.FireEvent(i.Event);
			return;
		}
	}
}


//============================================================================
//
// StartCam
//
// Starts the camera on a given interpolation path
//============================================================================

function StartCam(bool Smooth, bool Interuptable)
{
	local CineInterpolationPoint i;
	local InterpolationPoint oldPrev;

	bInteruptable = Interuptable;

	foreach AllActors(class 'CineInterpolationPoint', i, Event)
	{
		if(i.Position == 0)
		{ // Found a matching path

			if(Smooth)
			{ // Smoothly interpolate from the current position to the start of the path			
				// Create three "dummy" points to smooth out the start and end of the
				// path from the camera point						
				FirstNode = i;
				oldPrev = i.Prev;

				StartPt = Spawn(class'CineInterpolationPointTemp',,, Location, Rotation);
				StartPt2 = Spawn(class'CineInterpolationPointTemp',,, Location, Rotation);
				EndPt = Spawn(class'CineInterpolationPointTemp',,, Location, Rotation);

				// Copy bool bSplineThruPoints to the dummy points
				StartPt.bSplineThruPoints = i.bSplineThruPoints;
				StartPt2.bSplineThruPoints = i.bSplineThruPoints;
				EndPt.bSplineThruPoints = i.bSplineThruPoints;

				StartPt.Prev = EndPt;
				StartPt2.Prev = StartPt;
				StartPt.Next = StartPt2;
				StartPt2.Next = i;

				EndPt.Prev = oldPrev;
				EndPt.Next = StartPt;
				if(EndPt.Prev != None)
				{
					EndPt.Prev.Next = EndPt;
				}

				i.Prev = StartPt;			

				EndPt.bEndOfPath = true; // Guarantee that the pathing will finish

				Target = StartPt;
			}
			else
			{ // Instantly start at the path
				Target = i;
			}
			
			SetPhysics(PHYS_Interpolating);
			PhysRate = 1.0;
			PhysAlpha = 0.0;
			bInterpolating = true;
			
			GotoState('Interpolating');						
			return;
		}
	}
}

//============================================================================
//
// STATE Interpolating
//
//============================================================================

state Interpolating
{
	//========================================================================
	//
	// Timer
	//
	// Tripped when the CineCamera Pauses at an interpolation point
	//========================================================================

	function Timer()
	{
		bInterpolating = true; // Resume interpolation
	}

	//========================================================================
	//
	// InterpolateEnd
	//
	// Called when the CineCamera hits an interpolation point
	//========================================================================

	function InterpolateEnd(Actor Other)
	{	
		local RunePlayer P;
		local CineInterpolationPoint I;
		
		I = CineInterpolationPoint(Other);

		// This is a bit of a hack.
		// What this does is updates the dummy points to reflect the
		// new location of the SavedCamera position.  This must be done
		// because the camera position will have moved slightly due to the
		// Camera smoothing.  Without this adjustment the CineCamera will "pop"
		// a bit at the end.  Enough to be jarring.
		if(I.Next.Next.Next != None && I.Next.Next.Next == EndPt)
		{
			foreach AllActors(class'RunePlayer', P)
			{
				StartPt.SetLocation(P.SavedCameraLoc);
				StartPt.SetRotation(P.SavedCameraRot);
				StartPt2.SetLocation(P.SavedCameraLoc);
				StartPt2.SetRotation(P.SavedCameraRot);
				EndPt.SetLocation(P.SavedCameraLoc);
				EndPt.SetRotation(P.SavedCameraRot);
				break;
			}
		}
		
		// Pause if the interpolation point has a PauseTime
		if(I.PauseTime > 0)
		{
			bInterpolating = false; // Stop interpolating for now
			SetTimer(I.PauseTime, false);
		}
		
		if(I.bEndOfPath)
		{ // One past the end of path, so remove the cinecamera!		
			foreach AllActors(class'RunePlayer', P)
			{
				if(P.ViewTarget == self)
				{
					P.ReleaseFromCinematic();
				}
			}
			
			ResetPath();
		}
	}
	
begin:
}

defaultproperties
{
     bStatic=False
     Physics=PHYS_Flying
}
