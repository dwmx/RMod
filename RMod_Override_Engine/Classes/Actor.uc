//=============================================================================
// Actor: The base class of all actors.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Actor extends Object
	abstract
	native;
//	nativereplication;

// Imported data (during full rebuild).
#exec Texture Import File=Textures\S_Actor.pcx Name=S_Actor Mips=Off Flags=2

const bDebug			=	1;	// Debug Mode (Debug HUD available)

// These for the debugHUD
const DEBUG_NONE		=	0;	// No Debugging
const DEBUG_TARGET		=	1;	// Debug the target actor
const DEBUG_CONSTANT	=	2;	// Debug an actor and don't change
const DEBUG_AI			=	3;	// Debug AI (navpoints,constantTarget,POV)
const DEBUG_PLAYER		=	4;	// Debug the player
const DEBUG_LEVEL		=	5;	// Debug the level info actor
const DEBUG_ZONE		=	6;	// Debug current Zoneinfo
const DEBUG_MULTIPLE	=	7;	// ** this is the lowest multiple selection mode
const DEBUG_VISIBLE		=	7;	// Debug all visible actors
const DEBUG_LIGHTS		=	8;	// Debug lights
const DEBUG_NAVPOINTS	=	9;	// Debug all navigation points
const DEBUG_TRIGGERS	=	10;
const DEBUG_MAX			=	10;

const HUD_ACTOR			=	0;	// Call the actors debug function
const HUD_SKELETON		=	1;	// Draw skeleton
const HUD_SKELNAMES		=	2;	// Draw skeleton with joint names
const HUD_SKELJOINTS	=	3;	// Draw skeleton with collision joints
const HUD_SKELAXES		=	4;	// Draw skeleton with rotation axes
const HUD_LOD			=	5;	// Draw LOD
const HUD_POV			=	6;	// Draw POV of actor
const HUD_SCRIPT		=	7;	// Draw scripting info (triggers, events, etc.)
const HUD_NETWORK		=	8;	// Draw network info
const HUD_MAX			=   8;
const HUD_NONE			=   9;

const ANGLE_1	= 182;
const ANGLE_45	= 8192;
const ANGLE_90	= 16384;
const ANGLE_180	= 32768;
const ANGLE_360 = 65535;

// Body parts used for localized damage (update array in Pawn)
const BODYPART_BODY		=	0;	// Body represents the creature health (damaged by falling/drowning/etc.)
const BODYPART_LARM1	=	1;
const BODYPART_LARM2	=	2;
const BODYPART_RARM1	=	3;
const BODYPART_RARM2	=	4;
const BODYPART_HEAD		=	5;
const BODYPART_LLEG1	=	6;
const BODYPART_LLEG2	=	7;
const BODYPART_RLEG1	=	8;
const BODYPART_RLEG2	=	9;
const BODYPART_TORSO	=	10;
const BODYPART_MISC1	=	11;
const BODYPART_MISC2	=	12;
const BODYPART_MISC3	=	13;
const BODYPART_MISC4	=	14;
const NUM_BODYPARTS      =  15;

// Flags.
var(Advanced) const bool  bStatic;       // Does not move or change over time.
var(Advanced) bool        bHidden;       // Is hidden during gameplay.
var(Advanced) const bool  bNoDelete;     // Cannot be deleted during play.
var(Advanced) bool        bReleaseLock;  // Won't execute script code until released
var bool				  bAnimFinished; // Unlooped animation sequence has finished.
var bool				  bAnimLoop;     // Whether animation is looping.
var bool				  bAnimNotify;   // Whether a notify is applied to the current sequence.
var bool				  bAnimByOwner;	 // Animation dictated by owner.
var const bool            bDeleteMe;     // About to be deleted.
var transient const bool  bAssimilated;  // Actor dynamics are assimilated in world geometry.
var transient const bool  bTicked;       // Actor has been updated.
var transient bool        bLightChanged; // Recalculate this light's lighting now.
var bool                  bDynamicLight; // Temporarily treat this as a dynamic light.
var bool                  bTimerLoop;    // Timer loops (else is one-shot).
var bool				  bRenderedLastFrame; // RUNE:  True if the object was rendered the last frame
var(Advanced) bool		  bSpecialRender; // RUNE:  Special rendered... not actually drawn, but is still filtered
										  // used by the TT_See triggers for sight determination

// Other flags.
var(Advanced) bool        bCanTeleport;  // This actor can be teleported.
var(Advanced) bool		bOwnerNoSee;	 // Everything but the owner can see this actor.
var(Advanced) bool      bOnlyOwnerSee;   // Only owner can see this actor.
var Const     bool		bIsMover;		 // Is a mover.
var(Advanced) bool		bAlwaysRelevant; // Always relevant for network.
var Const	  bool		bAlwaysTick;     // Update even when players-only.
var(Advanced) bool        bHighDetail;	 // Only show up on high-detail.
var(Advanced) bool		  bStasis;		 // In StandAlone games, turn off if not in a recently rendered zone turned off if  bCanStasis  and physics = PHYS_None or PHYS_Rotating.
var(Advanced) bool		  bForceStasis;	 // Force stasis when not recently rendered, even if physics not none or rotating.
var const	  bool		  bIsPawn;		 // True only for pawns.
var(Advanced) const bool  bNetTemporary; // Tear-off simulation in network play.
var(Advanced) const bool  bNetOptional;  // Actor should only be replicated if bandwidth available.
var			  bool		  bReplicateInstigator;	// Replicate instigator to client (used by bNetTemporary projectiles).
var			  bool		  bTrailerSameRotation;	// If PHYS_Trailer and true, have same rotation as owner.
var			  bool		  bTrailerPrePivot;	// If PHYS_Trailer and true, offset from owner by PrePivot.
var			  bool		  bClientAnim;
var			  bool		  bSimFall;			// dumb proxy should simulate fall
var(Advanced) bool		  bFrameNotifies;	// RUNE: receive a FrameNotify() event each frame

var(Advanced) bool		  bLookFocusPlayer;		// RUNE:  Look focus for the Player
var(Advanced) bool		  bLookFocusCreature;	// RUNE:  Look focus for Non-Player Pawns
var(Advanced) bool		  bForceRender;			// RUNE:  Force rendering of this actor if the zone it's in is visible


// Priority Parameters
// Actor's current physics mode.
var(Movement) const enum EPhysics
{
	PHYS_None,
	PHYS_Walking,
	PHYS_Falling,
	PHYS_Swimming,
	PHYS_Flying,
	PHYS_Rotating,
	PHYS_Projectile,
	PHYS_Rolling,
	PHYS_Interpolating,
	PHYS_MovingBrush,
	PHYS_Spider,
	PHYS_Trailer,
	PHYS_Sliding
} Physics;

// Net variables.
enum ENetRole
{
	ROLE_None,              // No role at all.
	ROLE_DumbProxy,			// Dumb proxy of this actor.
	ROLE_SimulatedProxy,	// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,	// Locally autonomous proxy of this actor.
	ROLE_Authority,			// Authoritative control over the actor.
};
var ENetRole Role;
var(Networking) ENetRole RemoteRole;
var const transient int NetTag;

// Owner.
var         const Actor   Owner;         // Owner actor.
var(Object) name InitialState;
var(Object) name Group;

// Execution and timer variables.
var float                 TimerRate;     // Timer event, 0=no timer.
var const float           TimerCounter;	 // Counts up until it reaches TimerRate.
var(Advanced) float		  LifeSpan;      // How old the object lives before dying, 0=forever.

// Animation variables.
var(Display) name         AnimSequence;  // Animation sequence we're playing.
var(Display) float        AnimFrame;     // Current animation frame, 0.0 to 1.0.
var(Display) float        AnimRate;      // Animation rate in frames per second, 0=none, negative=velocity scaled.
var          float        TweenRate;     // Tween-into rate.

var(Display) float		  LODBias;

//-----------------------------------------------------------------------------
// Structures.

// Identifies a unique convex volume in the world.
struct PointRegion
{
	var zoneinfo Zone;       // Zone.
	var int      iLeaf;      // Bsp leaf.
	var byte     ZoneNumber; // Zone number.
};

enum E_RMAlign
{
	RMALIGN_Left,
	RMALIGN_Right,
	RMALIGN_Center,
	RMALIGN_None
};

//-----------------------------------------------------------------------------
// Major actor properties.

// Scriptable.
var       const LevelInfo Level;         // Level this actor is on.
var transient const Level XLevel;        // Level object.
var(Events) name		  Tag;			 // Actor's tag name.
var(Events) name          Event;         // The event this actor causes.
var Actor                 Target;        // Actor we're aiming at (other uses as well).
var Pawn                  Instigator;    // Pawn responsible for damage.
var Inventory             Inventory;     // Inventory chain.
var const Actor           Base;          // Moving brush actor we're standing on.
var byte				  BaseJoint;	 // RUNE:  If the Base has bJointsBlock, this contains the joint index
var EMatterType			  BaseMatterType; // RUNE:  The matter associated with the base
var Vector				  BaseScrollDir; // RUNE:  Scroll direction associated with the base

