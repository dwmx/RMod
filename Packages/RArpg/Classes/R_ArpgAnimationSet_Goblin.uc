//==============================================================================
//	R_ArpgAnimationSet_Goblin
//	Base class for Goblin animations
//==============================================================================
class R_ArpgAnimationSet_Goblin extends R_ArpgAnimationSet;

// Locomotion animations
const A_dodgeback			= 'dodgeback';			// Backward dodge
const A_w_gallopB 			= 'w_gallopB'; 			// Loop fast hop forward
const A_w_gallopB_torch		= 'w_gallopB_torch';	// Loop fast hop forward holding item high
const A_w_gallopB_weapon	= 'w_gallopB_weapon';	// Loop fast hop forward holding item low
const A_walkB 				= 'walkB'; 				// Loop walk forward
const A_hopA				= 'hopA';				// Loop idle hop
const A_idleA				= 'idleA';				// Loop idle
const A_w_idleA				= 'w_idleA';			// Loop idle

// Death animations
const A_Death				= 'Death';				// Death animation with significant root motion
const A_DeathB				= 'DeathB';				// Death in place animation
const A_Deaths				= 'Deaths';				// Death, fall backwards
const A_DeathR				= 'DeathR';				// Death, fall to his left
const A_DeathF				= 'DeathF';				// Death, fall forwards

// Attack animations
const A_attackB				= 'attackB';			// Basic forward attack with weapon
const A_swipe				= 'swipe';				// Basic forward attack bare hand
const A_ThrowA				= 'ThrowA';				// Forward throw

// Defend animations
const A_blockhigh			= 'blockhigh';			// Loop idle block high
const A_blocklow			= 'blocklow';			// Loop idle block low

// Pain animations
const A_Pain				= 'Pain';				// Pain react right

//------------------------------------------------------------------------------

static function Name GetStaticAnimationForMovementDirection(int MovementDirection)
{
	switch(MovementDirection)
	{
	case MOVEDIR_FORWARD:	return A_walkB;
	}
	return 'hopA';
}

static function Name GetStaticAttackAnimation(optional int Parameters)
{}

static function Name GetStaticDeathAnimation(optional int Parameters)
{
	local Name Options[4];
	Options[0] = A_DeathB;
	Options[1] = A_Deaths;
	Options[2] = A_DeathR;
	Options[3] = A_DeathF;
	return Options[Rand(ArrayCount(Options))];
}