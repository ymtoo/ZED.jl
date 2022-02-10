""" 
Tutorial 4

Arguments
- path to the SVO file, default is ""
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
init_param.svo_real_time_mode = length(ARGS) < 1 ? true : false
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
println("Path SVO: $(path_svo)")
state = sl_open_camera(camera_id, init_param, path_svo, "", 0, "", "", "")
if state != SL_ERROR_CODE(0)
    error("Error Open Camera $(state), exit program.")
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

rt_param = SL_RuntimeParameters()
rt_param.enable_depth = true
rt_param.confidence_threshold = 100
rt_param.reference_frame = ZED.SL_REFERENCE_FRAME_CAMERA
rt_param.sensing_mode = ZED.SL_SENSING_MODE_STANDARD
rt_param.texture_confidence_threshold = 100

width = sl_get_width(camera_id) 
height = sl_get_height(camera_id)

sensor_config = sl_get_sensors_configuration(camera_id)
zed_has_imu = sensor_config.gyroscope_parameters.is_available

image_ptr = sl_mat_create_new(width, 
                              height, 
                              ZED.SL_MAT_TYPE_U8_C4, 
                              ZED.SL_MEM_CPU)

numframes = length(ARGS) < 1 ? 50 : sl_get_svo_number_of_frames(camera_id)
let i = 1
    while i ≤ numframes
        grab_state = sl_grab(camera_id, rt_param) # Grab an image
        if grab_state == SL_ERROR_CODE(0)
            pose = Ref(SL_PoseData())
            sl_get_position_data!(camera_id, pose, ZED.SL_REFERENCE_FRAME_WORLD)
            println("Frame: $(i) / $(numframes), \
                    Camera Translation: $(pose[].translation.x), $(pose[].translation.y), $(pose[].translation.z), \
                    Orientation: $(pose[].rotation.x), $(pose[].rotation.y), $(pose[].rotation.z),  $(pose[].rotation.w), \
                    Timestamp: $(pose[].timestamp)")
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

sl_disable_positional_tracking(camera_id, "")
sl_close_camera(camera_id)