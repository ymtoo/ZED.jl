using Pkg
Pkg.activate(".")

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
            frames[:,:,:,svo_position] = getframes(image_ptr,
                                                   ZED.SL_MAT_TYPE_U8_C4)
            
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