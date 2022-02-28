using Pkg
Pkg.activate(".")

using CSV
using DataFrames
using ZED

camera_id = 0
sl_create_camera(camera_id)

init_param = SL_InitParameters(camera_id)
init_param.camera_fps = 60
init_param.resolution = ZED.SL_RESOLUTION_HD720
init_param.input_type = ZED.SL_INPUT_TYPE_SVO
init_param.camera_image_flip = ZED.SL_FLIP_MODE_AUTO
init_param.camera_disable_self_calib = true # set to `true` for repeatability
init_param.enable_image_enhancement = true
init_param.svo_real_time_mode = false
init_param.depth_mode = ZED.SL_DEPTH_MODE_PERFORMANCE
init_param.depth_stabilization = true
init_param.coordinate_unit = ZED.SL_UNIT_MILLIMETER
init_param.coordinate_system = ZED.SL_COORDINATE_SYSTEM_IMAGE
init_param.sdk_gpu_id = -1
init_param.sdk_verbose = false
init_param.sensors_required = false
init_param.enable_right_side_measure = false

path_svo = length(ARGS) < 1 ? "" : ARGS[1]
println("$(pwd())")
println("Path SVO: $(path_svo)")
state = sl_open_camera(camera_id, init_param, path_svo, "", 0, "", "", "")
if state != SL_ERROR_CODE(0)
    error("Error Open Camera $(state), exit program.")
end

# tracking_param = SL_PositionalTrackingParameters(ZED.SL_Quaternion_IM(Cfloat(0),Cfloat(0),Cfloat(0),Cfloat(1)),
#                                                 ZED.SL_Vector3_IM(Cfloat(0), Cfloat(0), Cfloat(0)),
#                                                 true,
#                                                 false,
#                                                 false,
#                                                 false,
#                                                 true)
tracking_param = SL_PositionalTrackingParameters()
tracking_param.enable_area_memory = true
tracking_param.enable_imu_fusion = true
tracking_param.enable_pose_smothing = false
tracking_param.initial_world_position = ZED.SL_Vector3_IM(0, 0, 0)
tracking_param.initial_world_rotation = ZED.SL_Quaternion_IM(0, 0, 0, 1)
tracking_param.set_as_static = false
tracking_param.set_floor_as_origin = false

state = sl_enable_positional_tracking(camera_id, tracking_param, "")
if state != SL_ERROR_CODE(0)
    error("Error Enable Tracking $(state), exit program.")
end

rt_param = SL_RuntimeParameters()
rt_param.enable_depth = true
rt_param.confidence_threshold = 100
rt_param.reference_frame = ZED.SL_REFERENCE_FRAME_CAMERA
rt_param.sensing_mode = ZED.SL_SENSING_MODE_STANDARD
rt_param.texture_confidence_threshold = 100

numframes = sl_get_svo_number_of_frames(camera_id)
@info "SVO contains $(numframes) frames"

width = sl_get_width(camera_id) 
height = sl_get_height(camera_id) 

leftimage_ptr = sl_mat_create_new(width, 
                                  height, 
                                  ZED.SL_MAT_TYPE_U8_C4, 
                                  ZED.SL_MEM_CPU)
rightimage_ptr = sl_mat_create_new(width, 
                                   height, 
                                   ZED.SL_MAT_TYPE_U8_C4, 
                                   ZED.SL_MEM_CPU)
depthimage_ptr = sl_mat_create_new(width, 
                                   height, 
                                   ZED.SL_MAT_TYPE_F32_C4, 
                                   ZED.SL_MEM_CPU)

root = length(ARGS) < 2 ? "." : ARGS[2]
leftimage_dir = joinpath(root, "left")
rightimage_dir = joinpath(root, "right")
depthimage_dir = joinpath(root, "depth")

isdir(leftimage_dir) === false && mkdir(leftimage_dir)
isdir(rightimage_dir) === false && mkdir(rightimage_dir)
isdir(depthimage_dir) === false && mkdir(depthimage_dir)

