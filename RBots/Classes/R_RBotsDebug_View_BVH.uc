//==============================================================================
//	R_RBotsDebug_View_BVH
//	Debug View for NavMeshBVH
//==============================================================================
class R_RBotsDebug_View_BVH extends R_RBotsDebug_View;

const Utilities = Class'RBots.R_BotUtilities';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const DebugBVHCategory = 'BVH';

var private Color BoundsColor;

simulated function DrawDebugView(Canvas C, R_RBotsDebug_StringManager StringManager)
{
	local R_NavMesh NavMesh;
	local R_NavMeshBVH BVH;

	StringManager.AddString(DebugBVHCategory, "Yes the BVH view is working");

	NavMesh = GetNavMesh();
	if(NavMesh != None)
	{
		BVH = NavMesh.GetNavMeshBVH();
		if(BVH != None)
		{
			DrawNavMeshBVH(C, StringManager, BVH);
		}
	}
}

simulated function DrawNavMeshBVH(Canvas C, R_RBotsDebug_StringManager StringManager, R_NavMeshBVH BVH)
{
	local Vector BoundsMin, BoundsMax;
	local float RGB[3];

	StringManager.AddColor(DebugBVHCategory, "Bounds", BoundsColor);

	Utilities.Static.ColorToFloats(BoundsColor, RGB[0], RGB[1], RGB[2]);

	BVH.GetBounds(BoundsMin, BoundsMax);
	CanvasLib.Static.DrawAABB3D(C, BoundsMin, BoundsMax, RGB);
}

defaultproperties
{
	BoundsColor=(R=255,G=26,B=255)
}