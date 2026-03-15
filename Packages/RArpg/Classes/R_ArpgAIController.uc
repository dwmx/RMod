//==============================================================================
//  R_ArpgAIController
//==============================================================================
class R_ArpgAIController extends R_ArpgObject;

var private Class<R_ArpgAITargetSelector> AITargetSelectorClass;
var private R_ArpgAITargetSelector AITargetSelector;

var private R_ArpgPawn ControlledPawn;
var private Actor Target;

var private Vector DesiredLocation;

var private float Accumulator;

function InitializeArpgObject()
{
    if(AITargetSelectorClass != None)
    {
        AITargetSelector = R_ArpgAITargetSelector(ArpgLib.Static.CreateArpgObject(AITargetSelectorClass, Self));
        AITargetSelector.SetAIController(Self);
    }
}

//------------------------------------------------------------------------------

function SetControlledPawn(R_ArpgPawn NewControlledPawn)
{
    ControlledPawn = NewControlledPawn;
    DesiredLocation = ControlledPawn.Location;
}

function R_ArpgPawn GetControlledPawn()
{
    return ControlledPawn;
}

function TickAI(float DeltaSeconds)
{
    local Actor NewTarget;

    AITargetSelector.TickAI(DeltaSeconds);
    NewTarget = AITargetSelector.GetTarget();
    Target = NewTarget;

    if(Target != None)
    {
        TickLookAtTarget(DeltaSeconds);

        if(IsInRangeOfTarget())
        {

        }
        else
        {
            MoveTowardTarget();
        }
    }
    else
    {
        MoveTowardDesiredLocation();
    }

    /*
	Accumulator += DeltaSeconds;
	if(Accumulator >= 4.0)
	{
		// Try to attack
		ControlledPawn.Input_Skill('Attack');
		Log("I try attack now");
		Accumulator = 0.0;
	}
        */
}

function TickLookAtTarget(float DeltaSeconds)
{
    local R_ArpgPawn LocalPawn;
    local Vector DeltaLocation;

    LocalPawn = GetControlledPawn();
    if(LocalPawn == None || Target == None)
    {
        return;
    }

    DeltaLocation = Target.Location - LocalPawn.Location;
    DeltaLocation = Normal(DeltaLocation * Vect(1,1,0));
    LocalPawn.SetDesiredLookDirection(DeltaLocation);
}

function MoveTowardDesiredLocation()
{
    local R_ArpgPawn LocalPawn;

    LocalPawn = GetControlledPawn();
    if(LocalPawn == None)
    {
        return;
    }

    LocalPawn.AddMovementInput(Normal(DesiredLocation - LocalPawn.Location) * Vect(1,1,0));
}

function MoveTowardTarget()
{
    local R_ArpgPawn LocalPawn;

    LocalPawn = GetControlledPawn();
    if(LocalPawn == None || Target == None)
    {
        return;
    }

    LocalPawn.AddMovementInput(Normal(Target.Location - LocalPawn.Location) * Vect(1,1,0));
}

function bool IsInRangeOfTarget()
{
    local R_ArpgPawn LocalPawn;
    local float Distance;

    LocalPawn = GetControlledPawn();
    if(LocalPawn == None || Target == None)
    {
        return false;
    }

    Distance = VSize(Target.Location - LocalPawn.Location);
    return Distance <= 64.0;
}

//------------------------------------------------------------------------------

defaultproperties
{
    AITargetSelectorClass=Class'RArpg.R_ArpgAITargetSelector'
}