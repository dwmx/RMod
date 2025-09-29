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
var config private Color Color_CellPlayer;
var config private Color Color_CellTriangles;

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

function CopyFloatRGB(out float InSrcRGB[3], out float OutDestRGB[3])
{
	OutDestRGB[0] = InSrcRGB[0];
	OutDestRGB[1] = InSrcRGB[1];
	OutDestRGB[2] = InSrcRGB[2];
}

function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager)
{
	local R_NavMesh NavMesh;
	local R_NavMeshSpatialQuery_GridCache SQG;

	StringManager.AddCategory(DebugCategory);

	SQG = GetSpatialQueryGrid();
	if(SQG == None)
	{	// SQG reference is required
		StringManager.AddWarning(DebugCategory, "Could not retrieve Spatial Query Grid object ref");
	}

	NavMesh = GetNavMesh();
	if(NavMesh == None)
	{	// Only required for triangle drawing, but should always be valid anyways
		StringManager.AddWarning(DebugCategory, "Could not retrieve NavMesh ref");
	}

	if(SQG != None)
	{
		DebugLib.Static.InitializeCanvasForDebugDrawing(C);

		DrawSQG_Bounds(C, StringManager, SQG);		// Draw bounds calculated by the AABB
		DrawSQG_GridCells(C, StringManager, SQG);	// Draw each grid cell

		if(NavMesh != None)
		{
			DrawSQG_PlayerIndexTriangles(C, StringManager, NavMesh, SQG);
		}
	}
	
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
	local int PlayerX, PlayerY;
	local Vector DrawCellLocation;
	local int CellIndexCount, GreatestCellIndexCount;
	local float CellActiveRGB[3], CellInactiveRGB[3], CellPlayerRGB[3];
	local float CellRGB[3];

	StringManager.AddColor(DebugCategory, "Populated Cells", Color_CellActive);
	StringManager.AddColor(DebugCategory, "Unpopulated Cells", Color_CellInactive);
	StringManager.AddColor(DebugCategory, "Player Cell", Color_CellPlayer);

	Utilities.Static.ColorToFloats(Color_CellActive, CellActiveRGB[0], CellActiveRGB[1], CellActiveRGB[2]);
	Utilities.Static.ColorToFloats(Color_CellInactive, CellInactiveRGB[0], CellInactiveRGB[1], CellInactiveRGB[2]);
	Utilities.Static.ColorToFloats(Color_CellPlayer, CellPlayerRGB[0], CellPlayerRGB[1], CellPlayerRGB[2]);

	StringManager.AddBool(DebugCategory, "Had Overflow Error?", SQG.GetHadOverflowError());

	// Get Player loc and bounds to center on Player's Z, clamped to bounds
	PlayerLocation = GetPlayerPawnOwnerLocation();
	SQG.GetBounds(BoundsMin, BoundsMax);

	// Get cell index Player is standing in for special drawing
	SQG.LocationToGrid2DIndex(PlayerLocation, PlayerX, PlayerY);

	// Get cell size for drawing
	CellSize = SQG.GetCellSize();

	// Draw the greatest number of indices contained in one cell
	// This is for monitoring how close we're coming to an array overflow in the IndexCache
	GreatestCellIndexCount = 0;

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

			// Select cell draw color
			if(GridX == PlayerX && GridY == PlayerY)
			{	// Player standing in cell, populated or unpopulated
				CopyFloatRGB(CellPlayerRGB, CellRGB);
				DrawCellLocation.Z += 1.0; // Offset so it draws on top
			}
			else if(IndexCache != None)
			{	// Populated cell
				CopyFloatRGB(CellActiveRGB, CellRGB);
			}
			else
			{	// Unpopulated cell
				CopyFloatRGB(CellInactiveRGB, CellRGB);
			}

			// Draw cell
			CanvasLib.Static.DrawRectXY3D(
					C,
					DrawCellLocation.X, DrawCellLocation.Y,
					DrawCellLocation.X + CellSize, DrawCellLocation.Y + CellSize,
					DrawCellLocation.Z,
					CellRGB);

			// Draw information about the cell
			if(IndexCache != None)
			{
				// Draw the number of indices contained in each cell
				CellIndexCount = IndexCache.GetNumIndices();
				if(CellIndexCount > GreatestCellIndexCount)
				{
					GreatestCellIndexCount = CellIndexCount;
				}

				CanvasLib.Static.DrawTextAtWorldLocation(
					C,
					String(CellIndexCount),
					DrawCellLocation + Vect(1,1,0) * CellSize * 0.5,
					Vect(0.5, 0.5, 0.0));
			}
		}
	}

	StringManager.AddInt(DebugCategory, "Greatest Cell Index Count", GreatestCellIndexCount);
}