var const PointRegion     Region;        // Region this actor is in.
var(Movement)	name	  AttachTag;

// Internal.
var const byte            StandingCount; // Count of actors standing on this actor.
var const byte            MiscNumber;    // Internal use.
var const byte            LatentByte;    // Internal latent function use.
var const int             LatentInt;     // Internal latent function use.
var const float           LatentFloat;   // Internal latent function use.
var const actor           LatentActor;   // Internal latent function use.
var const actor           Touching[4];   // List of touching actors.
var const actor           Deleted;       // Next actor in just-deleted chain.

// Internal tags.
var const transient int CollisionTag, LightingTag, OtherTag, ExtraTag, SpecialTag;

// The actor's position and rotation.
var(Movement) const vector Location;     // Actor's location; use Move to set.
var(Movement) const rotator Rotation;    // Rotation.
var       const vector    OldLocation;   // Actor's old location one tick ago.
var       const vector    ColLocation;   // Actor's old location one move ago.
var(Movement) vector      Velocity;      // Velocity.
var       vector          Acceleration;  // Acceleration.
var(Filter) float		  OddsOfAppearing; // 0-1 - chance actor will appear in relevant game modes.

//Editing flags
var(Advanced) bool        bHiddenEd;     // Is hidden during editing.
var(Advanced) bool        bDirectional;  // Actor shows direction arrow during editing.
var const bool            bSelected;     // Selected in UnrealEd.
var const bool            bMemorized;    // Remembered in UnrealEd.
var const bool            bHighlighted;  // Highlighted in UnrealEd.
var bool                  bEdLocked;     // Locked in editor (no movement or rotation).
var(Advanced) bool        bEdShouldSnap; // Snap to grid in editor.
var transient bool        bEdSnap;       // Should snap to grid in UnrealEd.
var transient const bool  bTempEditor;   // Internal UnrealEd.

// What kind of gameplay scenarios to appear in.
var(Filter) bool          bDifficulty0;  // Appear in difficulty 0.
var(Filter) bool          bDifficulty1;  // Appear in difficulty 1.
var(Filter) bool          bDifficulty2;  // Appear in difficulty 2.
var(Filter) bool          bDifficulty3;  // Appear in difficulty 3.
var(Filter) bool          bSinglePlayer; // Appear in single player.
var(Filter) bool          bNet;          // Appear in regular network play.
var(Filter) bool          bNetSpecial;   // Appear in special network play mode.

//-----------------------------------------------------------------------------
// Display properties.

// Drawing effect.
var(Display) enum EDrawType
{
	DT_None,
	DT_Sprite,
	DT_Mesh,
	DT_Brush,
	DT_RopeSprite,
	DT_VerticalSprite,
	DT_SkeletalMesh,
	DT_SpriteAnimOnce,
	DT_ParticleSystem,
} DrawType;

// Style for rendering sprites, meshes.
var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_AlphaBlend,
} Style;

// Other display properties.
var(Display) texture		Sprite;			 // Sprite texture if DrawType=DT_Sprite.
var(Display) texture		Texture;		 // Misc texture.
var(Display) texture		Skin;            // Special skin or enviro map texture.
var(Display) mesh			Mesh;            // Mesh if DrawType=DT_Mesh.

// RUNE:  Actor shadow variables
var(Display) bool			bHasShadow;		 // RUNE:  Actor casts a dynamic shadow
var	transient shadowtexture	ShadowTexture;	 // RUNE:  Texture that contains the info for the actor shadow
var			 vector			ShadowVector;	 // RUNE:  Shadow Direction (pointed towards actor)

var const export model		Brush;           // Brush if DrawType=DT_Brush.
var(Display) float			DrawScale;		 // Scaling factor, 1.0=normal size.
var			 vector			PrePivot;		 // Offset from box center for drawing.
var(Display) float			ScaleGlow;		 // Multiplies lighting.
var(Display) float			VisibilityRadius;// Actor is drawn if viewer is within its visibility
var(Display) float			VisibilityHeight;// cylinder.  Zero=infinite visibility.
var(Display) byte			AmbientGlow;     // Ambient brightness, or 255=pulsing.
var(Display) byte			Fatness;         // Fatness (mesh distortion).
var(Display) float			SpriteProjForward;// Distance forward to draw sprite from actual location.
var(Display) vector			ColorAdjust;		// RUNE:  Color adjustment applied to the actor
var(Display) vector			DesiredColorAdjust;	// RUNE:  Smoothly applies the Color adjustment
var(Display) byte			DesiredFatness;		// RUNE:  Desired Fatness to interpolate to
var(Display) float			AlphaScale;		 // RUNE:  Alpha value used in STY_AlphaBlend

// RUNE LOD variables
var			 int			LODPolyCount;	 // RUNE:  LOD last rendered polycount
var(Display) float			LODDistMax;	     // RUNE:  LOD max distance
var(Display) float			LODDistMin;	     // RUNE:  LOD min distance
var(Display) float			LODPercentMin;	 // RUNE:  LOD min percentage cap
var(Display) float			LODPercentMax;	 // RUNE:  LOD max percentage cap
var(Display) enum			ELODCurve		 // RUNE:  LOD Curve types
{
	LOD_CURVE_NONE,
	LOD_CURVE_ULTRA_CONSERVATIVE,
	LOD_CURVE_CONSERVATIVE,
	LOD_CURVE_NORMAL,
	LOD_CURVE_AGGRESSIVE,
	LOD_CURVE_ULTRA_AGGRESSIVE,
	LOD_CURVE_TEST,
} LODCurve;

// Display.
var(Display)  bool      bUnlit;          // Lights don't affect actor.
var(Display)  bool		bPointLight;	 // RUNE:  Actor is point lit at its centerpoint, rather than directionally lit
var(Display)  bool		bMirrored;       // RUNE:  Actor is mirrored (left-handed)
var(Display)  bool      bNoSmooth;       // Don't smooth actor's texture.
var(Display)  bool      bParticles;      // Mesh is a particle system.
var(Display)  bool      bRandomFrame;    // Particles use a random texture from among the default texture and the multiskins textures
var(Display)  bool      bMeshEnviroMap;  // Environment-map the mesh.
var(Display)  bool      bMeshCurvy;      // Curvy mesh.
var(Display)  bool		bFilterByVolume; // Filter this sprite by its Visibility volume.
var(Display)  bool		bPreLight;		 // RUNE:  This actor has static prelighting computed in the editor

var(Display)  bool		bComplexOcclusion; // RUNE:  Uses a more complex occlusion method (useful for larger objects)

// Not yet implemented.
var(Display) bool       bShadowCast;     // Casts shadows.

// Advanced.
var(Advanced) bool		bGameRelevant;	 // Always relevant for game
var			  bool		bCarriedItem;	 // being carried, and not responsible for displaying self, so don't replicated location and rotation
var			  bool		bForcePhysicsUpdate; // force a physics update for simulated pawns
var(Advanced) bool        bIsSecretGoal; // This actor counts in the "secret" total.
var(Advanced) bool        bIsKillGoal;   // This actor counts in the "death" toll.
var(Advanced) bool        bIsItemGoal;   // This actor counts in the "item" count.
var(Advanced) bool		  bCollideWhenPlacing; // This actor collides with the world when placing.
var(Advanced) bool		  bTravel;       // Actor is capable of travelling among servers.
var(Advanced) bool		  bMovable;      // Actor is capable of travelling among servers.

var           actor		AttachParent;    // RUNE: Parent actor if bCarriedItem
var           byte      AttachParentJoint;// RUNE: Parent joint index I am attached to

// Multiple skin support.
var(Display) texture MultiSkins[8];

//-----------------------------------------------------------------------------
// Sound.

// Ambient sound.
var(Sound) byte         SoundRadius;	 // Radius of ambient sound.
var(Sound) byte         SoundVolume;	 // Volume of amient sound.
var(Sound) byte         SoundPitch;	     // Sound pitch shift, 64.0=none.
var(Sound) sound        AmbientSound;    // Ambient sound effect.

// Regular sounds.
var(Sound) float TransientSoundVolume;
var(Sound) float TransientSoundRadius;

// Sound slots for actors.
enum ESoundSlot
{
	SLOT_None,
	SLOT_Misc,
	SLOT_Pain,
	SLOT_Interact,
	SLOT_Ambient,
	SLOT_Talk,
	SLOT_Interface,
};

// Music transitions.
enum EMusicTransition
{
	MTRAN_None,
	MTRAN_Instant,
	MTRAN_Segue,
	MTRAN_Fade,
	MTRAN_FastFade,
	MTRAN_SlowFade,
};

//-----------------------------------------------------------------------------
// Collision.

// Collision size.
var(Collision) const float CollisionRadius; // Radius of collision cyllinder.
var(Collision) const float CollisionHeight; // Half-height cyllinder.

