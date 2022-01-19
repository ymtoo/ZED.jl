using Pkg
Pkg.activate(".")

using ZED

camera_id = 0
sl_create_camera(camera_id)

init_param = SL_InitParameters(camera_id)
init_param.input_type = ZED.SL_INPUT_TYPE_SVO
init_param.svo_real_time_mode = false
init_param.coordinate_unit = ZED.SL_UNIT_MILLIMETER
init_param.depth_mode = ZED.SL_DEPTH_MODE_ULTRA

path_svo = length(ARGS) < 1 ? "" : ARGS[1]
println("$(pwd())")
println("Path SVO: $(path_svo)")
state = sl_open_camera(camera_id, init_param, path_svo, "", 0, "", "", "")
if state != SL_ERROR_CODE(0)
    println("Error Open Camera $(state), exit program.")
    return 1
end

rt_param = SL_RuntimeParameters()
#rt_param.sensing_mode = ZED.SL_SENSING_MODE_FILL

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
                                   ZED.SL_MEM_CPU);

root = length(ARGS) < 2 ? "." : ARGS[2]
leftimage_dir = joinpath(root, "left")
rightimage_dir = joinpath(root, "right")
depthimage_dir = joinpath(root, "depth")

isdir(leftimage_dir) === false && mkdir(leftimage_dir)
isdir(rightimage_dir) === false && mkdir(rightimage_dir)
isdir(depthimage_dir) === false && mkdir(depthimage_dir)

let i = 0
    while (i < numframes)
        # Grab an image
        state = sl_grab(camera_id, rt_param)
        println(state)
        if state == SL_ERROR_CODE(0)
    	    # Get the left image
            sl_retrieve_image(camera_id, 
                              leftimage_ptr, 
                              ZED.SL_VIEW_LEFT, 
                              ZED.SL_MEM_CPU, 
                              width, 
                              height)
            sl_retrieve_image(camera_id, 
                              rightimage_ptr, 
                              ZED.SL_VIEW_RIGHT, 
                              ZED.SL_MEM_CPU, 
                              width, 
                              height)
            sl_retrieve_measure(camera_id, 
                                depthimage_ptr, 
                                ZED.SL_MEASURE_DEPTH, 
                                ZED.SL_MEM_CPU, 
                                width, 
                                height);

            svo_position = sl_get_svo_position(camera_id)
            leftimage = getframes(leftimage_ptr, ZED.SL_MAT_TYPE_U8_C4)
            rightimage = getframes(rightimage_ptr, ZED.SL_MAT_TYPE_U8_C4)
            depthimage = getframes(depthimage_ptr, ZED.SL_MAT_TYPE_F32_C1)

            filename = lpad("$(i)", 4, "0")
            leftimage_path = joinpath(leftimage_dir, "$(filename).png")
            savergba(leftimage, leftimage_path)
            rightimage_path = joinpath(rightimage_dir, "$(filename).png")
            savergba(rightimage, rightimage_path)
            depthimage_path = joinpath(depthimage_dir, "$(filename).png")
            savedepth(depthimage, depthimage_path)

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

    