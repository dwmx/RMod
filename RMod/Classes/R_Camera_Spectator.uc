class R_Camera_Spectator extends R_ACamera;

const CAMERA_DISTANCE_MIN = 60.0;
const CAMERA_DISTANCE_MAX = 600.0;
const CAMERA_INCREMENT = 60.0;

// RunePlayer camera variable reimplementation for spectator mode
var private float CurrentTime;
var private float LastTime;
var private float CameraDist;
var private float CameraPitch;
var private float CameraHeight;
var private float CurrentDist;
var private float CameraAccel;
var private float EyeHeight; // Pull this in view
var private Vector OldCameraStart;
var private Rotator CurrentRotation;
var private Rotator CameraRotSpeed;
var private Rotator ViewRotation;
var private Vector ViewLocation;
var private Vector	SavedCameraLoc;
var private Rotator SavedCameraRot;
var private bool bBehindView;
var private bool bCameraLock;
var private bool bCameraOverhead;
var private bool bGotoFP;

// Allows player to control the camera in rotation-lock modes like pov
var struct FMouseAxisThreshold
{
	var float TimeStamp;
	var float MouseX;
	var float MouseY;
} MouseAxisThreshold;

var enum ECameraMode
{
	CAM_Free,
	CAM_FollowTarget,
	CAM_FollowTargetPov
} CameraMode;

replication
{
	// Variables set by server
	reliable if(Role == ROLE_Authority)
		CameraDist,
		CameraMode;
}

////////////////////////////////////////////////////////////////////////////////
//	PreBeginPlay
//	Overridden to reimplement RunePlayer camera settings, used in
//	PlayerCalcViewExtended
event PreBeginPlay()
{
	Super.PreBeginPlay();
	OldCameraStart = Location;
	OldCameraStart.Z += CameraHeight;
	
	CurrentDist = CameraDist;
	LastTime = 0;
	CurrentTime = 0;
	CurrentRotation = Rotation;
}

event PostBeginPlay()
{
	// Default to POV mode
	SelectCameraMode(CAM_FollowTargetPov);
}