// Collision flags.
var(Collision) const bool bCollideActors;   // Collides with other actors.
var(Collision) bool       bCollideWorld;    // Collides with the world.
var(Collision) bool       bBlockActors;	    // Blocks other nonplayer actors.
var(Collision) bool       bBlockPlayers;    // Blocks other player actors.
var(Collision) bool       bProjTarget;      // Projectiles should potentially target this actor.
var(Collision) bool       bJointsBlock;		// RUNE:  Collision joints block actors
var(Collision) bool		  bJointsTouch;		// RUNE:  This actor accepts joint touch messages
var(Collision) bool       bSweepable;		// RUNE:  This actor can be hit by weapons

//-----------------------------------------------------------------------------
// Lighting.

// Light modulation.
var(Lighting) enum ELightType
{
	LT_None,
	LT_Steady,
	LT_Pulse,
	LT_Blink,
	LT_Flicker,
	LT_Strobe,
	LT_BackdropLight,
	LT_SubtlePulse,
	LT_TexturePaletteOnce,
	LT_TexturePaletteLoop
} LightType;

// Spatial light effect to use.
var(Lighting) enum ELightEffect
{
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
	LE_Unused
} LightEffect;

// Lighting info.
var(LightColor) byte
	LightBrightness,
	LightHue,
	LightSaturation;

// Light properties.
var(Lighting) byte
	LightRadius,
	LightPeriod,
	LightPhase,
	LightCone,
	VolumeBrightness,
	VolumeRadius,
	VolumeFog;

// Lighting.
var(Lighting) bool	     bSpecialLit;	 // Only affects special-lit surfaces.
var(Lighting) bool	     bSpecialLit2;	 // Only affects special-lit2 surfaces.
var(Lighting) bool	     bSpecialLit3;	 // Only affects special-lit3 surfaces.
var(Lighting) bool	     bActorShadows;  // Light casts actor shadows.
var(Lighting) bool	     bCorona;        // Light uses Skin as a corona.
var(Lighting) bool	     bLensFlare;     // Whether to use zone lens flare.
var(Lighting) bool		 bNegativeLight; // RUNE:  This light is merged negatively (darklight)
var(Lighting) bool		 bAffectWorld;	 // RUNE:  This light affects the world
var(Lighting) bool	     bAffectActors;  // RUNE:  This light affects actors

//-----------------------------------------------------------------------------
// Physics.

// Options.
var(Movement) bool        bBounce;           // Bounces when hits ground fast.
var(Movement) bool		  bFixedRotationDir; // Fixed direction of rotation.
var(Movement) bool		  bRotateToDesired;  // Rotate to DesiredRotation.
var           bool        bInterpolating;    // Performing interpolating.
var			  const bool  bJustTeleported;   // Used by engine physics - not valid for scripts.

// Dodge move direction.
var enum EDodgeDir
{
	DODGE_None,
	DODGE_Left,
	DODGE_Right,
	DODGE_Forward,
	DODGE_Back,
	DODGE_Active,
	DODGE_Done
} DodgeDir;

// Physics properties.
var(Movement) float       Mass;            // Mass of this actor.
var(Movement) float       Buoyancy;        // Water buoyancy.
var(Movement) rotator	  RotationRate;    // Change in rotation per second.
var(Movement) rotator     DesiredRotation; // Physics will rotate pawn to this if bRotateToDesired.
var           float       PhysAlpha;       // Interpolating position, 0.0-1.0.
var           float       PhysRate;        // Interpolation rate per second.
var			  Actor		  PendingTouch;		// Actor touched during move which wants to add an effect after the movement completes 

//-----------------------------------------------------------------------------
// Animation.

// Animation control.
var          float        AnimLast;        // Last frame.
var          float        AnimMinRate;     // Minimum rate for velocity-scaled animation.
var			 float		  OldAnimRate;	   // Animation rate of previous animation (= AnimRate until animation completes).
var			 plane		  SimAnim;		   // replicated to simulated proxies.

//-----------------------------------------------------------------------------
// Networking.

// Network control.
var(Networking) float NetPriority; // Higher priorities means update it more frequently.
var(Networking) float NetUpdateFrequency; // How many seconds between net updates.

// Symmetric network flags, valid during replication only.
var const bool bNetInitial;       // Initial network update.
var const bool bNetOwner;         // Player owns this actor.
var const bool bNetRelevant;      // Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool bNetSee;           // Player sees it in network play.
var const bool bNetHear;          // Player hears it in network play.
var const bool bNetFeel;          // Player collides with/feels it in network play.
var const bool bSimulatedPawn;	  // True if Pawn and simulated proxy.
var const bool bDemoRecording;	  // True we are currently demo recording
var const bool bClientDemoRecording;// True we are currently recording a client-side demo
var const bool bClientDemoNetFunc;// True if we're client-side demo recording and this call originated from the remote.

//-----------------------------------------------------------------------------
// Skeletal Support Variables
//-----------------------------------------------------------------------------

// joint flags
const JOINT_FLAG_BLENDJOINT		= 0x01;
const JOINT_FLAG_ACCELERATIVE	= 0x02;
const JOINT_FLAG_SPRINGPOINT	= 0x04;
const JOINT_FLAG_IKCHAIN		= 0x08;
const JOINT_FLAG_COLLISION		= 0x10;
const JOINT_FLAG_ABSPOSITION	= 0x20;
const JOINT_FLAG_ABSROTATION	= 0x40;
const JOINT_FLAG_GRAVJOINT		= 0x80;
const NUM_JOINT_FLAGS			= 8;

const POLYFLAG_INVISIBLE	= 0x01;
const POLYFLAG_MASKED		= 0x02;
const POLYFLAG_TRANSLUCENT	= 0x04;
const POLYFLAG_ENVIRONMENT	= 0x10;
const POLYFLAG_MODULATED	= 0x40;

var(Movement) bool           bNoSurfaceBob;     // Don't bob on water surface (can't jump out of water either)
var(Skeleton) bool           bDrawSkel;         // Draw the skeleton
var(Skeleton) bool           bDrawJoints;       // Draw collision joints
var(Skeleton) bool           bDrawAxes;         // Draw rotational axes
var(Skeleton) bool           bApplyLagToAccelerators;	// Apply -Velocity to accelerators
var(Skeleton) byte           SkelMesh;	        // index of skeletal mesh
var(Skeleton) SkelModel      Skeletal;          // Skeletal Mesh if DrawType = DT_SkeletalMesh
var(Skeleton) SkelModel		 SubstituteMesh;	// RUNE:  Use this mesh/texture, but use the anims from Skeletal
var(Skeleton) float          BlendAnimAlpha;    // Alpha value for blending animation with BlendAnimFrame
var(Skeleton) float          BlendAnimFrame;    // Frame to blend with current animation
var(Skeleton) name           BlendAnimSequence; // Sequence to blend with current animation
var           AnimationProxy AnimProxy;			// Animation group controller actor (spawned in SpawnAnimationProxyX())
var(Skeleton) Texture        SkelGroupSkins[16];// Poly group skins
var(Skeleton) int            SkelGroupFlags[16];// Poly group properties
var           byte           JointFlags[50];    // Joint properties
var           actor		     JointChild[50];    // Children of joints

//-----------------------------------------------------------------------------
// Enums.

// Travelling from server to server.
enum ETravelType
{
	TRAVEL_Absolute,	// Absolute URL.
	TRAVEL_Partial,		// Partial (carry name, reset server).
	TRAVEL_Relative,	// Relative URL.
};

// Input system states.
enum EInputAction
{
	IST_None,    // Not performing special input processing.
	IST_Press,   // Handling a keypress or button press.
	IST_Hold,    // Handling holding a key or button.
	IST_Release, // Handling a key or button release.
	IST_Axis,    // Handling analog axis movement.
};

