# Add-on details
bl_info = {
    "name": "RBots NavMesh Add-on",
    "author": "John Savage",
    "version": (0, 0, 1),
    "blender": (4, 0, 0),
    "location": "View3D > Sidebar > RBots NavMesh Tab",
    "description": "Navmesh editor tool for use with RBots Rune package",
    "category": "3D View",
}

import bpy      # Blender Python API
import bmesh    # For adding metadata to mesh edges and faces
import gpu
from gpu_extras.batch import batch_for_shader
import math
from mathutils import Vector
import uuid

RBOTS_NAVMESH_CATEGORY = "RBots NavMesh"
RBOTS_LAYER_NAME_POLYGROUP_ID = "polygroup_id"

# Polygon Groups Bool Property
bpy.types.Scene.RBOTS_show_overlay = bpy.props.BoolProperty(
    name="Polygon Groups",
    description="Toggle the display of polygon groups",
    default=False
)

bpy.types.Scene.RBOTS_show_edge_passability = bpy.props.BoolProperty(
    name="Edge Passability",
    description="Toggle display of which edges are passable or impassable",
    default=False
)

# RBots NavMesh tab class for the 3D View
class RBOTS_PT_NavMeshPanel(bpy.types.Panel):
    bl_label = "NavMesh Tools"              # Panel header text
    bl_idname = "RBOTS_PT_navmesh_panel"    # uid
    bl_space_type = 'VIEW_3D'               # Places this in 3D View
    bl_region_type = 'UI'                   # Places this ins sidebar region
    bl_category = RBOTS_NAVMESH_CATEGORY    # Tab name

    def draw(self, context):
        layout = self.layout
        #layout.operator("rbots.test_operator", text="TestButton") # Push button
        pass

# Polygon Group Panel
class RBOTS_PolyGroupItem(bpy.types.PropertyGroup):
    uid: bpy.props.IntProperty(name="UID", default=0)
    name: bpy.props.StringProperty(name="Group Name", default="New Group")
    color: bpy.props.FloatVectorProperty(
        name="Color",
        subtype='COLOR',
        size=4,
        min=0.0, max=1.0,
        default=(1.0, 0.0, 0.0, 0.5)
    )

class RBOTS_UL_PolyGroupList(bpy.types.UIList):
    def draw_item(self, context, layout, data, item, icon, active_Data, active_propname, index):
        if self.layout_type in {'DEFAULT', 'COMPACT'}:
            row = layout.row()
            row.prop(item, "name", text="", emboss=False, icon='GROUP_VERTEX')
            row.label(text=str(item.uid))
        
        elif self.layout_type in {'GRID'}:
            layout.alignment = 'CENTER'
            layout.label(text="", icon='GROUP_VERTEX')

class RBOTS_PT_PolygonGroupsPanel(bpy.types.Panel):
    bl_label = "Polygon Groups"
    bl_idname = "RBOTS_PT_polygon_groups_panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = RBOTS_NAVMESH_CATEGORY

    def draw(self, context):
        layout = self.layout
        scene = context.scene

        layout.operator("rbots.polygroup_assign", text="Assign to Selection")

        row = layout.row()
        row.template_list(
            "RBOTS_UL_PolyGroupList",
            "rbots_poly_groups",
            scene,
            "rbots_poly_groups",
            scene,
            "rbots_poly_groups_index"
        )

        col = row.column(align=True)
        col.operator("rbots.polygroup_add", icon='ADD', text="")
        col.operator("rbots.polygroup_remove", icon='REMOVE', text="")

        idx = scene.rbots_poly_groups_index
        if 0 <= idx < len(scene.rbots_poly_groups):
            group = scene.rbots_poly_groups[idx]
            layout.prop(group, "color", text="Color")

class RBOTS_OT_PolyGroupAdd(bpy.types.Operator):
    bl_idname = "rbots.polygroup_add"
    bl_label = "Add Polygon Group"

    def execute(self, context):
        scene = context.scene
        item = scene.rbots_poly_groups.add()

        item.uid = uuid.uuid4().int & 0xFFFFFFF

        item.name = f"Group {len(scene.rbots_poly_groups)} uid: {item.uid}"
        scene.rbots_poly_groups_index = len(scene.rbots_poly_groups) - 1
        return {'FINISHED'}

class RBOTS_OT_PolyGroupRemove(bpy.types.Operator):
    bl_idname = "rbots.polygroup_remove"
    bl_label = "Remove Polygon Group"

    @classmethod
    def poll(cls, context):
        return len(context.scene.rbots_poly_groups) > 0
    
    def execute(self, context):
        scene = context.scene
        idx = scene.rbots_poly_groups_index
        if 0 <= idx < len(scene.rbots_poly_groups):
            scene.rbots_poly_groups.remove(idx)
            scene.rbots_poly_groups_index = max(0, idx - 1)
        return {'FINISHED'}

class RBOTS_OT_PolyGroupAssign(bpy.types.Operator):
    bl_idname = "rbots.polygroup_assign"
    bl_label = "Assign PolyGroup"

    def execute(self, context):
        scene = context.scene
        polygroup_index = scene.rbots_poly_groups_index
        #print(f"Assigning {polygroup_index}")
        assign_selection_polygroup_id(polygroup_index)
        return {'FINISHED'}

# Visibility Panel
class RBOTS_PT_NavMeshVisibilityPanel(bpy.types.Panel):
    bl_label = "Visibility"
    bl_idname = "RBOTS_PT_navmeshvisibility_panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = RBOTS_NAVMESH_CATEGORY

    def draw(self, context):
        layout = self.layout
        layout.prop(context.scene, "RBOTS_show_overlay")
        layout.prop(context.scene, "RBOTS_show_edge_passability")
        pass

