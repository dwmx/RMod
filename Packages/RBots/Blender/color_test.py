import bpy
import bmesh
import gpu
from gpu_extras.batch import batch_for_shader
import math
from mathutils import Vector

def draw_callback():
    obj = bpy.context.active_object
    if not obj or obj.type != 'MESH' or obj.mode != 'EDIT':
        return

    bm = bmesh.from_edit_mesh(obj.data)
    region = bpy.context.region
    rv3d = bpy.context.region_data
    cam_dir = rv3d.view_rotation @ Vector((0.0, 0.0, -1.0))  # camera forward

    # --- Draw polygons ---
    shader = gpu.shader.from_builtin('UNIFORM_COLOR')
    shader.bind()
    shader.uniform_float("color", (0.0, 1.0, 0.0, 1.0))
    gpu.state.face_culling_set('BACK')
    gpu.state.depth_test_set('LESS')

    epsilon = 1.0
    inset_dist = -2.0
    for face in bm.faces:
        if face.index % 2 == 0:
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
        print("Registered draw handler")

def unregister_draw():
    if hasattr(bpy.types, "RBOTS_draw_handler"):
        bpy.types.SpaceView3D.draw_handler_remove(bpy.types.RBOTS_draw_handler, 'WINDOW')
        del bpy.types.RBOTS_draw_handler
        print("Unregistered draw handler")

if __name__ == "__main__":
    unregister_draw()
    register_draw()