// Input keys.
enum EInputKey
{
/*00*/	IK_None			,IK_LeftMouse	,IK_RightMouse	,IK_Cancel		,
/*04*/	IK_MiddleMouse	,IK_Unknown05	,IK_Unknown06	,IK_Unknown07	,
/*08*/	IK_Backspace	,IK_Tab         ,IK_Unknown0A	,IK_Unknown0B	,
/*0C*/	IK_Unknown0C	,IK_Enter	    ,IK_Unknown0E	,IK_Unknown0F	,
/*10*/	IK_Shift		,IK_Ctrl	    ,IK_Alt			,IK_Pause       ,
/*14*/	IK_CapsLock		,IK_Unknown15	,IK_Unknown16	,IK_Unknown17	,
/*18*/	IK_Unknown18	,IK_Unknown19	,IK_Unknown1A	,IK_Escape		,
/*1C*/	IK_Unknown1C	,IK_Unknown1D	,IK_Unknown1E	,IK_Unknown1F	,
/*20*/	IK_Space		,IK_PageUp      ,IK_PageDown    ,IK_End         ,
/*24*/	IK_Home			,IK_Left        ,IK_Up          ,IK_Right       ,
/*28*/	IK_Down			,IK_Select      ,IK_Print       ,IK_Execute     ,
/*2C*/	IK_PrintScrn	,IK_Insert      ,IK_Delete      ,IK_Help		,
/*30*/	IK_0			,IK_1			,IK_2			,IK_3			,
/*34*/	IK_4			,IK_5			,IK_6			,IK_7			,
/*38*/	IK_8			,IK_9			,IK_Unknown3A	,IK_Unknown3B	,
/*3C*/	IK_Unknown3C	,IK_Unknown3D	,IK_Unknown3E	,IK_Unknown3F	,
/*40*/	IK_Unknown40	,IK_A			,IK_B			,IK_C			,
/*44*/	IK_D			,IK_E			,IK_F			,IK_G			,
/*48*/	IK_H			,IK_I			,IK_J			,IK_K			,
/*4C*/	IK_L			,IK_M			,IK_N			,IK_O			,
/*50*/	IK_P			,IK_Q			,IK_R			,IK_S			,
/*54*/	IK_T			,IK_U			,IK_V			,IK_W			,
/*58*/	IK_X			,IK_Y			,IK_Z			,IK_Unknown5B	,
/*5C*/	IK_Unknown5C	,IK_Unknown5D	,IK_Unknown5E	,IK_Unknown5F	,
/*60*/	IK_NumPad0		,IK_NumPad1     ,IK_NumPad2     ,IK_NumPad3     ,
/*64*/	IK_NumPad4		,IK_NumPad5     ,IK_NumPad6     ,IK_NumPad7     ,
/*68*/	IK_NumPad8		,IK_NumPad9     ,IK_GreyStar    ,IK_GreyPlus    ,
/*6C*/	IK_Separator	,IK_GreyMinus	,IK_NumPadPeriod,IK_GreySlash   ,
/*70*/	IK_F1			,IK_F2          ,IK_F3          ,IK_F4          ,
/*74*/	IK_F5			,IK_F6          ,IK_F7          ,IK_F8          ,
/*78*/	IK_F9           ,IK_F10         ,IK_F11         ,IK_F12         ,
/*7C*/	IK_F13			,IK_F14         ,IK_F15         ,IK_F16         ,
/*80*/	IK_F17			,IK_F18         ,IK_F19         ,IK_F20         ,
/*84*/	IK_F21			,IK_F22         ,IK_F23         ,IK_F24         ,
/*88*/	IK_Unknown88	,IK_Unknown89	,IK_Unknown8A	,IK_Unknown8B	,
/*8C*/	IK_Unknown8C	,IK_Unknown8D	,IK_Unknown8E	,IK_Unknown8F	,
/*90*/	IK_NumLock		,IK_ScrollLock  ,IK_Unknown92	,IK_Unknown93	,
/*94*/	IK_Unknown94	,IK_Unknown95	,IK_Unknown96	,IK_Unknown97	,
/*98*/	IK_Unknown98	,IK_Unknown99	,IK_Unknown9A	,IK_Unknown9B	,
/*9C*/	IK_Unknown9C	,IK_Unknown9D	,IK_Unknown9E	,IK_Unknown9F	,
/*A0*/	IK_LShift		,IK_RShift      ,IK_LControl    ,IK_RControl    ,
/*A4*/	IK_UnknownA4	,IK_UnknownA5	,IK_UnknownA6	,IK_UnknownA7	,
/*A8*/	IK_UnknownA8	,IK_UnknownA9	,IK_UnknownAA	,IK_UnknownAB	,
/*AC*/	IK_UnknownAC	,IK_UnknownAD	,IK_UnknownAE	,IK_UnknownAF	,
/*B0*/	IK_UnknownB0	,IK_UnknownB1	,IK_UnknownB2	,IK_UnknownB3	,
/*B4*/	IK_UnknownB4	,IK_UnknownB5	,IK_UnknownB6	,IK_UnknownB7	,
/*B8*/	IK_UnknownB8	,IK_UnknownB9	,IK_Semicolon	,IK_Equals		,
/*BC*/	IK_Comma		,IK_Minus		,IK_Period		,IK_Slash		,
/*C0*/	IK_Tilde		,IK_UnknownC1	,IK_UnknownC2	,IK_UnknownC3	,
/*C4*/	IK_UnknownC4	,IK_UnknownC5	,IK_UnknownC6	,IK_UnknownC7	,
/*C8*/	IK_Joy1	        ,IK_Joy2	    ,IK_Joy3	    ,IK_Joy4	    ,
/*CC*/	IK_Joy5	        ,IK_Joy6	    ,IK_Joy7	    ,IK_Joy8	    ,
/*D0*/	IK_Joy9	        ,IK_Joy10	    ,IK_Joy11	    ,IK_Joy12		,
/*D4*/	IK_Joy13		,IK_Joy14	    ,IK_Joy15	    ,IK_Joy16	    ,
/*D8*/	IK_UnknownD8	,IK_UnknownD9	,IK_UnknownDA	,IK_LeftBracket	,
/*DC*/	IK_Backslash	,IK_RightBracket,IK_SingleQuote	,IK_UnknownDF	,
/*E0*/  IK_JoyX			,IK_JoyY		,IK_JoyZ		,IK_JoyR		,
/*E4*/	IK_MouseX		,IK_MouseY		,IK_MouseZ		,IK_MouseW		,
/*E8*/	IK_JoyU			,IK_JoyV		,IK_UnknownEA	,IK_UnknownEB	,
/*EC*/	IK_MouseWheelUp ,IK_MouseWheelDown,IK_Unknown10E,UK_Unknown10F  ,
/*F0*/	IK_JoyPovUp     ,IK_JoyPovDown	,IK_JoyPovLeft	,IK_JoyPovRight	,
/*F4*/	IK_UnknownF4	,IK_UnknownF5	,IK_Attn		,IK_CrSel		,
/*F8*/	IK_ExSel		,IK_ErEof		,IK_Play		,IK_Zoom		,
/*FC*/	IK_NoName		,IK_PA1			,IK_OEMClear
};

var(Display) class<RenderIterator> RenderIteratorClass;	// class to instantiate as the actor's RenderInterface
var transient RenderIterator RenderInterface;		// abstract iterator initialized in the Rendering engine

//-----------------------------------------------------------------------------
// natives.

// Execute a console command in the context of the current level and game engine.
native function string ConsoleCommand( string Command );


//=============================================================================
// Skeletal Support (natives 600-700)
//=============================================================================
native(602) final function Vector	GetJointPos(int joint);
native(603) final function Rotator	GetJointRot(int joint);
//native(604)
native(605) final function string	GetJointName(int joint);
//native(606)
//native(607)
native(608) final function			ApplyJointForce(int joint, Vector force);
native(609) final function int		NumJoints();
native(610) final function			SetDefaultPolygroups();
native(611) final function			SetDefaultJointFlags();
//native(612)
native(613) final function			AttachActorToJoint(Actor a, int j);
native(614) final function actor	DetachActorFromJoint(int j);
//native(615)
native(616) final function			TurnJointTo(int joint, Rotator rot);
native(617) final function actor	ActorAttachedTo(int joint);
native(618) final function int		ClosestJointTo(Vector point);
native(619) final function int		JointNamed(name jointname);
native(620) final function			ResetAnimationCache(name seq);
native(621) final function			SetJointRot(int joint, Rotator rot);
native(622) final function			FrameSweep(int curframe, vector weaponvect, out vector lastB1, out vector lastE1);

event FrameSwept(vector B1, vector E1, vector B2, vector E2);
event FrameNotify(int framepassed);

simulated event GetSpringJointParms(int joint, out float DampFactor, out float SpringConstant, out vector SpringThreshold)
{
	DampFactor = 1.0;
	SpringConstant = 20;
	SpringThreshold = vect(100,100,100);
}

simulated event GetAccelJointParms(int joint, out float DampFactor, out float RotThreshold)
{
	DampFactor = 1.0;
	RotThreshold = 2000;
}

simulated event float GetAccelJointMagnitude(int joint)
{
	return 5000;
}

// --New natives reserved number list
// Skeletal Support				600-649
// Accelerators use				650-659
// Actor::Release/Wait 			660-661
// Object::VSize2D				662
// Actor::CalcArcVelocity		663
// Pawn::NearestNavPoint		664
// Pawn::CloserNavPointTo		665
// Actor::TraceTexture			666
// Actor::LipSyncString			667
// Polyobj::GetCollisionRadius	668
// Polyobj::GetTexture			669
// Pawn::Look					670


native(660) final latent function WaitForRelease();		// Wait to be released
native(661) final function Release();					// Release an actor from waiting
native(663) final function Vector CalcArcVelocity(int trajectory, vector src, vector dst);

final function ReleaseTagged(name tag)
{
	local actor A;
	foreach AllActors(class'actor',A,tag)
		A.Release();
}

event TouchJointOf  (Actor Other, int joint);	// Actor touched joint of Other during Movement
event JointTouchedBy(Actor Other, int joint);	// Actor's joint touched by Other during Movement

// 3 directions: 0=no dir change, sign=dir mag=velocity, PosOffset of spring joint
event JointChangedDirection(int joint, vector Direction, vector PosOffset);

function Texture PainSkin(int BodyPart)
{
//	SLog("Default painskin on"@Name$"!");
	return Texture'engine.s_actor';
}

