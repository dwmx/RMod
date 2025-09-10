import bpy

class RBOTS_PolyGroupItem(bpy.types.PropertyGroup):
    name: bpy.props.StringProperty(name="Group Name", default="New Group")

class RBOTS_PT_PolygonGroups(bpy.types.Panel):
    bl_label = "Polygon Groups"
    bl_idname = "RBOTS_PT_polygon_groups"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "RBots NavMesh"

    def draw(self, context):
        layout = self.layout
        scene = context.scene

        row = layout.row()
        row.template_list(
            "UI_UL_list",
            "rbots_poly_groups",
            scene,
            "rbots_poly_groups",
            scene,
            "rbots_poly_groups_index"
        )

        layout.operator("rbots.polygroup_add", text="Add Group")

class RBOTS_OT_PolyGroupAdd(bpy.types.Operator):
    bl_idname = "rbots.polygroup_add"
    bl_label = "Add Polygon Group"

    def execute(self, context):
        scene = context.scene
        item = scene.rbots_poly_groups.add()
        item.name = f"Group {len(scene.rbots_poly_groups)}"
        scene.rbots_poly_groups_index = len(scene.rbots_poly_groups) - 1
        return {'FINISHED'}

classes = [RBOTS_PolyGroupItem, RBOTS_PT_PolygonGroups, RBOTS_OT_PolyGroupAdd]

def register():
    for cls in classes:
        bpy.utils.register_class(cls)
    bpy.types.Scene.rbots_poly_groups = bpy.props.CollectionProperty(type=RBOTS_PolyGroupItem)
    bpy.types.Scene.rbots_poly_groups_index = bpy.props.IntProperty(default=0)
    print("Registered")
    pass

def unregister():
    for cls in reversed(classes):
        try:
            bpy.utils.unregister_class(cls)
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

    print("Unregistered")
    pass

if __name__ == "__main__":
    unregister()
    register()