////////////////////////////////////////////////////////////////////////////////
//	Tick
//	Overridden to reimplement RunePlayer camera settings, used in
//	PlayerCalcViewExtended
event Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);
	CurrentTime += DeltaSeconds / Level.TimeDilation;
	
	// If camera mode requires a ViewTarget, make sure its valid
	if(Role == ROLE_Authority && CameraMode != CAM_Free)
	{
		if(!IsValidViewTarget(ViewTarget))
		{
			SelectNextViewTarget();
			if(!IsValidViewTarget(ViewTarget))
				SelectCameraMode(CAM_Free);
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
//	Mouse axis threshold
function Input_MouseAxis(float MouseX, float MouseY)
{
	MouseAxisThreshold.MouseX = MouseX;
	MouseAxisThreshold.MouseY = MouseY;
}

function bool UpdateAndCheckMouseAxisThreshold()
{
	// Check if the player is moving their mouse
    if(Self.MouseAxisThreshold.MouseX != 0.0
    || Self.MouseAxisThreshold.MouseY != 0.0)
    {
        Self.MouseAxisThreshold.TimeStamp = Level.TimeSeconds;
    }
	// Time delay before releasing player's mouse hold
    if((Level.TimeSeconds - Self.MouseAxisThreshold.TimeStamp) <= 0.5)
	{
        return true;
	}
    return false;
}

////////////////////////////////////////////////////////////////////////////////
//	View mode cycling
//	Use input cycles through camera modes
function Input_Use()
{
	SelectNextCameraMode();
}

function SelectNextCameraMode()
{
	switch(CameraMode)
	{
	case CAM_Free:
		SelectCameraMode(CAM_FollowTarget);
		break;
	case CAM_FollowTarget:
		SelectCameraMode(CAM_FollowTargetPov);
		break;
	case CAM_FollowTargetPov:
		SelectCameraMode(CAM_Free);
		break;
	default:
		SelectCameraMode(CAM_Free);
		break;
	}
}

function bool IsValidViewTarget(Pawn P)
{
	// Universal checks
	if(P == None
	|| P == Self.Owner
	|| P.GetStateName() == 'PlayerSpectating')
	{
		return false;
	}

	// Pawn only checks
	if(PlayerPawn(P) == None)
	{
		if(P.Health <= 0)
		{
			return false;
		}
	}

	// PlayerPawn checks
	if(PlayerPawn(P) != None)
	{
		if(PlayerPawn(P).PlayerReplicationInfo == None
		|| PlayerPawn(P).PlayerReplicationInfo.bIsSpectator
		|| PlayerPawn(P).Player == None
		|| !PlayerPawn(P).bIsPlayer)
		{
			return false;
		}
	}

	return true;
}

function SelectCameraMode(ECameraMode CM)
{
	if(CameraMode == CM)
		return;

	// If spectating a target, make sure its valid
	if(CM != CAM_Free)
	{
		if(!IsValidViewTarget(ViewTarget))
		{
			SelectNextViewTarget();
		}
		if(!IsValidViewTarget(ViewTarget))
		{
			CM = CAM_Free;
		}
	}
	
	if(CameraMode == CM)
		return;
	CameraMode = CM;
	
	switch(CameraMode)
	{
	case CAM_Free:
		Pawn(Owner).ClientMessage("Free-spectate mode");
		ViewTarget = None;
		break;
	case CAM_FollowTarget:
		Pawn(Owner).ClientMessage("Viewing from follow-target mode");
		break;
	case CAM_FollowTargetPov:
		Pawn(Owner).ClientMessage("Viewing from POV mode");
		break;
	}
}

////////////////////////////////////////////////////////////////////////////////
//	View target cycling
function Input_Fire()
{
	if(Role == ROLE_Authority)
	{
		if(CameraMode != CAM_Free)
		{
			SelectNextViewTarget();
		}
	}
}

function SelectNextViewTarget()
{
	local Pawn Candidates[64];
	local int CandidateCount;
	local Pawn P;
	local int i;
	
	if(Role < ROLE_Authority)
	{
		return;
	}
	
	CandidateCount = 0;
	for(P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if(IsValidViewTarget(P))
		{
			Candidates[CandidateCount] = P;
			++CandidateCount;
		}
	}
	
	if(ViewTarget == None)
	{
		ViewTarget = Candidates[0];
        OnViewTargetChanged();
		return;
	}
	
	for(i = 0; i < CandidateCount; ++i)
	{
		if(Candidates[i] == ViewTarget)
		{
			break;
		}
	}
	
	if(i == CandidateCount)
	{
		ViewTarget = Candidates[0];
        OnViewTargetChanged();
		return;
	}
	else
	{
		ViewTarget = Candidates[(i + 1) % CandidateCount];
        OnViewTargetChanged();
		return;
	}
}

function OnViewTargetChanged()
{
    local String DrawString;

    if(ViewTarget == None)
    {
        return;
    }

    if(ViewTarget.PlayerReplicationInfo != None)
    {
        DrawString = ViewTarget.PlayerReplicationInfo.PlayerName;
    }
    else
    {
        DrawString = String(ViewTarget);
    }
    DrawString = "Now spectating" @ DrawString;
    Pawn(Owner).ClientMessage(DrawString);
}

////////////////////////////////////////////////////////////////////////////////
//	Camera distance
function Input_CameraIn()
{
	CameraDist -= CAMERA_INCREMENT;
	CameraDist =
		FClamp(CameraDist, CAMERA_DISTANCE_MIN, CAMERA_DISTANCE_MAX);
}

function Input_CameraOut()
{
	CameraDist += CAMERA_INCREMENT;
	CameraDist =
		FClamp(CameraDist, CAMERA_DISTANCE_MIN, CAMERA_DISTANCE_MAX);
}

////////////////////////////////////////////////////////////////////////////////
//	PlayerCalcView
//	Display camera view based on current camera mode
event PlayerCalcView(
	out Actor ViewActor,
	out vector CameraLocation,
	out rotator CameraRotation)
{
	switch(Self.CameraMode)
	{
	case CAM_Free:
		PlayerCalcView_CAM_Free(
			ViewActor, CameraLocation, CameraRotation);
		break;
	case CAM_FollowTarget:
		PlayerCalcView_CAM_FollowTarget(
			ViewActor, CameraLocation, CameraRotation);
		break;
	case CAM_FollowTargetPov:
		PlayerCalcView_CAM_FollowTargetPov(
			ViewActor, CameraLocation, CameraRotation);
		break;
	}
}

// ECameraMode.CAM_Free
function PlayerCalcView_CAM_Free(
	out Actor ViewActor,
	out vector CameraLocation,
	out rotator CameraRotation)
{
	local PlayerPawn P;
	local Vector BaseLocation;
	
	P = PlayerPawn(Self.Owner);
	if(P == None)
	{
		return;
	}
	
	BaseLocation = P.Location;
	Self.ViewRotation = Pawn(Self.Owner).ViewRotation;
	
	PlayerCalcViewExtended(
		ViewActor,
		CameraLocation,
		CameraRotation,
		BaseLocation,
		Self.ViewRotation);
	Self.ViewLocation = CameraLocation;
	Self.ViewRotation = CameraRotation;
	Self.SetLocation(Self.ViewLocation);
	Self.SetRotation(Self.ViewRotation);
	ViewActor = Self.Owner;
}

// ECameraMode.CAM_FollowTarget
function PlayerCalcView_CAM_FollowTarget(
	out Actor ViewActor,
	out vector CameraLocation,
	out rotator CameraRotation)
{
	local Vector BaseLocation;

	if(ViewTarget == None)
	{
		return;
	}
	
	BaseLocation = ViewTarget.Location;
	Self.ViewRotation = Pawn(Self.Owner).ViewRotation;

	PlayerCalcViewExtended(
		ViewActor,
		CameraLocation,
		CameraRotation,
		BaseLocation,
		Self.ViewRotation);
	Self.ViewLocation = CameraLocation;
	Self.ViewRotation = CameraRotation;
	Self.SetLocation(Self.ViewLocation);
	Self.SetRotation(Self.ViewRotation);
	ViewActor = ViewTarget;
	
	// Owner must follow camera or there will be replication issues
	Self.Owner.SetLocation(Self.Location);
	Self.Owner.SetRotation(Self.Rotation);
}

// ECameraMode.CAM_FollowTargetPov
function PlayerCalcView_CAM_FollowTargetPov(
	out Actor ViewActor,
	out vector CameraLocation,
	out rotator CameraRotation)
{
	local Vector BaseLocation;
	local Rotator BaseRotation;
	
	// Allow player to free look
	if(UpdateAndCheckMouseAxisThreshold())
	{
		PlayerCalcView_CAM_FollowTarget(
			ViewActor,
			CameraLocation,
			CameraRotation);
		return;
	}
	
	if(ViewTarget == None)
	{
		return;
	}
	
	BaseLocation = ViewTarget.Location;
	if(R_RunePlayer(ViewTarget) != None)
	{
		BaseRotation = R_RunePlayer(ViewTarget).GetViewRotPov();
	}
	else
	{
		BaseRotation = ViewTarget.Rotation;
	}
	
	PlayerCalcViewExtended(
		ViewActor,
		CameraLocation,
		CameraRotation,
		BaseLocation,
		BaseRotation);
	Self.ViewLocation = CameraLocation;
	Self.ViewRotation = CameraRotation;
	Self.SetLocation(Self.ViewLocation);
	Self.SetRotation(Self.ViewRotation);
	ViewActor = ViewTarget;
	
	Pawn(Self.Owner).ViewRotation = Self.ViewRotation;
	
	// Owner must follow camera or there will be replication issues
	Self.Owner.SetLocation(Self.Location);
	Self.Owner.SetRotation(Self.Rotation);
}

////////////////////////////////////////////////////////////////////////////////
//	PlayerCalcViewExtended
//	Extension off of the original RunePlayer.PlayerCalcView function so that
//	spectators can pipe different view targets through the same camera code
function PlayerCalcViewExtended(
    out Actor       ViewActor,
    out Vector      CameraLocation,
    out Rotator     CameraRotation,
    Vector          BaseLocation,
    Rotator         BaseRotation)
{
    local vector View,HitLocation,HitNormal;
    local float ViewDist, WallOutDist;

    local vector PlayerLocation;
    local vector loc;
    local rotator rot;
    local vector desiredLoc;
    local vector currentLoc;
    local vector cameraVect, newVect;
    local float accel;
    local float deltaTime;
    local vector startPt;
    local vector endPt;
    local bool done;
    local float desiredDist;
    local float diff;
    local rotator targetangle;
    
    local vector extent; // trace extent
    
    // Calculate time change
    deltaTime = CurrentTime - LastTime;

    // View rotation.
    //ViewActor = Self;

    // Handle view shaking
    //ViewShake(deltaTime);
    //targetAngle = ViewRotation + ShakeDelta;
    targetAngle = BaseRotation;// + ShakeDelta;
    
    //PlayerLocation = Location + PrePivot;
    PlayerLocation = BaseLocation + PrePivot;

    //if(Region.Zone != None && Region.Zone.bTakeOverCamera)
    //{
    //    CameraLocation = Region.Zone.Location;
    //    loc = PlayerLocation;
    //    loc.Z += EyeHeight;
    //    CameraRotation = rotator(loc - CameraLocation);
    //    ViewLocation = CameraLocation;
    //    return;
    //}

    if(RemoteRole != ROLE_AutonomousProxy && (deltaTime < 0.1 && deltaTime > 0))
    { // Local Player Only (deltaTime == 0.0 for remote players on the server)
        // Interpolate Yaw
        targetAngle.Yaw = targetAngle.Yaw & 65535;
        CurrentRotation.Yaw = CurrentRotation.Yaw & 65535;
        diff = targetAngle.Yaw - CurrentRotation.Yaw;
        if(abs(diff) > 32768)
        { // Handle wrap around case
            if(targetAngle.Yaw > 32768)
            {
                targetAngle.Yaw -= 65536;;
            }
            else
            {
                targetAngle.Yaw += 65536;
            }
            
            diff = targetAngle.Yaw - CurrentRotation.Yaw;
        }   

        if(abs(diff) < 10)
        {
            CurrentRotation.Yaw = targetAngle.Yaw;
        }
        else
        {       
            CurrentRotation.Yaw += deltaTime * diff * CameraRotSpeed.Yaw;
            
            if((diff < 0 && CurrentRotation.Yaw < targetAngle.Yaw)
                || (diff > 0 && CurrentRotation.Yaw > targetAngle.Yaw))
            { // Guard against overshooting targetangle
                CurrentRotation.Yaw = targetAngle.Yaw;
            }       
        }

        // Interpolate Pitch
        targetAngle.Pitch = targetAngle.Pitch & 65535;
        CurrentRotation.Pitch = CurrentRotation.Pitch & 65535;
        diff = targetAngle.Pitch - CurrentRotation.Pitch;
        if(abs(diff) > 32768)
        { // Handle wrap around case
            if(targetAngle.Pitch > 32768)
            {
                targetAngle.Pitch -= 65536;;

            }
            else
            {
                targetAngle.Pitch += 65536;
            }
            
            diff = targetAngle.Pitch - CurrentRotation.Pitch;
        }   
        if(abs(diff) < 10)
        {
            CurrentRotation.Pitch = targetAngle.Pitch;
        }
        else
        {       
            CurrentRotation.Pitch += deltaTime * diff * CameraRotSpeed.Pitch;
            
            if((diff < 0 && CurrentRotation.Pitch < targetAngle.Pitch)
                || (diff > 0 && CurrentRotation.Pitch > targetAngle.Pitch))
            { // Guard against overshooting targetangle
                CurrentRotation.Pitch = targetAngle.Pitch;
            }       
        }
        
        // Interpolate Roll
        targetAngle.Roll = targetAngle.Roll & 65535;
        CurrentRotation.Roll = CurrentRotation.Roll & 65535;
        diff = targetAngle.Roll - CurrentRotation.Roll;
        if(abs(diff) > 32768)
        { // Handle wrap around case
            if(targetAngle.Roll > 32768)
            {
                targetAngle.Roll -= 65536;;
            }
            else
            {
                targetAngle.Roll += 65536;
            }
            
            diff = targetAngle.Roll - CurrentRotation.Roll;
        }   
        if(abs(diff) < 10)
        {
            CurrentRotation.Roll = targetAngle.Roll;
        }
        else
        {       
            CurrentRotation.Roll += deltaTime * diff * CameraRotSpeed.Roll;
            
            if((diff < 0 && CurrentRotation.Roll < targetAngle.Roll)
                || (diff > 0 && CurrentRotation.Roll > targetAngle.Roll))
            { // Guard against overshooting targetangle
                CurrentRotation.Roll = targetAngle.Roll;
            }       
        }
    }
    else
    { // No interpolation
        targetAngle.Yaw = targetAngle.Yaw & 65535;
        targetAngle.Pitch = targetAngle.Pitch & 65535;
        targetAngle.Roll = targetAngle.Roll & 65535;

        CurrentRotation = targetAngle;
    }

    CameraRotation = CurrentRotation;

    if(bBehindView && !bCameraLock && !bCameraOverhead)
    {
        if(CameraRotation.Pitch < 32768 && CameraRotation.Pitch > 12000)
        { // Clamp the camera to a given set of angles [should be done in control functions?]
            CameraRotation.Pitch = 12000;
        }

        WallOutDist = 15;
        rot = CameraRotation;
        endPt = PlayerLocation;

        ViewDist = CameraDist;
        if(Region.Zone.MaxCameraDist >= CollisionRadius)
        { // Zone-based camera distance
            ViewDist = Region.Zone.MaxCameraDist;
        }

        rot.Pitch -= CameraPitch;
        endPt.Z += CameraHeight;

        View = vect(1,0,0) >> rot;

        startPt = PlayerLocation;
        if(Trace(HitLocation, HitNormal, endPt, startPt) != None)
        {
            loc = HitLocation;
        }
        else
        {
            loc = endPt;
        }

        if(RemoteRole != ROLE_AutonomousProxy && (deltaTime < 0.1 && deltaTime > 0))
        { // Do interpolation of CurrentDist.  
            // Local Player Only (deltaTime == 0.0 for remote players on the server)
            diff = abs(CurrentDist - ViewDist);
            if(diff > 30)
            {
                diff = 30;
            }
            else if(diff < 0.25)
            { // Close enough, force the camera to the desired position
                CurrentDist = ViewDist;
            }
            
            if(CurrentDist < ViewDist)
            {
                CurrentDist += deltaTime * diff * 10;
                if(CurrentDist > ViewDist)
                {
                    CurrentDist = ViewDist;
                }
            }
            else if(CurrentDist > ViewDist)
            {
                CurrentDist -= deltaTime * diff * 10;
                if(CurrentDist < ViewDist)
                {
                    CurrentDist = ViewDist;
                }
            }
        }
        else
        {
            CurrentDist = ViewDist;
        }

        cameraVect = (loc - OldCameraStart);
        accel = (ViewDist / CurrentDist) * CameraAccel;
        if(RemoteRole != ROLE_AutonomousProxy && (deltaTime < 0.1 && deltaTime > 0))
        { // Local Player Only (deltaTime == 0.0 for remote players on the server)
            newVect = cameraVect * deltaTime * accel;
            if(VSize(newVect) < VSize(cameraVect))
                cameraVect = newVect;

            loc = OldCameraStart + cameraVect;
        }
        // Otherwise, loc is not interpolated

        endPt = loc - (CurrentDist + WallOutDist) * vector(rot);
        startPt = loc;

        if(Trace(HitLocation, HitNormal, endPt, startPt) != None)
        {
            CurrentDist = FMin((loc - HitLocation) dot View, CurrentDist);
        }

        if(CurrentDist < WallOutDist)
        { // Camera pulled in so close that the view should just go first person
            CurrentDist = WallOutDist;

            if(bGotoFP)
                bBehindView = false;
        }

        CameraLocation = loc - (CurrentDist - WallOutDist) * View;
        
        OldCameraStart = loc;

        // Set Tranlucency on local player if too close to a wall
        //if (CurrentDist > TranslucentDist)
        //    SetClientAlpha(1.0);
        //else
        //    SetClientAlpha(CurrentDist/TranslucentDist);
    }
    else if(bBehindView && bCameraLock)
    {
        loc = PlayerLocation;
        loc.Z += EyeHeight;
        CameraLocation = SavedCameraLoc;
        CameraRotation = rotator(loc - CameraLocation);// + ShakeDelta;
    }
    else if(bBehindView && bCameraOverhead)
    {
        CameraLocation = PlayerLocation;
        CameraLocation.Z += (CameraDist - 50) * 10;
        
        CameraRotation.Pitch = -16384;
        CameraRotation.Yaw = Rotation.Yaw;
        CameraRotation.Roll = 0;        
    }
    else
    {
        // First-person view.
        CameraRotation = ViewRotation;// + ShakeDelta;
        CameraLocation = Location;
        CameraLocation.Z += EyeHeight;
        //CameraLocation += WalkBob;
//      CameraRotation = GetJointRot(JointNamed('head'));   // too jerky, but cool
//      CameraLocation = GetJointPos(JointNamed('head'));   // too jerky
        OldCameraStart = CameraLocation;

        if(!bGotoFP)
        { // Return from first-person
            bBehindView = true;
        }
    }

    SavedCameraRot = CameraRotation;
    SavedCameraLoc = CameraLocation;
    
    /*
    // Handle view target.  Done AFTER other code, so that SavedLoc/Rot are updated
    if(ViewTarget != None)
    {
        SetClientAlpha(1.0);
        ViewActor = ViewTarget;
        CameraLocation = ViewTarget.Location;
        CameraRotation = ViewTarget.Rotation + ShakeDelta; // Add in effect of earthquakes
        if(Pawn(ViewTarget) != None)
        {
            if((Level.NetMode == NM_StandAlone) && (ViewTarget.IsA('PlayerPawn')))
            {
                CameraRotation = Pawn(ViewTarget).ViewRotation;
            }

            CameraLocation.Z += Pawn(ViewTarget).EyeHeight;
        }
    }
    */

    ViewLocation = CameraLocation;

    LastTime = CurrentTime;

    // Replicate ViewPitch for spectator
    //ViewPitch = CameraRotation.Pitch;
}

defaultproperties
{
     CameraDist=180.000000
     CameraPitch=450.000000
     CameraHeight=35.000000
     CurrentDist=200.000000
     CameraAccel=7.000000
     CameraRotSpeed=(Pitch=20,Yaw=20,Roll=20)
}