function int BodyPartForJoint(int joint)
{
	return BODYPART_BODY;
}

function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int BodyPart)
{
	return(true);
}

// All damage functionality comes through this instead of TakeDamage()
// Returns true if the swipe can continue through this joint, false if the swipe should stop
event bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local int BodyPart;
	
	BodyPart = BodyPartForJoint(joint);

	if (DamageType == 'fire')
	{	// Light on fire
		SetOnFire(EventInstigator, joint);
	}
	
	return(DamageBodyPart(Damage, EventInstigator, HitLoc, Momentum, DamageType, BodyPart));
}

function SetOnFire(Pawn EventInstigator, int Joint);


//============================================================
//
// ApplyDamageToActor
//
//============================================================
function ApplyDamageToActor(int amount, name DamageType, Pawn EventInstigator, actor victim, vector Location, vector Momentum, int joint)
{
	victim.JointDamaged(amount, EventInstigator, Location, Momentum, DamageType, joint);
}

//============================================================
//
// GetDamageValues
//
//============================================================
function GetDamageValues(int Damage, name DamageType, out int BluntDamage, out int SeverDamage)
{
	switch(DamageType)
	{
		case 'fire':
			BluntDamage = Damage;
			break;
		case 'blunt':
			BluntDamage = Damage;
			SeverDamage = 0;
			break;
		case 'sever':
			BluntDamage = 0;
			SeverDamage = Damage;
			break;
		case 'bluntsever':
		default:
			BluntDamage = 0.5 * Damage;
			SeverDamage = 0.5 * Damage;
			break;
	}
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_NONE;
}

//============================================================
//
// MatterTrace
//
// Returns the material struck by a traceline
// This routine is used by the weapon sweep code, which
// passes in HitLoc (for end).  Since HitLoc of obtained 
// through a volumetric trace (and TraceTexture is a line
// trace), this routine fudges the end point out a bit
// to adjust for the volumetric trace
// 
// Additionally, if offset is nonzero, this trace function uses
// the offset value to fudge a bit to find the texture hit
// by the trace
//============================================================

function EMatterType MatterTrace(vector end, vector start, optional float offset, optional out texture hitTexture)
{
	local vector adjust;
	local texture tex;
	local int Flags;
	local vector ScrollDir;

	adjust = start + (end - start) * 1.5;
	tex = TraceTexture(adjust, start, Flags, ScrollDir);

	if(tex == NONE && offset > 0)
	{ // Trace a bit to the left
		adjust.X -= offset;
		tex = TraceTexture(adjust, start, Flags, ScrollDir);
		if(tex == NONE)
		{ // Trace a bit to the right
			adjust.X += offset * 2;
			tex = TraceTexture(adjust, start, Flags, ScrollDir);
			if(tex == NONE)
			{ // Trace a bit to the north
				adjust.X -= offset;
				adjust.Y -= offset;
				tex = TraceTexture(adjust, start, Flags, ScrollDir);
				if(tex == NONE)
				{ // Trace a bit to the south
					adjust.Y += offset * 2;
					tex = TraceTexture(adjust, start, Flags, ScrollDir);
					if(tex == NONE)
					{ // Trace a bit down
						adjust.Y -= offset;
						adjust.Z -= offset;
						tex = TraceTexture(adjust, start, Flags, ScrollDir);
						if(tex == NONE)
						{ // Trace a bit up
							adjust.Z += offset * 2;
							tex = TraceTexture(adjust, start, Flags, ScrollDir);
						}
					}
				}
			}
		}
	}

	hitTexture = tex;

	if(tex != None)
	{
		return(tex.TextureMaterial);
	}

	return(MATTER_NONE);
}

function AddVelocity(vector NewVelocity)
{
}

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	// NEW ACTOR VARIABLES NOT YET REPLICATED:
	/*
		//server only stuff
		var(Collision) bool       bSweepable;		// RUNE:  This actor can be hit by weapons
		var           byte      AttachParentJoint;// RUNE: Parent joint index I am attached to

		//set client side
		var			 int			LODPolyCount;	 // RUNE:  LOD last rendered polycount
		var(Display) float			LODDistMax;	     // RUNE:  LOD max distance
		var(Display) float			LODDistMin;	     // RUNE:  LOD min distance
		var(Display) float			LODPercentMin;	 // RUNE:  LOD min percentage cap
		var(Display) float			LODPercentMax;	 // RUNE:  LOD max percentage cap
		var(Display) enum			ELODCurve		 // RUNE:  LOD Curve types
		var			 shadowtexture	Shadow;			 // RUNE:  ShadowTexture
		var			 vector			ShadowVector;	 // RUNE:  Shadow Direction (pointed towards actor)

		//unknown
		var byte				  BaseJoint;	 // RUNE:  If the Base has bJointsBlock, this contains the joint index
		var EMatterType			  BaseMatterType; // RUNE:  The matter associated with the base
		var Vector				  BaseScrollDir; // RUNE:  Scroll direction associated with the base
		var(Display)  bool		bPointLight;	 // RUNE:  Actor is point lit at its centerpoint, rather than directionally lit
		var(Movement) bool           bNoSurfaceBob;     // Don't bob on water surface (can't jump out of water either)
		var(Skeleton) bool           bApplyLagToAccelerators;	// Apply -Velocity to accelerators
	*/

	// Relationships.
	unreliable if( Role==ROLE_Authority )
		Owner, Role, RemoteRole;
	unreliable if( bNetOwner && Role==ROLE_Authority )
		bNetOwner, Inventory;
	unreliable if( bReplicateInstigator && (RemoteRole>=ROLE_SimulatedProxy) && (Role==ROLE_Authority) )
		Instigator;
	unreliable if( Role==ROLE_Authority )
		AnimProxy;

	// Ambient sound.
	unreliable if( (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) )
		AmbientSound;
	unreliable if( AmbientSound!=None && Role==ROLE_Authority  && (!bNetOwner || !bClientAnim) )
		SoundRadius, SoundVolume, SoundPitch;
	unreliable if( bDemoRecording )
		DemoPlaySound;

	// Collision.
	unreliable if( Role==ROLE_Authority )
		bCollideActors, bCollideWorld;
	unreliable if( (bCollideActors || bCollideWorld) && Role==ROLE_Authority )
		bProjTarget, bBlockActors, bBlockPlayers, CollisionRadius, CollisionHeight;
	unreliable if( Role==ROLE_Authority && DrawType==DT_SkeletalMesh )
		bJointsBlock, bJointsTouch, JointFlags;

	// Location.
	unreliable if( !bCarriedItem && (bNetInitial || bSimulatedPawn || RemoteRole<ROLE_SimulatedProxy) && Role==ROLE_Authority )
		Location;
	unreliable if( !bCarriedItem && (DrawType==DT_Mesh || DrawType==DT_SkeletalMesh || DrawType==DT_Brush || DrawType == DT_VerticalSprite) && (bNetInitial || bSimulatedPawn || RemoteRole<ROLE_SimulatedProxy) && Role==ROLE_Authority )
		Rotation;
	unreliable if( RemoteRole==ROLE_SimulatedProxy )
		Base;

	// Velocity.
	unreliable if( bSimFall || ((RemoteRole==ROLE_SimulatedProxy && (bNetInitial || bSimulatedPawn)) || bIsMover) )
		Velocity;

	// Physics.
	unreliable if( bSimFall || (RemoteRole==ROLE_SimulatedProxy && bNetInitial && !bSimulatedPawn) )
		Physics, Acceleration, bBounce;
	unreliable if( RemoteRole==ROLE_SimulatedProxy && Physics==PHYS_Rotating && bNetInitial )
		bFixedRotationDir, bRotateToDesired, RotationRate, DesiredRotation;

	// Animation. 
	unreliable if((DrawType==DT_Mesh || DrawType == DT_SkeletalMesh || AnimationProxy(self)!=None) &&
		((RemoteRole<=ROLE_SimulatedProxy && (!bNetOwner || !bClientAnim)) || bDemoRecording) )
		AnimSequence, SimAnim, AnimMinRate, bAnimNotify;

	// Rendering.
	unreliable if( Role==ROLE_Authority )
		bHidden, bOnlyOwnerSee, bCarriedItem;
	unreliable if( Role==ROLE_Authority )
		Texture, DrawScale, DrawType, Style;
	unreliable if( Role==ROLE_Authority && Style==STY_AlphaBlend)
		AlphaScale;
	unreliable if( DrawType==DT_Sprite && !bHidden && (!bOnlyOwnerSee || bNetOwner) && Role==ROLE_Authority)
		Sprite;
	unreliable if( DrawType==DT_Mesh && Role==ROLE_Authority )
		Mesh, Skin, MultiSkins, Fatness;
	unreliable if( DrawType==DT_SkeletalMesh || DrawType==DT_Mesh)
		PrePivot, bMeshEnviroMap;
	unreliable if( DrawType!=DT_None )
		AmbientGlow, ScaleGlow, bUnlit;
	unreliable if( DrawType==DT_Brush && Role==ROLE_Authority )
		Brush;
	unreliable if( Role==ROLE_Authority && DrawType==DT_SkeletalMesh)
		Skeletal, SkelMesh, SkelGroupSkins, SkelGroupFlags, JointChild, bHasShadow,
		BlendAnimAlpha, BlendAnimFrame, BlendAnimSequence, DesiredColorAdjust, DesiredFatness,
		LODDistMax, LODDistMin, LODPercentMin, LODPercentMax, LODCurve,
		bDrawSkel, bDrawJoints, bDrawAxes,
		SubstituteMesh, // RUNE:  substitute mesh code
		// Mirrored support
		AttachParent, bMirrored;
