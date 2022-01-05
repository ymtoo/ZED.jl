# ZED.jl

This is a Julia wrapper around [zed-c-api](https://github.com/stereolabs/zed-c-api) for the [ZED SDK](https://www.stereolabs.com/developers/release/).

## Prerequisites
- ZED SDK 3.6
- zed-c-api (See the [build & install instructions](https://github.com/stereolabs/zed-c-api#installing-the-c-api))
- Supported OS: Linux

## Installation
```julia-repl
julia>]
pkg> add https://github.com/ymtoo/ZED.jl
```

## Usage
### Tutorial 2: image capture
```julia
using ZED

# create a ZED camera
camera_id = 0
sl_create_camera(camera_id)

init_param = SL_InitParameters(camera_id)
init_param.resolution = ZED.SL_RESOLUTION_HD720
init_param.depth_maximum_distance = 40
init_param.depth_minimum_distance = -1
init_param.coordinate_unit = ZED.SL_UNIT_METER

# open the camera
state = sl_open_camera(camera_id, init_param, "", "", 0, "", "", "")
if state != SL_ERROR_CODE(0)
    println("Error Open")
    return 1
end

rt_param = SL_RuntimeParameters()

width = sl_get_width(camera_id) 
height = sl_get_height(camera_id) 

image_ptr = sl_mat_create_new(width, 
                              height, 
                              ZED.SL_MAT_TYPE_U8_C4, 
                              ZED.SL_MEM_CPU)

# Capture 50 frames and stop
let i = 0
    while (i < 50)
        # Grab an image
        state = sl_grab(camera_id, rt_param)
        if state == SL_ERROR_CODE(0)
    	    # Get the left image
            sl_retrieve_image(camera_id, 
                              image_ptr, 
                              ZED.SL_VIEW_LEFT, 
                              ZED.SL_MEM_CPU, 
                              width, 
                              height)
            w = sl_mat_get_width(image_ptr)
            h = sl_mat_get_height(image_ptr)
            timestamp = sl_get_current_timestamp(camera_id; indatetime=true)
            println("Image resolution: $(h) x $(w) || $(timestamp)")
            i += 1
        end
    end
end

sl_close_camera(camera_id)
```

### Tutorial 5: spatial mapping
```julia
using ZED

# create a ZED camera
camera_id = 0
sl_create_camera(camera_id)

init_param = SL_InitParameters(camera_id)
init_param.camera_fps = 30
init_param.resolution = ZED.SL_RESOLUTION_HD1080
init_param.input_type = ZED.SL_INPUT_TYPE_USB
#init_param.camera_device_id = camera_id
init_param.camera_image_flip = ZED.SL_FLIP_MODE_AUTO 
init_param.camera_disable_self_calib = false
init_param.enable_image_enhancement = true
init_param.svo_real_time_mode = true
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
state = sl_open_camera(camera_id, init_param, "", "", 0, "", "", "")
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

let i = 1
    while i ≤ 50
        grab_state = sl_grab(camera_id, rt_param) # Grab an image
        if grab_state == SL_ERROR_CODE(0)
            map_state = sl_get_spatial_mapping_state(camera_id)
            println("\r Images captured: $(i) / 50 \
                    || Spatial mapping state: $(map_state)")
            i += 1
        end
    end
end

@info "Extracting Mesh..."
# Extract the whole mesh.
sl_extract_whole_spatial_map(camera_id)
# Filter the mesh
MAX_SUBMESH = 1000
nb_vertices = Libc.malloc(MAX_SUBMESH)
nb_triangles = Libc.malloc(MAX_SUBMESH)
nb_updated_submeshes = Libc.malloc(0)
updated_indices = Libc.malloc(MAX_SUBMESH)
nb_vertices_tot = Libc.malloc(0)
nb_triangles_tot = Libc.malloc(0)
sl_filter_mesh(camera_id, 
               ZED.SL_MESH_FILTER_MEDIUM, 
               nb_vertices, 
               nb_triangles, 
               nb_updated_submeshes, 
               updated_indices, 
               nb_vertices_tot, 
               nb_triangles_tot, 
               MAX_SUBMESH)
textures_size = Libc.malloc(0)
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
@info "Saving Mesh ..."
sl_save_mesh(camera_id, "mesh.obj", ZED.SL_MESH_FILE_FORMAT_OBJ)

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
```

### SVO Recording
```julia
using Dates
using ZED

# create a ZED camera
camera_id = 0
sl_create_camera(camera_id)

init_param = SL_InitParameters(camera_id)
init_param.resolution = ZED.SL_RESOLUTION_HD720
init_param.depth_maximum_distance = 40
init_param.depth_minimum_distance = -1
init_param.coordinate_unit = ZED.SL_UNIT_METER

# open the camera
state = sl_open_camera(camera_id, init_param, "", "", 0, "", "", "")
if state != SL_ERROR_CODE(0)
    println("Error Open")
    return 1
end

# enable recording
path_output = "demo.svo" # save to the current directory
compression = ZED.SL_SVO_COMPRESSION_MODE_LOSSLESS
bitrate = 7000
fps = 30
returned_state = sl_enable_recording(camera_id,
                                     path_output,
                                     compression,
                                     bitrate,
                                     fps,
                                     false)

totalrecordtime = Millisecond(30000) # 30 seconds
currenttime = now()
rt_param = SL_RuntimeParameters()
@info "Start recording..."
while now() - currenttime < totalrecordtime
    state = sl_grab(camera_id, rt_param)
    state != SL_ERROR_CODE(0) && break
end

sl_disable_recording(camera_id)
sl_close_camera(camera_id)
```

### SVO Playback
```julia
using ZED

# create a ZED camera
camera_id = 0
sl_create_camera(camera_id)

init_param = SL_InitParameters(camera_id)
init_param.input_type = ZED.SL_INPUT_TYPE_SVO
init_param.svo_real_time_mode = false

# open the camera
path_svo = "./test/data/dummy.svo"
state = sl_open_camera(camera_id, init_param, path_svo, "", 0, "", "", "")
if state != SL_ERROR_CODE(0)
    println("Error Open")
    return 1
end

numframes = sl_get_svo_number_of_frames(camera_id)
@info "SVO contains $(numframes) frames"

rt_param = SL_RuntimeParameters()

width = sl_get_width(camera_id) 
height = sl_get_height(camera_id) 

image_ptr = sl_mat_create_new(width, 
                              height, 
                              ZED.SL_MAT_TYPE_U8_C4, 
                              ZED.SL_MEM_CPU)

frames = zeros(Cuchar, height, width, 4, numframes)
let i = 0
    while (i < numframes)
        # Grab an image
        state = sl_grab(camera_id, rt_param)
        println(state)
        if state == SL_ERROR_CODE(0)
    	    # Get the left image
            sl_retrieve_image(camera_id, 
                              image_ptr, 
                              ZED.SL_VIEW_LEFT, 
                              ZED.SL_MEM_CPU, 
                              width, 
                              height)

            svo_position = sl_get_svo_position(camera_id)
            frames[:,:,:,svo_position] = getframes(image_ptr, ZED.SL_MAT_TYPE_U8_C4)
            
            println("Get frame #$(svo_position).")
            i += 1
        elseif state == ZED.SL_ERROR_CODE_END_OF_SVOFILE_REACHED
            sl_set_svo_position(camera_id, 0)
            break
        else
            println("Grab ZED : $(state)");
            break
        end
    end
end
sl_close_camera(camera_id)
```

## Implemented APIs
### Types
- USB_DEVICE
- SL_ERROR_CODE
- SL_RESOLUTION
- SL_UNIT
- SL_COORDINATE_SYSTEM
- SL_MEM
- SL_INPUT_TYPE
- SL_REFERENCE_FRAME
- SL_VIEW
- SL_SENSING_MODE
- SL_DEPTH_MODE
- SL_FLIP_MODE
- SL_SVO_COMPRESSION_MODE
- SL_MAT_TYPE
- SL_InitParameters
- SL_RuntimeParameters
- SL_PositionalTrackingParameters

### Interface functions
- sl_unload_all_instances
- sl_find_usb_device 
- sl_create_camera  
- sl_close_camera
- sl_open_camera    
- sl_is_opened       
- sl_get_sdk_version 
- sl_get_camera_firmware
- sl_grab
- sl_enable_recording
- sl_disable_recording
- sl_pause_recording
- sl_get_width
- sl_get_height
- sl_get_current_timestamp

### Mat
- sl_mat_create_new  
- sl_mat_is_init
- sl_mat_free
- sl_mat_get_infos
- sl_mat_get_width
- sl_mat_get_height
- sl_mat_get_channels
- sl_mat_get_memory_type
- sl_mat_set_value_uchar
- sl_mat_set_value_uchar2
- sl_mat_set_value_uchar3
- sl_mat_set_value_uchar4
- sl_mat_set_value_float
- sl_mat_set_value_float2
- sl_mat_set_value_float3
- sl_mat_set_value_float4
- sl_mat_get_value_uchar
- sl_mat_get_value_uchar2
- sl_mat_get_value_uchar3
- sl_mat_get_value_uchar4
- sl_mat_get_value_float
- sl_mat_get_value_float2
- sl_mat_get_value_float3
- sl_mat_get_value_float4
- sl_mat_set_to_uchar
- sl_mat_set_to_uchar2
- sl_mat_set_to_uchar3
- sl_mat_set_to_uchar4
- sl_mat_set_to_float
- sl_mat_set_to_float2
- sl_mat_set_to_float3
- sl_mat_set_to_float4

### Retrieve
- sl_retrieve_image