df = DataFrame(:frame => Int[], 
               :position_x => Cfloat[],
               :position_y => Cfloat[],
               :position_z => Cfloat[],
               :rotation_x => Cfloat[],
               :rotation_y => Cfloat[],
               :rotation_z => Cfloat[],
               :rotation_w => Cfloat[],
               :imu_orientation_x => Cfloat[],
               :imu_orientation_y => Cfloat[],
               :imu_orientation_z => Cfloat[],
               :imu_orientation_w => Cfloat[],
               :imu_acceleration_x => Cfloat[],
               :imu_acceleration_y => Cfloat[],
               :imu_acceleration_z => Cfloat[])

let i = 0
    while (i < numframes)
        # Grab an image
        state = sl_grab(camera_id, rt_param)
        println(state)
        if state == SL_ERROR_CODE(0)

            #pose = Ref(SL_PoseData())
            rotation = Ref(ZED.SL_Quaternion_IM(0,0,0,0))
            position = Ref(ZED.SL_Vector3_IM(0,0,0))
            tracking_state = sl_get_position!(camera_id, rotation, position, ZED.SL_REFERENCE_FRAME_WORLD)
            println(tracking_state)

            translation_x = position[].x
            translation_y = position[].y
            translation_z = position[].z
            rotation_x = rotation[].x
            rotation_y = rotation[].y
            rotation_z = rotation[].z
            rotation_w = rotation[].w

            #tracking_state = sl_get_position_data!(camera_id, pose, ZED.SL_REFERENCE_FRAME_WORLD)

            sensor_data = Ref(SL_SensorData())
            sl_get_sensors_data!(camera_id, sensor_data, ZED.SL_TIME_REFERENCE_IMAGE)

            svo_position = sl_get_svo_position(camera_id)

            filename = lpad("$(svo_position)", 4, "0") * ".png"
            leftimage_path = joinpath(leftimage_dir, filename)
            if !isfile(leftimage_path) 
                sl_retrieve_image(camera_id, 
                                  leftimage_ptr, 
                                  ZED.SL_VIEW_LEFT, 
                                  ZED.SL_MEM_CPU, 
                                  width, 
                                  height)
                leftimage = getframes(leftimage_ptr, ZED.SL_MAT_TYPE_U8_C4)
                savergba(leftimage, leftimage_path)
            end

            rightimage_path = joinpath(rightimage_dir, filename)
            if !isfile(rightimage_path) 
                sl_retrieve_image(camera_id, 
                                  rightimage_ptr, 
                                  ZED.SL_VIEW_RIGHT, 
                                  ZED.SL_MEM_CPU, 
                                  width, 
                                  height)
                rightimage = getframes(rightimage_ptr, ZED.SL_MAT_TYPE_U8_C4)
                savergba(rightimage, rightimage_path)
            end
            
            depthimage_path = joinpath(depthimage_dir, filename)
            if !isfile(depthimage_path)
                sl_retrieve_measure(camera_id, 
                                    depthimage_ptr, 
                                    ZED.SL_MEASURE_DEPTH, 
                                    ZED.SL_MEM_CPU, 
                                    width, 
                                    height)
                depthimage = getframes(depthimage_ptr, ZED.SL_MAT_TYPE_F32_C1)
                savedepth(depthimage, depthimage_path)
            end

            imu_orientation_x = sensor_data[].imu.orientation.x
            imu_orientation_y = sensor_data[].imu.orientation.y
            imu_orientation_z = sensor_data[].imu.orientation.z
            imu_orientation_w = sensor_data[].imu.orientation.w
            imu_acceleration_x = sensor_data[].imu.linear_acceleration.x
            imu_acceleration_y = sensor_data[].imu.linear_acceleration.y
            imu_acceleration_z = sensor_data[].imu.linear_acceleration.z

            row = [i;; translation_x;; translation_y;;
                   translation_z;; rotation_x;; 
                   rotation_y;; rotation_z;; 
                   rotation_w;; imu_orientation_x;;
                   imu_orientation_y;; imu_orientation_z;;
                   imu_orientation_w;; imu_acceleration_x;;
                   imu_acceleration_y;; imu_acceleration_z]
            push!(df, row)

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

CSV.write(joinpath(root, "pose.csv"), df)

sl_close_camera(camera_id)    