//	unreliable if( Role==ROLE_Authority && (DrawType==DT_SkeletalMesh || DrawType==DT_Sprite || DrawType==DT_ParticleSystem))
//		AttachParent;

	// Lighting.
	unreliable if( Role==ROLE_Authority )
		LightType;
	unreliable if( LightType!=LT_None && Role==ROLE_Authority )
		LightEffect, LightBrightness, LightHue, LightSaturation,
		LightRadius, LightPeriod, LightPhase,
		VolumeBrightness, VolumeRadius,
		bSpecialLit, bSpecialLit2, bSpecialLit3,
		bNegativeLight, bAffectWorld, bAffectActors;

	// Properties
	unreliable if( Role==ROLE_Authority )
		bLookFocusPlayer, bLookFocusCreature;

	// Messages
	reliable if( Role<ROLE_Authority )
		BroadcastMessage, BroadcastLocalizedMessage;
}

//=============================================================================
// Actor error handling.

// Handle an error and kill this one actor.
native(233) final function Error( coerce string S );

//=============================================================================
// General functions.

// Latent functions.
native(256) final latent function Sleep( float Seconds );

// Collision.
native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
native(283) final function bool SetCollisionSize( float NewRadius, float NewHeight );

// Movement.
native(266) final function bool Move( vector Delta );
native(267) final function bool SetLocation( vector NewLocation );
native(299) final function bool SetRotation( rotator NewRotation );
native(3969) final function bool MoveSmooth( vector Delta );
native(3971) final function AutonomousPhysics(float DeltaSeconds);

// Relations.
native(298) final function SetBase( actor NewBase );
native(272) final function SetOwner( actor NewOwner );

//=============================================================================
// Animation.

// Animation functions.
native(259) final function PlayAnim( name Sequence, optional float Rate, optional float TweenTime );
native(260) final function LoopAnim( name Sequence, optional float Rate, optional float TweenTime, optional float MinRate );
native(294) final function TweenAnim( name Sequence, float Time );
native(282) final function bool IsAnimating();
native(293) final function name GetAnimGroup( name Sequence );
native(261) final latent function FinishAnim();
native(263) final function bool HasAnim( name Sequence );

// Animation notifications.
event AnimEnd();
event AnimProxyEnd();

function PlayStabRemove()
{
}

//=========================================================================
// Physics.

// Physics control.
native(301) final latent function FinishInterpolation();
native(3970) final function SetPhysics( EPhysics newPhysics );



//=============================================================================
// Engine notification functions.

//
// Major notifications.
//
event Spawned();
event Expired();
event GainedChild( Actor Other );
event LostChild( Actor Other );
event Tick( float DeltaTime );
event Destroyed()
{
	UnlinkAttachments();
	DestroyAnimationProxy();
}

function UnlinkAttachments()
{
	local int ix, numberjoints;
	local actor A;

	// Remove any attachments
	if (Skeletal != None)
	{
		numberjoints = NumJoints();
		for (ix=0; ix<numberjoints; ix++)
		{
			A = DetachActorFromJoint(ix);
			if (A != None && PlayerPawn(A)==None)
			{
				//slog("  removing"@A.name@"from"@name);
				A.Destroy();
			}
		}
	}

	// Detach from any parent actors
	if (bCarriedItem)
	{
		//slog("  detaching"@name@"from parent"@AttachParent@"joint"@AttachParentJoint);
		if (AttachParent != None)
			AttachParent.DetachActorFromJoint(AttachParentJoint);
	}
}

//
// Triggers.
//
event Trigger( Actor Other, Pawn EventInstigator );
event UnTrigger( Actor Other, Pawn EventInstigator );
event BeginEvent();
event EndEvent();
function FireEvent(name TheEvent)
{
	local actor A;
	if( TheEvent != '' )
		foreach AllActors( class 'Actor', A, TheEvent )
			A.Trigger(self, Instigator);
}

// -------------------------------------------------------
//
// UseTrigger
//
// Other "used" me, return true if use message eaten
// -------------------------------------------------------
event bool UseTrigger(Actor Other)
{
	return false;
}

//
// Physics & world interaction.
//
event Timer();
event HitWall( vector HitNormal, actor HitWall );
event Falling();
event Landed( vector HitNormal, actor HitActor );
event ZoneChange( ZoneInfo NewZone );
event Touch( Actor Other );
event PostTouch( Actor Other ); // called for PendingTouch actor after physics completes
event UnTouch( Actor Other );
event Bump( Actor Other );
event BaseChange();
event Attach( Actor Other );
event Detach( Actor Other );
event KillCredit( Actor Other );
event Actor SpecialHandling(Pawn Other);
event bool EncroachingOn( actor Other );
event EncroachedBy( actor Other );
event InterpolateEnd( actor Other );
event EndedRotation();

event FellOutOfWorld()
{
	UnlinkAttachments();
	SetPhysics(PHYS_None);
	Destroy();
}	

//
// Damage and kills.
//
event KilledBy( pawn EventInstigator );
event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	JointDamaged(Damage, EventInstigator, HitLocation, Momentum, DamageType, 0);
}

//
// Trace a line and see what it collides with first.
// Takes this actor's collision properties into account.
// Returns first hit actor, Level if hit level, or None if hit nothing.
//
native(277) final function Actor Trace
(
	out vector      HitLocation,
	out vector      HitNormal,
	vector          TraceEnd,
	optional vector TraceStart,
	optional bool   bTraceActors,
	optional vector Extent
);

// returns true if did not hit world geometry
native(548) final function bool FastTrace
(
	vector          TraceEnd,
	optional vector TraceStart
);

// RUNE
// Returns the texture from a given traceline (ALWAYS has an extent of (0, 0, 0))
native(666) final function Texture TraceTexture(vector TraceEnd, vector TraceStart, out int Flags, out vector ScrollDir);

//
// Spawn an actor. Returns an actor of the specified class, not
// of class Actor (this is hardcoded in the compiler). Returns None
// if the actor could not be spawned (either the actor wouldn't fit in
// the specified location, or the actor list is full).
// Defaults to spawning at the spawner's location.
//
native(278) final function actor Spawn
(
	class<actor>      SpawnClass,
	optional actor	  SpawnOwner,
	optional name     SpawnTag,
	optional vector   SpawnLocation,
	optional rotator  SpawnRotation
);

//
// Destroy this actor. Returns true if destroyed, false if indestructable.
// Destruction is latent. It occurs at the end of the tick.
//
native(279) final function bool Destroy();

//=============================================================================
// Timing.

// Causes Timer() events every NewTimerRate seconds.
native(280) final function SetTimer( float NewTimerRate, bool bLoop );

//=============================================================================
// Sound functions.

/* Play a sound effect. - returns the ID to use to stop it, valid slots are:
	SLOT_None,
	SLOT_Misc,
	SLOT_Pain,
	SLOT_Interact,
	SLOT_Ambient,
	SLOT_Talk,
	SLOT_Interface,
*/

native(667) final function string LipSyncString(Sound sound, float granularity);

native(264) final function int PlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch
);

// play a sound effect, but don't propagate to a remote owner
// (he is playing the sound clientside
native simulated final function PlayOwnedSound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch
);

native(265) final function StopSound(int Id);
native(268) final function StopAllSound();

native simulated event DemoPlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch
);

// Get a sound duration.
native final function float GetSoundDuration(sound Sound);

//=============================================================================
// AI functions.

//
// Inform other creatures that you've made a noise
// they might hear (they are sent a HearNoise message)
// Senders of MakeNoise should have an instigator if they are not pawns.
//
native(512) final function MakeNoise( float Loudness );

//
// PlayerCanSeeMe returns true if some player has a line of sight to 
// actor's location.
//
native(532) final function bool PlayerCanSeeMe();

//=============================================================================
// Regular engine functions.

// Teleportation.
event bool PreTeleport( Teleporter InTeleporter );
event PostTeleport( Teleporter OutTeleporter );

// Level state.
event BeginPlay();

//========================================================================
// Disk access.

// Find files.
native(539) final function string GetMapName( string NameEnding, string MapName, int Dir );
native(545) final function GetNextSkin( string Prefix, string CurrentSkin, int Dir, out string SkinName, out string SkinDesc );
native(547) final function string GetURLMap();
native final function string GetNextInt( string ClassName, int Num );
native final function GetNextIntDesc( string ClassName, int Num, out string Entry, out string Description );

//=============================================================================
// Iterator functions.

