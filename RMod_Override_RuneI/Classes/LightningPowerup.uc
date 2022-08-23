//=============================================================================
// LightningPowerup.
//=============================================================================
class LightningPowerup expands Electricity;

var() int DamagePerSecond;
var float TimeElapsed;
var Effects Flash;


function Tick(float DeltaTime)
{
	TimeElapsed += DeltaTime;

	if (TimeElapsed > 1)
	{
		if (Base != None)
		{
			if (Pawn(Base)!=None && Pawn(Base).Health > 0)
			{
				Base.JointDamaged(DamagePerSecond, Instigator, Base.Location, vect(0,0,0), 'fire', 0);
				if (Pawn(Base).Health <= 0)
				{
					if (Flash != None)
						Flash.Destroy();
					Destroy();
				}
			}

			// Create flash if it doesn't exist yet
			if (Flash == None)
			{
				Flash = Spawn(class'FlashCycle', Owner,, Base.Location);
				Flash.SetBase(Base);
			}
		}
		
		TimeElapsed = 0;
	}
}

defaultproperties
{
     DamagePerSecond=10
}
