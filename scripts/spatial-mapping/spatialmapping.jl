""" 
Tutorial 5

Arguments
- path to the SVO file, default is ""
- path to save the obj file, default is the current directory
"""

using Pkg
Pkg.activate(".")

using ZED

# create a ZED camera
camera_id = 0
sl_create_camera(camera_id)

init_param = SL_InitParameters(camera_id)
init_param.camera_fps = 0
init_param.resolution = ZED.SL_RESOLUTION_HD720
init_param.input_type = length(ARGS) < 1 ? ZED.SL_INPUT_TYPE_USB : ZED.SL_INPUT_TYPE_SVO 
init_param.svo_real_time_mode = length(ARGS) < 2 ? true : false
#init_param.camera_device_id = camera_id
init_param.camera_image_flip = ZED.SL_FLIP_MODE_AUTO 
init_param.camera_disable_self_calib = false
init_param.enable_image_enhancement = true
init_param.depth_mode = ZED.SL_DEPTH_MODE_PERFORMANCE
init_param.depth_stabilization = true
init_param.depth_maximum_distance = 40
init_param.depth_minimum_distance = -1
init_param.coordinate_unit = ZED.SL_UNIT_METER
init_param.coordinate_system = ZED.SL_COORDINATE_SYSTEM_LEFT_HANDED_Y_UP
init_param.sdk_gpu_id = -1
init_param.sdk_verbose = false
init_param.sensors_required = false
init_param.enable_right_side_measure = false

# open the camera
path_svo = length(ARGS) < 1 ? "" : ARGS[1]
println("$(pwd())")
println("Path SVO: $(path_svo)")
state = sl_open_camera(camera_id, init_param, path_svo, "", 0, "", "", "")
if state != SL_ERROR_CODE(0)
    println("Error Open Camera $(state), exit program.")
    return 1
end

tracking_param = SL_PositionalTrackingParameters()
tracking_param.enable_area_memory = true
tracking_param.enable_imu_fusion = true
tracking_param.enable_pose_smothing = false
tracking_param.initial_world_position = ZED.SL_Vector3(0, 0, 0)
tracking_param.initial_world_rotation = ZED.SL_Quaternion(0, 0, 0, 1)
tracking_param.set_as_static = false
tracking_param.set_floor_as_origin = false

state = sl_enable_positional_tracking(camera_id, tracking_param, "")
if state != SL_ERROR_CODE(0)
    println("Error Enable Tracking $(state), exit program.")
    return 1
end

mapping_param = SL_SpatialMappingParameters()
mapping_param.map_type = ZED.SL_SPATIAL_MAP_TYPE_MESH;
mapping_param.max_memory_usage = 2048
mapping_param.range_meter = Cfloat(0)
mapping_param.resolution_meter = Cfloat(0.05)
mapping_param.save_texture = true
mapping_param.use_chunk_only = true
mapping_param.reverse_vertex_order = false

state = sl_enable_spatial_mapping(camera_id, mapping_param)
if state != SL_ERROR_CODE(0)
    println("Error Spatial Mapping $(state), exit program.")
    return 1
end

rt_param = SL_RuntimeParameters()
rt_param.enable_depth = true
rt_param.confidence_threshold = 100
rt_param.reference_frame = ZED.SL_REFERENCE_FRAME_CAMERA
rt_param.sensing_mode = ZED.SL_SENSING_MODE_STANDARD
rt_param.texture_confidence_threshold = 100

width = sl_get_width(camera_id) 
height = sl_get_height(camera_id)

numframes = length(ARGS) < 1 ? 50 : sl_get_svo_number_of_frames(camera_id)
let i = 1
    while i ≤ numframes
        grab_state = sl_grab(camera_id, rt_param) # Grab an image
        if grab_state == SL_ERROR_CODE(0)
            map_state = sl_get_spatial_mapping_state(camera_id)
            println("\r Images captured: $(i) / $(numframes) \
                    || Spatial mapping state: $(map_state)")
            i += 1
        elseif grab_state == ZED.SL_ERROR_CODE_END_OF_SVOFILE_REACHED
            sl_set_svo_position(camera_id, 0)
            break
        else
            println("Grab ZED : $(grab_state)");
            continue
        end
    end
end


@info "Extracting Mesh..."
# Extract the whole mesh.
sl_extract_whole_spatial_map(camera_id)
# Filter the mesh
MAX_SUBMESH = 1000
s = sizeof(zeros(Cint, MAX_SUBMESH))
nb_vertices = Libc.malloc(s)
nb_triangles = Libc.malloc(s)
nb_updated_submeshes = Libc.malloc(1)
updated_indices = Libc.malloc(s)
nb_vertices_tot = Libc.malloc(1)
nb_triangles_tot = Libc.malloc(1)
sl_filter_mesh(camera_id, 
               ZED.SL_MESH_FILTER_MEDIUM, 
               nb_vertices, 
               nb_triangles, 
               nb_updated_submeshes, 
               updated_indices, 
               nb_vertices_tot, 
               nb_triangles_tot, 
               MAX_SUBMESH)
textures_size = Libc.malloc(1)
sl_apply_texture(camera_id,
                 nb_vertices, 
                 nb_triangles, 
                 nb_updated_submeshes, 
                 updated_indices, 
                 nb_vertices_tot, 
                 nb_triangles_tot,
                 textures_size,
                 MAX_SUBMESH)
# Save the mesh
path_obj = joinpath(length(ARGS) < 2 ? "./" : ARGS[2], "mesh.obj")
@info "Saving Mesh to $(path_obj)..."
sl_save_mesh(camera_id, path_obj, ZED.SL_MESH_FILE_FORMAT_OBJ)

Libc.free(nb_vertices)
Libc.free(nb_triangles)
Libc.free(nb_updated_submeshes)
Libc.free(updated_indices)
Libc.free(nb_vertices_tot)
Libc.free(nb_triangles_tot)
Libc.free(textures_size)
sl_disable_spatial_mapping(camera_id)
sl_disable_positional_tracking(camera_id, "")
sl_close_camera(camera_id)