// Iterator functions for dealing with sets of actors.
native(304) final iterator function AllActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );
native(305) final iterator function ChildActors   ( class<actor> BaseClass, out actor Actor );
native(306) final iterator function BasedActors   ( class<actor> BaseClass, out actor Actor );
native(307) final iterator function TouchingActors( class<actor> BaseClass, out actor Actor );
native(309) final iterator function TraceActors   ( class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent, optional bool bTraceLevel );
native(310) final iterator function RadiusActors  ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );
native(311) final iterator function VisibleActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc );
native(312) final iterator function VisibleCollidingActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc, optional bool bIgnoreHidden );

native(313) final iterator function SweepActors   ( class<actor> BaseClass, out actor Actor, vector start1, vector stop1, vector start2, vector stop2, float ExtentRadius, out vector HitLoc, out vector HitNorm, out int LowJointMask, out int HighJointMask);

//=============================================================================
// Color operators
native(549) static final operator(20)  color -     ( color A, color B );
native(550) static final operator(16) color *     ( float A, color B );
native(551) static final operator(20) color +     ( color A, color B );
native(552) static final operator(16) color *     ( color A, float B );

//=============================================================================
// Scripted Actor functions.

// draw on canvas before flash and fog are applied (used for drawing weapons)
event RenderOverlays( canvas Canvas );

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	// Handle autodestruction if desired.
	if( !bGameRelevant && (Level.NetMode != NM_Client) && !Level.Game.IsRelevant(Self) )
	{
		Destroy();
	}

	if (Skeletal != None)
	{
		// Set Default Skeleton properties
		SetDefaultPolyGroups();
		SetDefaultJointFlags();
	}

	if ( DrawScale != Default.Drawscale )
	{
		SetCollisionSize(CollisionRadius*DrawScale/Default.DrawScale, CollisionHeight*DrawScale/Default.DrawScale);
	}
}

//
// Broadcast a message to all players.
//
event BroadcastMessage( coerce string Msg, optional bool bBeep, optional name Type )
{
	local Pawn P;

	if (Type == '')
		Type = 'Event';

	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if( P.bIsPlayer || P.IsA('MessagingSpectator') )
				P.ClientMessage( Msg, Type, bBeep );
}

//
// Broadcast a localized message to all players.
// Most message deal with 0 to 2 related PRIs.
// The LocalMessage class defines how the PRI's and optional actor are used.
//
event BroadcastLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local Pawn P;

	for ( P=Level.PawnList; P != None; P=P.nextPawn )
		if ( P.bIsPlayer || P.IsA('MessagingSpectator') )
			P.ReceiveLocalizedMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

//
// Called immediately after gameplay begins.
//
event PostBeginPlay();

//
// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	if( InitialState!='' )
		GotoState( InitialState );
	else
		GotoState( 'Auto' );
}

// called after PostBeginPlay on net client
event PostNetBeginPlay();

//
// Hurt actors within the radius.
//
final function HurtRadius( float DamageAmount, float DamageRadius, name DamageType, float Momentum, vector HitLocation )
{
	local actor Victim;
	local float damageScale, dist;
	local vector dir;
	
	foreach VisibleCollidingActors( class 'Actor', Victim, DamageRadius, HitLocation )
	{
		if( Victim != self && Victim != Owner)
		{
			dir = Victim.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			damageScale = 1 - FMax(0,(dist - Victim.CollisionRadius)/DamageRadius);

			Victim.JointDamaged(damageScale * DamageAmount,
				Instigator,
				Victim.Location - 0.5 * (Victim.CollisionHeight + Victim.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType,
				0);
		} 
	}
}

//
// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept();

//
// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept();

//
// Called when a scripted texture needs rendering
//
event RenderTexture(ScriptedTexture Tex);

//
// Called by PlayerPawn when this actor becomes its ViewTarget.
//
function BecomeViewTarget();

//
// Returns the string representation of the name of an object without the package
// prefixes.
//
function String GetItemName( string FullName )
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

//
// Returns the human readable string representation of an object.
//

function String GetHumanName()
{
	return GetItemName(string(class));
}

//
// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
	bMeshEnviromap = bEnviromap;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
	bMeshEnviromap = Default.bMeshEnviromap;
}


// Spawn animation proxies for a skeletal actor
function SpawnAnimationProxy()
{
	if (Skeletal == None)
		SLog("Only skeletal actors can spawn Animation Proxies");

	AnimProxy = spawn(class'AnimationProxy', self);
}

function DestroyAnimationProxy()
{
	if (AnimProxy != None)
	{
		AnimProxy.Destroy();
		AnimProxy = None;
	}
}

//============================================================================
//
// CheckDefending
//
// Checks if the Actor is defending 
// Default does nothing.
//============================================================================

function bool CheckDefending()
{
	return(false);
}

//============================================================================
//
// GetUseAnim
//
// Returns the animation that the player (or a viking) should play when
// this item is 'used'.
//============================================================================

function name GetUseAnim()
{
	return('');
}

//============================================================================
//
// CanBeUsed
//
// Whether the actor can be used.
//============================================================================

function bool CanBeUsed(Actor Other)
{
	return(false);
}

//============================================================================
//
// GetUsePriority
//
// Returns the priority of the weapon, lower is better
//============================================================================

function int GetUsePriority()
{
	return(9999);
}

final function bool ActorInSector(actor A, int angle)
{
	local rotator angleToTarget;
	local int yaw;
	
	yaw = (rotator(A.Location - Location) - Rotation).Yaw;
	if (yaw > 32768)
		yaw = yaw - 65535;
	if (yaw < -32768)
		yaw = yaw + 65535;
	
	return (yaw >= -angle && yaw <= angle);
}

//============================================================
//
// Slog
//
// Sends text to the Log as well as displaying on all client screens for debug purposes
//============================================================
simulated function SLog(coerce string msg)
{
	local Pawn P;
	Log(msg);
	
	// Remove the broadcast when testing networking or building final
/* Global Broadcast
	for( P=Level.PawnList; P!=None; P=P.nextPawn )
		if( P.bIsPlayer )
			PlayerPawn(P).ClientMessage(msg);
*/
	if (Level.Netmode == NM_Client)
	{	// No pawn list on client
		foreach AllActors(class'Pawn', P)
		{
			if(P.bIsPlayer && P.Role==ROLE_AutonomousProxy)
			{
				PlayerPawn(P).ClientMessage(msg);
//				break;
			}
		}
	}
	else
	{
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
		{
			if(P.bIsPlayer && P.RemoteRole!=ROLE_AutonomousProxy)
			{
				PlayerPawn(P).ClientMessage(msg);
//				break;
			}
		}
	}
}

// Allow any actor to process console commands (not implimented)
event int HandleConsoleCommand(string cmd)
{
}


//============================================================
//
// DebugStop
//
// Stops everything for debugging purposes
//============================================================
function DebugStop(string msg, optional bool bStopAnimation)
{
	local Pawn P;
	local PlayerPawn aPlayer;

	SLog(Name@"DebugStop:"@msg@"("$bStopAnimation$")");
	
	// Remove the broadcast when testing networking or building final
	for( P=Level.PawnList; P!=None; P=P.nextPawn )
		if( P.bIsPlayer )
			aPlayer = PlayerPawn(P);

	if (bStopAnimation)
		AnimRate = 0;

	// Pause the game
	//aPlayer.SetPause(true);

	// Players only
	Level.bPlayersOnly = true;

	// Turn on Debug info
	if (aPlayer.myDebugHud != None)
	{
		aPlayer.myDebugHUD.DebugMode = DEBUG_CONSTANT;
		aPlayer.myDebugHUD.DebugHudMode = HUD_ACTOR;
		aPlayer.myDebugHUD.SetWatch(None);
		aPlayer.myDebugHUD.SetWatch(self);
	}
}



