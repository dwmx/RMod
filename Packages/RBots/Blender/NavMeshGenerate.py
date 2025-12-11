import bpy
import bmesh

SCALE = 1.0

# Make sure we are in object mode
if bpy.context.object.mode != 'OBJECT':
    bpy.ops.object.mode_set(mode='OBJECT')

obj = bpy.context.active_object
mesh = obj.data

# Apply transforms
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# Load mesh into bmesh (no auto triangulation!)
bm = bmesh.new()
bm.from_mesh(mesh)

bm.verts.ensure_lookup_table()
bm.faces.ensure_lookup_table()

# Get world-space vertices
vertex_list = []
for v in bm.verts:
    co = obj.matrix_world @ v.co
    vertex_list.append((co.x * SCALE, co.y * SCALE, co.z * SCALE))

print("function BuildNavMesh()")
print("{")

# Output vertices
for v in vertex_list:
    print(f"    NavMesh.PushVertex(Vect({v[0]:.6f},{v[1]:.6f},{v[2]:.6f}));")

# Output triangles while preserving manual topology
for f in bm.faces:
    verts = [v.index for v in f.verts]
    if len(verts) == 3:
        # Already a triangle
        print(f"    NavMesh.PushTriangle({verts[0]}, {verts[1]}, {verts[2]});")
    elif len(verts) > 3:
        # Manual fan triangulation to preserve your vertex order
        for i in range(1, len(verts) - 1):
            print(f"    NavMesh.PushTriangle({verts[0]}, {verts[i]}, {verts[i+1]});")

print("}")

bm.free()