class RBOTS_OT_TestOperator(bpy.types.Operator):
    bl_idname = "rbots.test_operator"
    bl_label = "Test Operator"

    def execute(self, context):
        print("Test button pressed")
        assign_selection_polygroup_id(1)
        return {'FINISHED'}

def assign_selection_polygroup_id(id):
    obj = bpy.context.active_object
    if obj is None or obj.type != 'MESH' or obj.mode != 'EDIT':
        raise Exception("Must be in Edit Mode with a mesh selected")
    
    bm = bmesh.from_edit_mesh(obj.data)

    polygoup_layer = bm.faces.layers.int.get(RBOTS_LAYER_NAME_POLYGROUP_ID)
    if polygoup_layer is None:
        polygoup_layer = bm.faces.layers.int.new(RBOTS_LAYER_NAME_POLYGROUP_ID)
    
    for face in bm.faces:
        if face.select:
            face[polygoup_layer] = id
    
    bmesh.update_edit_mesh(obj.data)

def draw_callback():
    context = bpy.context
    scene = context.scene

    # Only draw if visibility is checked
    if not scene.RBOTS_show_overlay:
        return

    obj = bpy.context.active_object
    if not obj or obj.type != 'MESH' or obj.mode != 'EDIT':
        return
    
    # Get the polygorup id layer
    bm = bmesh.from_edit_mesh(obj.data)
    polygroup_layer = bm.faces.layers.int.get(RBOTS_LAYER_NAME_POLYGROUP_ID)
    if polygroup_layer is None:
        return

    shader = gpu.shader.from_builtin('UNIFORM_COLOR')
    shader.bind()
    #shader.uniform_float("color", (0.0, 1.0, 0.0, 1.0))

    gpu.state.face_culling_set('BACK')
    gpu.state.depth_test_set('LESS')

    # Draw each even-indexed face with an inset
    epsilon = 1.0
    inset_dist = -2.0
    for face in bm.faces:
        group = scene.rbots_poly_groups[face[polygroup_layer]]

        shader.uniform_float("color", group.color)

        coords = []
        verts = face.verts[:]

        for i, v in enumerate(verts):
            # adjacent vertices (previous and next in the loop)
            v_prev = verts[i - 1].co
            v_curr = v.co
            v_next = verts[(i + 1) % len(verts)].co

            # edge directions
            e0 = (v_curr - v_prev).normalized()
            e1 = (v_next - v_curr).normalized()

            # bisector (pointing inward)
            bisector = (e0 + (-e1)).normalized()

            # angle between edges
            angle = math.acos(max(-1.0, min(1.0, -e0.dot(e1))))

            # scale along bisector so inset distance is constant
            move_len = inset_dist / math.sin(angle / 2.0)
            move = bisector * move_len

            # final position: inset inward + lift slightly (epsilon)
            coords.append(v_curr + move + face.normal * epsilon)

        batch = batch_for_shader(shader, 'TRI_FAN', {"pos": coords})
        batch.draw(shader)
    
    gpu.state.face_culling_set('NONE')
    gpu.state.depth_test_set('NONE')

def register_draw():
    if not hasattr(bpy.types, "RBOTS_draw_handler"):
        bpy.types.RBOTS_draw_handler = bpy.types.SpaceView3D.draw_handler_add(
            draw_callback, (), 'WINDOW', 'POST_VIEW')

def unregister_draw():
    if hasattr(bpy.types, "RBOTS_draw_handler"):
        bpy.types.SpaceView3D.draw_handler_remove(bpy.types.RBOTS_draw_handler, 'WINDOW')
        del bpy.types.RBOTS_draw_handler

# Registration classes
register_classes = [
    RBOTS_PT_NavMeshPanel,
    RBOTS_PT_NavMeshVisibilityPanel,
    RBOTS_PT_PolygonGroupsPanel,
    RBOTS_PolyGroupItem,
    RBOTS_OT_PolyGroupAdd,
    RBOTS_OT_PolyGroupRemove,
    RBOTS_OT_PolyGroupAssign
]

def register():
    print("RBots NavMesh Add-on registered")
    for rcls in register_classes:
        bpy.utils.register_class(rcls)
    bpy.types.Scene.rbots_poly_groups = bpy.props.CollectionProperty(type=RBOTS_PolyGroupItem)
    bpy.types.Scene.rbots_poly_groups_index = bpy.props.IntProperty(default=0)
    #bpy.utils.register_class(RBOTS_PT_NavMeshPanel)
    #bpy.utils.register_class(RBOTS_PT_NavMeshVisibilityPanel)
    #bpy.utils.register_class(RBOTS_OT_TestOperator)

    register_draw()

def unregister():
    print("RBots NavMesh Add-on unregistered")
    for rcls in reversed(register_classes):
        try:
            bpy.utils.unregister_class(rcls)
        except RuntimeError:
            pass
    
    try:
        del bpy.types.Scene.rbots_poly_groups
    except AttributeError:
        pass
    
    try:
        del bpy.types.Scene.rbots_poly_groups_index
    except AttributeError:
        pass

    #bpy.utils.unregister_class(RBOTS_PT_NavMeshPanel)
    #bpy.utils.unregister_class(RBOTS_PT_NavMeshVisibilityPanel)
    #bpy.utils.unregister_class(RBOTS_OT_TestOperator)

    unregister_draw()

if __name__ == "__main__":
    try:
        unregister()
    except:
        pass
    register()