function DrawSQG_PlayerIndexTriangles(Canvas C, R_RBotsDebug_StringManager StringManager, R_NavMesh NavMesh, R_NavMeshSpatialQuery_GridCache SQG)
{
	local Vector PlayerLocation;
	local int PlayerX, PlayerY;
	local Vector VLoc[3];
	local R_IndexCache IndexCache;
	local int NumTriangleIndices;
	local int TriangleIndex;
	local int i;
	local float TriangleRGB[3];

	StringManager.AddColor(DebugCategory, "Cell Triangles", Color_CellTriangles);
	Utilities.Static.ColorToFloats(Color_CellTriangles, TriangleRGB[0], TriangleRGB[1], TriangleRGB[2]);

	PlayerLocation = GetPlayerPawnOwnerLocation();
	SQG.LocationToGrid2DIndex(PlayerLocation, PlayerX, PlayerY);
	IndexCache = SQG.GetIndexCacheFrom2DGridIndex(PlayerX, PlayerY);

	StringManager.AddString(DebugCategory, "[" $ PlayerX $ "," $ PlayerY $ "]", "Player Cell Index");

	if(IndexCache == None)
	{
		StringManager.AddInt(DebugCategory, "Player Cell Node Count", 0);
	}
	else
	{
		NumTriangleIndices = IndexCache.GetNumIndices();
		StringManager.AddInt(DebugCategory, "Player Cell Node Count", NumTriangleIndices);

		for(i = 0; i < NumTriangleIndices; ++i)
		{
			TriangleIndex = IndexCache.GetUnchecked(i);
			NavMesh.GetTriangleVertexLocationsUnchecked(TriangleIndex, VLoc);

			DrawTriangle(C, VLoc, TriangleRGB, 0.975, 1.0);
		}
	}
}

function DrawTriangle(Canvas C, Vector VLoc[3], float RGB[3], float Scale, optional float NormalOffset)
{
	local Vector Center;
	local Vector NormalOffsetVec;

	Center = (VLoc[0] + VLoc[1] + VLoc[2]) * (1.0/3.0);
	VLoc[0] = Center + ((VLoc[0] - Center) * Scale);
	VLoc[1] = Center + ((VLoc[1] - Center) * Scale);
	VLoc[2] = Center + ((VLoc[2] - Center) * Scale);

	if(NormalOffset != 0.0)
	{
		NormalOffsetVec = Normal((VLoc[1] - VLoc[0]) Cross (VLoc[2] - VLoc[0])) * NormalOffset;
		VLoc[0] += NormalOffsetVec;
		VLoc[1] += NormalOffsetVec;
		VLoc[2] += NormalOffsetVec;
	}

	CanvasLib.Static.DrawLine3D(C, VLoc[0], VLoc[1], RGB[0], RGB[1], RGB[2]);
	CanvasLib.Static.DrawLine3D(C, VLoc[1], VLoc[2], RGB[0], RGB[1], RGB[2]);
	CanvasLib.Static.DrawLine3D(C, VLoc[2], VLoc[0], RGB[0], RGB[1], RGB[2]);
}

defaultproperties
{
	Color_Bounds=(R=247,G=27,B=255)
	Color_CellActive=(R=8,G=118,B=138)
	Color_CellInactive=(R=129,G=20,B=20)
	Color_CellPlayer=(R=9,G=255,B=0)
	Color_CellTriangles=(R=247,G=27,B=255)
}