//============================================================
//
// Debug
//
// Debug rendering callback
//============================================================
simulated function debug(canvas Canvas, int mode)
{
	local float yaw,pitch,roll;
	local string text;
	local Inventory i;
	local actor A;

	if (mode == HUD_SCRIPT)
	{
		Canvas.DrawText("Class:"@Class);
		Canvas.CurY -= 8;
		Canvas.DrawText("Tag:  "@Tag);
		Canvas.CurY -= 8;
		Canvas.DrawText("Event:"@Event);
		Canvas.CurY -= 8;
		Canvas.DrawText("State:"@GetStateName());
		Canvas.CurY -= 8;

		if (Event != '')
			foreach AllActors(class'Actor', A, Event)
				Canvas.DrawLine3D(Location, A.Location, 255, 255, 0);

		return;
	}

	if (mode >= DEBUG_MULTIPLE)
	{
		Canvas.DrawText(name);
		Canvas.CurY -= 8;

		return;
	}

	Canvas.SetPos(0,50);
	if (bDeleteMe)
	{
		Canvas.SetColor(255,255,0);
		Canvas.DrawText("Name:     "$name@"(DELETED)");
		Canvas.SetColor(255,0,0);
	}
	else
		Canvas.DrawText("Name:     "$name);
	Canvas.CurY -= 8;
	Canvas.DrawText("Class:    "$class);
	Canvas.CurY -= 8;
	Canvas.DrawText("Tag:      "$tag);
	Canvas.CurY -= 8;
	Canvas.DrawText("Event:    "$Event);
	Canvas.CurY -= 8;
	Canvas.DrawText("State:    "$GetStateName());
	Canvas.CurY -= 8;
	Canvas.DrawText("Owner:    "$Owner);
	Canvas.CurY -= 8;
	Canvas.DrawText("Reg.Zone: "$Region.Zone);
	Canvas.CurY -= 8;
	Canvas.DrawText("R.ZoneNum:"$Region.ZoneNumber);
	Canvas.CurY -= 8;
	Canvas.DrawText("Location: "$Location);
	Canvas.CurY -= 8;
	Canvas.DrawText("PrePivot: "$PrePivot);
	Canvas.CurY -= 8;
	Canvas.DrawText("Velocity: "$Velocity);
	Canvas.CurY -= 8;
	Canvas.DrawText("Accel:    "$Acceleration);
	Canvas.CurY -= 8;

	switch(Physics)
	{
		case PHYS_None:
			text = "PHYS_None";		break;
		case PHYS_Walking:
			text = "PHYS_Walking";	break;
		case PHYS_Falling:
			text = "PHYS_Falling";	break;
		case PHYS_Swimming:
			text = "PHYS_Swimming";	break;
		case PHYS_Flying:
			text = "PHYS_Flying";	break;
		case PHYS_Rotating:
			text = "PHYS_Rotating";	break;
		case PHYS_Projectile:
			text = "PHYS_Projectile";	break;
		case PHYS_Rolling:
			text = "PHYS_Rolling";	break;
		case PHYS_Interpolating:
			text = "PHYS_Interpolating";	break;
		case PHYS_MovingBrush:
			text = "PHYS_MovingBrush";	break;
		case PHYS_Spider:
			text = "PHYS_Spider";	break;
		case PHYS_Trailer:
			text = "PHYS_Trailer";	break;
		case PHYS_Sliding:
			text = "PHYS_Sliding";	break;
		default:
			text = "UNKNOWN (" $ Physics $")";	break;
	}
	Canvas.DrawText("Physics:  "$text);
	Canvas.CurY -= 8;

	switch(Drawtype)
	{
		case DT_None:			text="DT_None";							break;
		case DT_Sprite:			text="DT_Sprite tex="$Texture;			break;
		case DT_Mesh:			text="DT_Mesh mesh="$Mesh;				break;
		case DT_Brush:			text="DT_Brush";						break;
		case DT_RopeSprite:		text="DT_RopeSprite";					break;
		case DT_VerticalSprite:	text="DT_VerticalSprite tex="$Texture;	break;
		case DT_SkeletalMesh:	text="DT_SkeletalMesh skel="$Skeletal@"SkelMesh="$SkelMesh;	break;
		case DT_SpriteAnimOnce:	text="DT_SpriteAnimOnce";				break;
		case DT_ParticleSystem:
			text="DT_ParticleSystem ptex="$ParticleSystem(self).ParticleTexture[0];
			break;
	}
	Canvas.DrawText("DrawType: "$text);
	Canvas.CurY -= 8;
	switch(Style)
	{
		case STY_None:			text="STY_None";		break;
		case STY_Normal:		text="STY_Normal";		break;
		case STY_Masked:		text="STY_Masked";		break;
		case STY_Translucent:	text="STY_Translucent";	break;
		case STY_Modulated:		text="STY_Modulated";	break;
		case STY_AlphaBlend:	text="STY_AlphaBlend";	break;
	}
	Canvas.DrawText("Style:    "$text);
	Canvas.CurY -= 8;
	pitch = Rotation.Pitch * 360 / 65536;
	yaw = Rotation.Yaw * 360 / 65536;
	roll = Rotation.Roll * 360 / 65536;
	Canvas.DrawText("Rotation: P="$pitch$" Y="$yaw$" R="$roll);
	Canvas.CurY -= 8;

//	Canvas.DrawText("Region.Zone:      "@Region.Zone);
//	Canvas.CurY -= 8;
//	Canvas.DrawText("Region.ZoneNumber:"@Region.ZoneNumber);
//	Canvas.CurY -= 8;

/*	// Rotation stuff
	Canvas.DrawText("Rotation:        P="$Rotation.Pitch$" Y="$Rotation.yaw$" R="$Rotation.roll);
	Canvas.CurY -= 8;
	Canvas.DrawText("DesiredRotation: P="$DesiredRotation.Pitch$" Y="$DesiredRotation.yaw$" R="$DesiredRotation.roll);
	Canvas.CurY -= 8;
	Canvas.DrawText("RotationRate:    P="$RotationRate.Pitch$" Y="$RotationRate.yaw$" R="$RotationRate.roll);
	Canvas.CurY -= 8;
	Canvas.DrawText("bFixedRotationDir:"@bFixedRotationDir);
	Canvas.CurY -= 8;
	Canvas.DrawText("bRotateToDesired: "@bRotateToDesired);
	Canvas.CurY -= 8;
	Canvas.DrawText("bBounce:          "@bBounce);
	Canvas.CurY -= 8;
*/
	Canvas.DrawText("Mass:     "$Mass);
	Canvas.CurY -= 8;
	Canvas.DrawText("Buoyancy: "$Buoyancy);
	Canvas.CurY -= 8;
	Canvas.DrawText("Sequence: "$AnimSequence);
	Canvas.CurY -= 8;
	Canvas.DrawText("AnimFrame:"$AnimFrame);
	Canvas.CurY -= 8;
	Canvas.DrawText("AnimRate  "$AnimRate);
	Canvas.CurY -= 8;
//	Canvas.DrawText("Base: "$Base);
//	Canvas.CurY -= 8;

	text = "Collision:";
	if (bCollideWorld)
		text = text@"CW";
	if (bCollideActors)
		text = text@"CA";
	if (bBlockActors)
		text = text@"BA";
	if (bBlockPlayers)
		text = text@"BP";
	Canvas.DrawText(text);
	Canvas.CurY -= 8;

	if (bHidden)
	{
		Canvas.DrawText("bHidden:"@bHidden);
		Canvas.CurY -= 8;
	}

	text = "";
	if (bStatic)
		text = text@"bStatic";
	if (bStasis)
		text = text@"bStasis";
	if (text != "")
	{
		Canvas.DrawText(text);
		Canvas.CurY -= 8;
	}

	if (AnimProxy != None)
	{
		Canvas.DrawText("AnimProxy: " $ AnimProxy);
		Canvas.CurY -= 8;
		Canvas.DrawText("  Sequence:   " $ AnimProxy.AnimSequence);
		Canvas.CurY -= 8;
		Canvas.DrawText("  Frame       " $ AnimProxy.AnimFrame);
		Canvas.CurY -= 8;
	}

	Canvas.DrawText("bCarriedItem:"@bCarriedItem);
	Canvas.CurY -= 8;
	if (bCarriedItem)
	{
		Canvas.DrawText("AttachParent:"@AttachParent);
		Canvas.CurY -= 8;
	}
	if (Inventory != None)
	{
		Canvas.DrawText("Inventory:");
		Canvas.CurY -= 8;
		i = Inventory;
		while (i != None)
		{
			Canvas.DrawText("  "$i.name);
			Canvas.CurY -= 8;

			i = i.Inventory;
		}
	}
	Canvas.DrawText("LifeSpan:    "@LifeSpan);
	Canvas.CurY -= 8;
	Canvas.DrawText("Instigator:  "@Instigator);
	Canvas.CurY -= 8;
//	Canvas.DrawText("bLookFocusPlayer:"@bLookFocusPlayer);
//	Canvas.CurY -= 8;
}

defaultproperties
{
     Role=ROLE_Authority
     RemoteRole=ROLE_DumbProxy
     LODBias=1.000000
     OddsOfAppearing=1.000000
     bDifficulty0=True
     bDifficulty1=True
     bDifficulty2=True
     bDifficulty3=True
     bSinglePlayer=True
     bNet=True
     bNetSpecial=True
     DrawType=DT_Sprite
     Style=STY_Normal
     Texture=Texture'Engine.S_Actor'
     DrawScale=1.000000
     ScaleGlow=1.000000
     VisibilityRadius=10000.000000
     VisibilityHeight=10000.000000
     Fatness=128
     SpriteProjForward=32.000000
     DesiredFatness=128
     AlphaScale=1.000000
     LODDistMax=2500.000000
     LODPercentMax=1.000000
     LODCurve=LOD_CURVE_NORMAL
     bShadowCast=True
     bMovable=True
     SoundRadius=32
     SoundVolume=128
     SoundPitch=64
     TransientSoundVolume=1.000000
     CollisionRadius=22.000000
     CollisionHeight=22.000000
     bAffectWorld=True
     bAffectActors=True
     bJustTeleported=True
     Mass=100.000000
     NetPriority=1.000000
     NetUpdateFrequency=100.000000
}
