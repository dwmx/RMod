//=============================================================================
// Canvas: A drawing canvas.
// This is a built-in Unreal class and it shouldn't be modified.
//
// Notes.
//   To determine size of a drawable object, set Style to STY_None,
//   remember CurX, draw the thing, then inspect CurX and CurYL.
//=============================================================================
class Canvas extends Object
	native
	noexport;

/*
	Small:	Used for debug hud output
	Med:	Used for console text
	Big:	Use for menus
	Large:	Used for HUD, precaching, loading, etc.
*/

// Objects.
#exec Font Import File=Textures\SmallFont.pcx Name=SmallFont
#exec Font Import File=Textures\MedFont.pcx   Name=MedFont
//#exec Font Import File=Textures\BigFont.pcx   Name=BigFont
//#exec Font Import File=Textures\LargeFont.pcx Name=LargeFont


// RUNE fonts
// NOTE: To hard code a color use the suffix:  FontR=200 FontG=0 FontB=0
#exec new TrueTypeFontFactory Name=RuneMed   FontName="PR Uncial Alternate Capitals" Height=12 AntiAlias=1 CharactersPerPage=64
#exec new TrueTypeFontFactory Name=RuneBig   FontName="PR Uncial Alternate Capitals" Height=14 AntiAlias=1 CharactersPerPage=64
#exec new TrueTypeFontFactory Name=RuneCred  FontName="PR Uncial Alternate Capitals" Height=20 AntiAlias=1 CharactersPerPage=64
#exec new TrueTypeFontFactory Name=RuneCred2 FontName="PR Uncial Alternate Capitals" Height=24 AntiAlias=1 CharactersPerPage=64
#exec new TrueTypeFontFactory Name=RuneLarge FontName="PR Uncial Alternate Capitals" Height=36 AntiAlias=1 CharactersPerPage=16

#exec new TrueTypeFontFactory Name=Haettenschweiler16  FontName="Haettenschweiler" Height=16 AntiAlias=1 CharactersPerPage=64

#exec new TrueTypeFontFactory Name=RuneButton FontName="PR Uncial Alternate Capitals" Height=18 AntiAlias=1 CharactersPerPage=64
//#exec new TrueTypeFontFactory Name=RuneButton FontName="Lucida Sans Unicode" Height=24 AntiAlias=1 CharactersPerPage=64 List ="00 04"

// Font Use:
//	SmallFont			Debugging, Scoreboard ping
//	MedFont				Tab text, Scoreboard, Paused
//	RuneButton			Menu Buttons
//	RuneMed				Menus
//	RuneBig				Menus, RuneMessages
//	RuneLarge			Progress Messages
//	Haettenschweiler16	Subtitles, Toplines
//	??					Credits
//
//	Unused: ??: RuneCred, RuneCred2



// Modifiable properties.
var font    Font;            // Font for DrawText.
var float   SpaceX, SpaceY;  // Spacing for after Draw*.
var float   OrgX, OrgY;      // Origin for drawing.
var float   ClipX, ClipY;    // Bottom right clipping region.
var float   CurX, CurY;      // Current position for drawing.
var float   Z;               // Z location. 1=no screenflash, 2=yes screenflash.
var byte    Style;           // Drawing style STY_None means don't draw.
var float   CurYL;           // Largest Y size since DrawText.
var color   DrawColor;       // Color for drawing.
var bool    bCenter;         // Whether to center the text.
var bool    bNoSmooth;       // Don't bilinear filter.
var const int SizeX, SizeY;  // Zero-based actual dimensions.
var float	AlphaScale;		 // RUNE:  Alpha value used by STY_AlphaBlend

// Stock fonts.
var font SmallFont;          // Small system font.
var font MedFont;            // Medium system font.
var font BigFont;            // Big system font.
var font LargeFont;          // Large system font.
var font RuneMedFont;
var font CredsFont;
var font ButtonFont;

// Internal.
var const viewport Viewport; // Viewport that owns the canvas.
var const int FramePtr;      // Scene frame pointer.
var const int RenderPtr;	 // Render device pointer, only valid during UGameEngine::Draw

// native functions.
native(464) final function StrLen( coerce string String, out float XL, out float YL );
native(465) final function DrawText( coerce string Text, optional bool CR );
native(466) final function DrawTile( texture Tex, float XL, float YL, float U, float V, float UL, float VL );
native(467) final function DrawActor( Actor A, bool WireFrame, optional bool ClearZ );
native(468) final function DrawTileClipped( texture Tex, float XL, float YL, float U, float V, float UL, float VL );
native(469) final function DrawTextClipped( coerce string Text, optional bool bCheckHotKey );
native(470) final function TextSize( coerce string String, out float XL, out float YL );
native(471) final function DrawClippedActor( Actor A, bool WireFrame, int X, int Y, int XB, int YB, optional bool ClearZ );
native(480) final function DrawPortal( int X, int Y, int Width, int Height, actor CamActor, vector CamLocation, rotator CamRotation, optional int FOV, optional bool ClearZ );
native(490) final function DrawLine( float X1, float Y1, float X2, float Y2, float R, float G, float B );
native(491) final function DrawLine3D( vector P1, vector P2, float R, float G, float B );
native(492) final function TransformPoint( vector P1, out int X, out int Y );


final function DrawTextRightJustify(string text, int X, int Y)
{
	local float w,h;
	StrLen(text, w, h);
	SetPos(X-w, Y);
	DrawText(text);
}


