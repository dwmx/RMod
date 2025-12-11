/////////////////////////////////////////////////////////////////////////////////
//  Vmod_RunePlayerCamera
//  Actor class encompassing camera behavior for a Vmod_RunePlayer
//  For custom behavior, subclass this and set Vmod_RunePlayer.m_cameraClass
class R_ACamera extends Actor abstract;//Vmod_RunePlayerComponent;

var Pawn ViewTarget;

replication
{
	// Variables set by server
	reliable if(Role == ROLE_Authority)
		ViewTarget;
}

/////////////////////////////////////////////////////////////////////////////////
function bool IsActorRelevantToView(Actor A)
{
    //  Implemented in states
    return true;
}

/////////////////////////////////////////////////////////////////////////////////
event PlayerCalcView(
    out Actor ViewActor,
    out vector CameraLocation,
    out rotator CameraRotation)
{
    //  Implemented in states
}

event PostRender(Canvas C)
{}

// Optional input functions called from Vmod_RunePlayer
function Input_MouseAxis(float MouseX, float MouseY) {}
function Input_Fire()				{}
function Input_RunePower()			{}
function Input_Use()				{}
function Input_CameraIn()			{}
function Input_CameraOut()			{}

//  TODO: Camera mode ideas
//      - Smooth out camera movement!
//      - Player point of view
//      - Player point of view with enemy focus
//      - Free-follow
//      - All follow states implemented with input tolerance

defaultproperties
{
     RemoteRole=ROLE_AutonomousProxy
     DrawType=DT_None
}
