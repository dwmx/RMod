//==============================================================================
//  R_ArpgAITargetSelector
//  Manages all state for selecting targets for an AI controller
//  Owned by an called from an ArpgAIController
//==============================================================================
class R_ArpgAITargetSelector extends R_ArpgObject;

var private R_ArpgAIController AIController;
var private Actor Target;
var private float TargetSelectRadius;
var private float TargetTimeOutDuration;
var private float TargetTimeOutAccumulator;

//------------------------------------------------------------------------------

function InitializeArpgObject()
{
    Target = None;
    TargetTimeOutAccumulator = 0.0;
}

function SetAIController(R_ArpgAIController NewAIController)
{
    AIController = NewAIController;
}

function Actor GetTarget()
{
    return Target;
}

//------------------------------------------------------------------------------
// Helpers

function R_ArpgPawn GetControlledPawn()
{
    if(AIController != None)
    {
        return AIController.GetControlledPawn();
    }
    return None;
}

//------------------------------------------------------------------------------

function TickAI(float DeltaSeconds)
{
    local Actor SelectedTarget;

    // If there's an existing target, validate it
    if(Target != None)
    {
        if(!IsValidTarget(Target))
        {   // If target is no longer valid, release it immediately
            SetTarget(None);
        }
        else
        {
            if(IsTargetInRange(Target))
            {   // If target is in range, tick up the time out accumulator
                TargetTimeOutAccumulator += DeltaSeconds;
                TargetTimeOutAccumulator = FClamp(TargetTimeOutAccumulator, 0.0, TargetTimeOutDuration);
            }
            else
            {   // It target it out of range, tick down the accumulator
                TargetTimeOutAccumulator -= DeltaSeconds;
                TargetTimeOutAccumulator = FClamp(TargetTimeOutAccumulator, 0.0, TargetTimeOutDuration);
                if(TargetTimeOutAccumulator <= 0.0)
                {   // Target timed out, release it
                    SetTarget(None);
                }
            }
        }
    }

    // If no target, try to find one
    if(Target == None)
    {
        SelectedTarget = SelectBestTarget();
        if(SelectedTarget != None)
        {
            SetTarget(SelectedTarget);
        }
    }
}

function SetTarget(Actor NewTarget)
{
    if(Target == NewTarget)
    {
        return;
    }

    Target = NewTarget;
    if(Target != None)
    {
        TargetTimeOutAccumulator = TargetTimeOutDuration;
    }
    else
    {
        TargetTimeOutAccumulator = 0.0;
    }
}

function bool IsValidTarget(Actor TargetActor)
{
    local R_ArpgPawn ControlledPawn;
    local R_ArpgPawn TargetPawn;

    ControlledPawn = GetControlledPawn();
    if(ControlledPawn == None || ControlledPawn.IsDead())
    {
        return false;
    }

    TargetPawn = R_ArpgPawn(TargetActor);
    if(TargetPawn == None || TargetPawn.IsDead() || TargetPawn == ControlledPawn)
    {   // Only target ArpgPawns for now -- may change this later
        return false;
    }

    if(ControlledPawn.GetTeamIndex() == TargetPawn.GetTeamIndex())
    {   // Don't target teammates
        return false;
    }

    return true;
}

function bool IsTargetInRange(Actor TestTarget)
{
    local R_ArpgPawn ControlledPawn;
    local float TargetDistance;

    if(TestTarget == None)
    {
        return false;
    }

    ControlledPawn = GetControlledPawn();
    if(ControlledPawn == None)
    {
        return false;
    }

    TargetDistance = VSize(Vect(1,1,0) * (TestTarget.Location - ControlledPawn.Location));
    return TargetDistance <= TargetSelectRadius;
}

function Actor SelectBestTarget()
{
    local R_ArpgPawn ControlledPawn;
    local R_ArpgPawn TargetPawn;
    local Vector SphereOrigin;
    local float SphereRadius;
    local Vector DeltaLocation;
    local float BestScore, CurrScore;
    local Actor BestTarget;

    ControlledPawn = GetControlledPawn();
    if(ControlledPawn == None)
    {
        return None;
    }

    BestScore = 0.0;
    BestTarget = None;

    SphereOrigin = ControlledPawn.Location;
    SphereRadius = TargetSelectRadius;
    foreach ControlledPawn.RadiusActors(Class'RArpg.R_ArpgPawn', TargetPawn, SphereRadius, SphereOrigin)
    {
        if(!IsValidTarget(TargetPawn))
        {
            continue;
        }

        CurrScore = ScoreTarget(TargetPawn);
        if(CurrScore >= BestScore)
        {
            BestScore = CurrScore;
            BestTarget = TargetPawn;
        }
    }

    return BestTarget;
}

function float ScoreTarget(Actor TargetActor)
{
    return 1.0;
}

defaultproperties
{
    TargetSelectRadius=256.0
    TargetTimeOutDuration=3.0
}