// UnrealScript functions.
event Reset()
{
	Font        = Default.Font;
	SpaceX      = Default.SpaceX;
	SpaceY      = Default.SpaceY;
	OrgX        = Default.OrgX;
	OrgY        = Default.OrgY;
	CurX        = Default.CurX;
	CurY        = Default.CurY;
	Style       = Default.Style;
	DrawColor   = Default.DrawColor;
	CurYL       = Default.CurYL;
	bCenter     = false;
	bNoSmooth   = false;
	Z           = 1.0;
}
final function SetPos( float X, float Y )
{
	CurX = X;
	CurY = Y;
}
final function SetOrigin( float X, float Y )
{
	OrgX = X;
	OrgY = Y;
}
final function SetClip( float X, float Y )
{
	ClipX = X;
	ClipY = Y;
}
final function DrawPattern( texture Tex, float XL, float YL, float Scale )
{
	DrawTile( Tex, XL, YL, (CurX-OrgX)*Scale, (CurY-OrgY)*Scale, XL*Scale, YL*Scale );
}
final function DrawIcon( texture Tex, float Scale )
{
	if ( Tex != None )
		DrawTile( Tex, Tex.USize*Scale, Tex.VSize*Scale, 0, 0, Tex.USize, Tex.VSize );
}
final function DrawRect( texture Tex, float RectX, float RectY )
{
	DrawTile( Tex, RectX, RectY, 0, 0, Tex.USize, Tex.VSize );
}

final function DrawBox3D( vector Center, vector Extents, int R, int G, int B )
{
	local vector bX,bY,bZ;
	
	bX = vect(0,0,0); bX.X = Extents.X;
	bY = vect(0,0,0); bY.Y = Extents.Y;
	bZ = vect(0,0,0); bZ.Z = Extents.Z;

	// Top	
	DrawLine3D(Center+bZ+bX, Center+bZ+bY, R, G, B);
	DrawLine3D(Center+bZ+bY, Center+bZ-bX, R, G, B);
	DrawLine3D(Center+bZ-bX, Center+bZ-bY, R, G, B);
	DrawLine3D(Center+bZ-bY, Center+bZ+bX, R, G, B);
	
	// Bottom
	DrawLine3D(Center-bZ+bX, Center-bZ+bY, R, G, B);
	DrawLine3D(Center-bZ+bY, Center-bZ-bX, R, G, B);
	DrawLine3D(Center-bZ-bX, Center-bZ-bY, R, G, B);
	DrawLine3D(Center-bZ-bY, Center-bZ+bX, R, G, B);

	// Sides
	DrawLine3D(Center+bZ+bX, Center-bZ+bX, R, G, B);
	DrawLine3D(Center+bZ+bY, Center-bZ+bY, R, G, B);
	DrawLine3D(Center+bZ-bX, Center-bZ-bX, R, G, B);
	DrawLine3D(Center+bZ-bY, Center-bZ-bY, R, G, B);
}

final function DrawTube(vector v1, vector v2, int Radius, int Height, int R, int G, int B)
{
	local vector p1, p2, tX, tY, tZ, tocorner1, tocorner2, tocorner3, tocorner4;
	local rotator toend;

	toend = rotator(v2 - v1);
	GetAxes(toend, tX, tY, tZ);

	tocorner1 =  tY*Radius + tZ*Height;
	tocorner2 =  tY*Radius - tZ*Height;
	tocorner3 = -tY*Radius - tZ*Height;
	tocorner4 = -tY*Radius + tZ*Height;

	// Length of box
	DrawLine3D( v1 + tocorner1, v2 + tocorner1, R, G, B);
	DrawLine3D( v1 + tocorner2, v2 + tocorner2, R, G, B);
	DrawLine3D( v1 + tocorner3, v2 + tocorner3, R, G, B);
	DrawLine3D( v1 + tocorner4, v2 + tocorner4, R, G, B);

	// End cap 1
	DrawLine3D( v1+tocorner1, v1+tocorner2, R, G, B);
	DrawLine3D( v1+tocorner2, v1+tocorner3, R, G, B);
	DrawLine3D( v1+tocorner3, v1+tocorner4, R, G, B);
	DrawLine3D( v1+tocorner4, v1+tocorner1, R, G, B);

	// End cap 2
	DrawLine3D( v2+tocorner1, v2+tocorner2, R, G, B);
	DrawLine3D( v2+tocorner2, v2+tocorner3, R, G, B);
	DrawLine3D( v2+tocorner3, v2+tocorner4, R, G, B);
	DrawLine3D( v2+tocorner4, v2+tocorner1, R, G, B);
}

// Color components are of the range 0..255
final function Setcolor(float R, float G, float B)
{
	DrawColor.R = R;
	DrawColor.G = G;
	DrawColor.B = B;
}

defaultproperties
{
     Z=1.000000
     Style=1
     DrawColor=(R=127,G=127,B=127)
     AlphaScale=1.000000
     SmallFont=Font'Engine.SmallFont'
     MedFont=Font'Engine.MedFont'
     BigFont=Font'Engine.Haettenschweiler16'
     LargeFont=Font'Engine.RuneLarge'
     RuneMedFont=Font'Engine.RuneMed'
     CredsFont=Font'Engine.RuneCred'
     ButtonFont=Font'Engine.RuneButton'
}
