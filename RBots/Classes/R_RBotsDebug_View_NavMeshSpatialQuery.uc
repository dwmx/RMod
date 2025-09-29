//==============================================================================
//	R_RBotsDebug_View_NavMeshSpatialQuery
//	Debug View for RBots NavMesh Spatial Query structures
//	Mainly meant to draw the grid spatial query
//==============================================================================
class R_RBotsDebug_View_NavMeshSpatialQuery extends R_RBotsDebug_View config(RBotsDebug);

const Utilities = Class'RBots.R_BotUtilities';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const DebugLib = Class'RBots.R_RBots_DebugLibrary';

const DebugCategory = 'SpatialQueryGrid';

var private R_NavMeshSpatialQuery_GridCache SpatialQueryGrid;

var config private Color Color_Bounds;
var config private Color Color_CellActive;
var config private Color Color_CellInactive;

final function R_NavMeshSpatialQuery_GridCache GetSpatialQueryGrid()
{
	local R_NavMesh NavMesh;

	if(SpatialQueryGrid == None)
	{
		NavMesh = GetNavMesh();
		if(NavMesh != None)
		{
			SpatialQueryGrid = R_NavMeshSpatialQuery_GridCache(NavMesh.GetNavMeshSpatialQuery());
		}
	}
	return SpatialQueryGrid;
}

function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager)
{
	local R_NavMeshSpatialQuery_GridCache SQG;

	StringManager.AddCategory(DebugCategory);

	// Require SQG ref
	SQG = GetSpatialQueryGrid();
	if(SQG == None)
	{
		StringManager.AddWarning(DebugCategory, "Could not retrieve Spatial Query Grid object ref");
		return;
	}

	DebugLib.Static.InitializeCanvasForDebugDrawing(C);

	DrawSQG_Bounds(C, StringManager, SQG);		// Draw bounds calculated by the AABB
	DrawSQG_GridCells(C, StringManager, SQG);	// Draw each grid cell
}

function DrawSQG_Bounds(Canvas C, R_RBotsDebug_StringManager StringManager, R_NavMeshSpatialQuery_GridCache SQG)
{
	local Vector BoundsMin, BoundsMax;
	local float BoundsRGB[3];

	StringManager.AddColor(DebugCategory, "Bounds", Color_Bounds);

	Utilities.Static.ColorToFloats(Color_Bounds, BoundsRGB[0], BoundsRGB[1], BoundsRGB[2]);

	SQG.GetBounds(BoundsMin, BoundsMax);

	CanvasLib.Static.DrawAABB3D(C, BoundsMin, BoundsMax, BoundsRGB);
}

function DrawSQG_GridCells(Canvas C, R_RBotsDebug_StringManager StringManager, R_NavMeshSpatialQuery_GridCache SQG)
{
	local Vector BoundsMin, BoundsMax;
	local int GridMaxX, GridMaxY;
	local int GridX, GridY;
	local float CellSize;
	local R_IndexCache IndexCache;
	local Vector PlayerLocation;
	local Vector DrawCellLocation;
	local int CellIndexCount;
	local float CellActiveRGB[3], CellInactiveRGB[3];

	StringManager.AddColor(DebugCategory, "Populated Cells", Color_CellActive);
	StringManager.AddColor(DebugCategory, "Unpopulated Cells", Color_CellInactive);

	Utilities.Static.ColorToFloats(Color_CellActive, CellActiveRGB[0], CellActiveRGB[1], CellActiveRGB[2]);
	Utilities.Static.ColorToFloats(Color_CellInactive, CellInactiveRGB[0], CellInactiveRGB[1], CellInactiveRGB[2]);

	// Get Player loc and bounds to center on Player's Z, clamped to bounds
	PlayerLocation = GetPlayerPawnOwnerLocation();
	SQG.GetBounds(BoundsMin, BoundsMax);

	// Get cell size for drawing
	CellSize = SQG.GetCellSize();

	// Draw each grid cell within the relevant bounds
	SQG.GetMax2DIndexInBounds(GridMaxX, GridMaxY);
	for(GridX = 0; GridX <= GridMaxX; ++GridX)
	{
		for(GridY = 0; GridY <= GridMaxY; ++GridY)
		{
			// Draw the cell at the player's Z, clamped inside of bounds
			SQG.Grid2DIndexToLocation(GridX, GridY, DrawCellLocation);
			DrawCellLocation.Z = FClamp(PlayerLocation.Z, BoundsMin.Z, BoundsMax.Z);

			IndexCache = SQG.GetIndexCacheFrom2DGridIndex(GridX, GridY);
			if(IndexCache != None)
			{	// Draw as populated cell
				CanvasLib.Static.DrawRectXY3D(
					C,
					DrawCellLocation.X, DrawCellLocation.Y,
					DrawCellLocation.X + CellSize, DrawCellLocation.Y + CellSize,
					DrawCellLocation.Z,
					CellActiveRGB);
				
				// Draw the number of indices contained in each cell
				CellIndexCount = IndexCache.GetNumIndices();
				CanvasLib.Static.DrawTextAtWorldLocation(
					C,
					String(CellIndexCount),
					DrawCellLocation + Vect(1,1,0) * CellSize * 0.5,
					Vect(0.5, 0.5, 0.0));
			}
			else
			{	// Draw as unpopulated cell
				CanvasLib.Static.DrawRectXY3D(
					C,
					DrawCellLocation.X, DrawCellLocation.Y,
					DrawCellLocation.X + CellSize, DrawCellLocation.Y + CellSize,
					DrawCellLocation.Z,
					CellInactiveRGB);
			}
		}
	}
}

defaultproperties
{
	Color_Bounds=(R=247,G=27,B=255)
	Color_CellActive=(R=231,G=255,B=14)
	Color_CellInactive=(R=255,G=37,B=37)
}