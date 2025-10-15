//==============================================================================
//	R_BotBehavior_Fight
//	Try to kill and try not to die
//==============================================================================
class R_BotBehavior_Fight extends R_BotBehavior;

// Attack directions, copied from R_BotPawnController
const AttackDir_Forward = 1;
const AttackDir_Backward = 2;
const AttackDir_Right = 3;
const AttackDir_Left = 4;
const AttackDir_Neutral = 5;

// Dodge directions, copied from R_BotPawnController
const DodgeDir_Forward = 1;
const DodgeDir_Backward = 2;
const DodgeDir_Right = 3;
const DodgeDir_Left = 4;

var private float AccumulatedTime;

var private Vector MovementDirection;

const BBKey_MoveDirection = 'MoveDirection';

function BuildBlackBoard(R_BlackBoard BB)
{
	BB.AddActor(BBKey_InventoryTarget);

	BB.AddFloat(BBKey_WantHealth);
	BB.AddFloat(BBKey_WantRunePower);
	BB.AddFloat(BBKey_WantStrength);

	BB.AddVector(BBKey_MoveDirection);
}

function BehaviorActivated()
{
	local R_Bot Bot;

	Bot = GetBot();
	if(Bot != None)
	{
		Bot.ClearPath();
	}
}

function BehaviorTick(float DeltaSeconds)
{
	local PlayerPawn PP;
	local R_BotPerception Perception;
	local R_BotPawnController Controller;
	local Actor TargetActor;
	local float EngagementScore;
	local Vector BorderAvoidanceInput;
	local Vector TowardTargetInput;
	local Vector MovementInput;
	local float TargetDistance;
	local float AttackRadius;

	Perception = GetBotPerception();
	Controller = GetBotPawnController();
	PP = GetPlayerPawn();
	if(Perception == None || Controller == None || PP == None)
	{
		return;
	}
	
	TargetActor = Perception.GetPerceivedActor();	// The bot's target
	EngagementScore = Perception.GetPerceivedActorEngagementScore();	// How strongly the bot wants to engage [0,1]
	
	// Figure out movement input
	MovementInput = Vect(0,0,0);

	// Always avoid borders
	BorderAvoidanceInput = Normal(Vect(1,1,0) * Perception.GetBorderAvoidanceDir());
	MovementInput += BorderAvoidanceInput;

	if(TargetActor != None)
	{	// If bot wants to engage target, calc movement towards
		// TODO: Need to update this to work with target avoidance as well, where engagement score would be < 0 if bot wants to avoid
		TowardTargetInput = Normal(Vect(1,1,0) * (TargetActor.Location - PP.Location));
		TowardTargetInput = Utilities.Static.LerpVector(Vect(0,0,0), TowardTargetInput, EngagementScore);
		MovementInput += TowardTargetInput;
	}

	Controller.AddMovementInput_WorldSpace(MovementInput);
	
	// Attack if within some striking range of target
	TargetDistance = VSize(TargetActor.Location - PP.Location);
	AttackRadius = 128.0;
	if(TargetDistance <= AttackRadius)
	{
		if(Controller.CanPerformAttack() && !Controller.HasPendingAttack())
		{
			if(FRand() > 0.75)
			{
				if(FRand() > 0.5)
				{
					Controller.Attack(AttackDir_Left);
				}
				else
				{
					Controller.Attack(AttackDir_Right);
				}
			}
			else
			{
				Controller.Attack(AttackDir_Forward, 2);
			}
		}
	}

	// Look directly at the target
	Controller.LookAt_WorldSpace(TargetActor.Location);
}