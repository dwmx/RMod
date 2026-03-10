//==============================================================================
//  R_ArpgAIController
//==============================================================================
class R_ArpgAIController extends R_ArpgObject;

var private R_ArpgPawn ControlledPawn;
var private Actor Target;
var private float TargetTimeOut;
var private float MinimumTargetDistance;

var private Vector DesiredLocation;

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
    TickAITarget(DeltaSeconds);

    if(Target != None)
    {
        MoveTowardTarget();
    }
    else
    {
        MoveTowardDesiredLocation();
    }
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

    if(Target == None)
    {
        return;
    }

    LocalPawn = GetControlledPawn();
    if(LocalPawn == None)
    {
        return;
    }

    LocalPawn.AddMovementInput(Normal(Target.Location - LocalPawn.Location) * Vect(1,1,0));
}

//------------------------------------------------------------------------------

function TickAITarget(float DeltaSeconds)
{
    local R_ArpgPawn LocalPawn;
    local Actor NewTarget;
    local Vector DeltaLocation;

    if(Target == None)
    {
        NewTarget = SelectTarget();
        if(NewTarget != None)
        {
            Target = NewTarget;
            TargetTimeOut = 5.0;
        }
    }
    else
    {
        LocalPawn = GetControlledPawn();
        if(LocalPawn != None)
        {
            DeltaLocation = Target.Location - LocalPawn.Location;
            if(VSize(DeltaLocation) <= MinimumTargetDistance)
            {
                TargetTimeOut = 5.0;
            }
            else
            {
                TargetTimeOut -= DeltaSeconds;
                TargetTimeOut = FMax(0.0, TargetTimeOut);
                if(TargetTimeOut <= 0.0)
                {
                    Target = None;
                }
            }
        }
    }
}

function bool IsValidTarget(Actor A)
{
    if(R_ArpgPawn_Hero(A) != None)
    {
        return true;
    }
    return false;
}

function Actor SelectTarget()
{
    local R_ArpgPawn LocalPawn;
    local Pawn PawnIt;
    local Vector DeltaLocation;

    LocalPawn = GetControlledPawn();
    if(LocalPawn == None)
    {
        return None;
    }

    for(PawnIt = LocalPawn.Level.PawnList; PawnIt != None; PawnIt = PawnIt.NextPawn)
    {
        if(!IsValidTarget(PawnIt))
        {
            continue;
        }

        DeltaLocation = PawnIt.Location - LocalPawn.Location;
        if(VSize(DeltaLocation) <= MinimumTargetDistance)
        {
            return PawnIt;
        }
    }
}

defaultproperties
{
    MinimumTargetDistance=256.0
}