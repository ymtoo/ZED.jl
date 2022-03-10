using ZED 

using Test

@testset "types" begin

    @test instances(USB_DEVICE) == (ZED.USB_DEVICE_OCULUS, ZED.USB_DEVICE_HTC, ZED.USB_DEVICE_STEREOLABS)
    @test instances(SL_RESOLUTION) == (ZED.SL_RESOLUTION_HD2K, ZED.SL_RESOLUTION_HD1080, ZED.SL_RESOLUTION_HD720, ZED.SL_RESOLUTION_VGA)
    @test instances(SL_UNIT) == (ZED.SL_UNIT_MILLIMETER, ZED.SL_UNIT_CENTIMETER, ZED.SL_UNIT_METER, ZED.SL_UNIT_INCH, ZED.SL_UNIT_FOOT)
    @test instances(SL_COORDINATE_SYSTEM) == (ZED.SL_COORDINATE_SYSTEM_IMAGE, ZED.SL_COORDINATE_SYSTEM_LEFT_HANDED_Y_UP, 
                                              ZED.SL_COORDINATE_SYSTEM_RIGHT_HANDED_Y_UP, ZED.SL_COORDINATE_SYSTEM_RIGHT_HANDED_Z_UP, 
                                              ZED.SL_COORDINATE_SYSTEM_LEFT_HANDED_Z_UP, ZED.SL_COORDINATE_SYSTEM_RIGHT_HANDED_Z_UP_X_FWD)
    @test instances(SL_INPUT_TYPE) == (ZED.SL_INPUT_TYPE_USB, ZED.SL_INPUT_TYPE_SVO, ZED.SL_INPUT_TYPE_STREAM)
    @test instances(SL_DEPTH_MODE) == (ZED.SL_DEPTH_MODE_NONE, ZED.SL_DEPTH_MODE_PERFORMANCE, ZED.SL_DEPTH_MODE_QUALITY, ZED.SL_DEPTH_MODE_ULTRA, ZED.SL_DEPTH_MODE_NEURAL)
    @test instances(SL_FLIP_MODE) == (ZED.SL_FLIP_MODE_OFF, ZED.SL_FLIP_MODE_ON, ZED.SL_FLIP_MODE_AUTO)

end

@testset "interface" begin

    [@test typeof(sl_find_usb_device(USB_DEVICE(i))) == Bool for i ∈ 0:2]
    @test typeof(sl_get_sdk_version()) == String
    
    camera_id = 0
    sl_create_camera(camera_id)

    init_param = SL_InitParameters(camera_id)
    init_param.input_type = ZED.SL_INPUT_TYPE_SVO
    init_param.svo_real_time_mode = false

    path_svo = "./data/dummy.svo"
    state = sl_open_camera(camera_id, init_param, path_svo, "", 0, "", "", "")
    @test state == SL_ERROR_CODE(0)

    numframes = sl_get_svo_number_of_frames(camera_id)
    @test numframes == 33

    rt_param = SL_RuntimeParameters()

    width = sl_get_width(camera_id) 
    height = sl_get_height(camera_id) 
    @test width == 1280
    @test height == 720

    image_ptr = sl_mat_create_new(width, 
                              height, 
                              ZED.SL_MAT_TYPE_U8_C4, 
                              ZED.SL_MEM_CPU)

    svo_position = sl_get_svo_position(camera_id)
    @test svo_position == 0
    frames = zeros(Cuchar, height, width, 4, numframes)
    i = 0
    while (i < numframes)
        # Grab an image
        state = sl_grab(camera_id, rt_param)
        i += 1
        if state == SL_ERROR_CODE(0)
            # Get the left image
            sl_retrieve_image(camera_id, 
                            image_ptr, 
                            ZED.SL_VIEW_LEFT, 
                            ZED.SL_MEM_CPU, 
                            width, 
                            height)

            svo_position = sl_get_svo_position(camera_id)
            @test svo_position == i
            frames[:,:,:,svo_position] = getframe(image_ptr, Cuchar, sl_mat_get_value_uchar4)
        elseif state == ZED.SL_ERROR_CODE_END_OF_SVOFILE_REACHED
            sl_set_svo_position(camera_id, 0)
            svo_position = sl_get_svo_position(camera_id)
            @test svo_position == 0
            break
        else
            break
        end
    end
    sl_close_camera(camera_id)

end

@testset "mat" begin

    width = 10
    height = 20
    mat_types = [ZED.SL_MAT_TYPE_U8_C1,
                 ZED.SL_MAT_TYPE_U8_C2,
                 ZED.SL_MAT_TYPE_U8_C3,
                 ZED.SL_MAT_TYPE_U8_C4,
                 ZED.SL_MAT_TYPE_F32_C1,
                 ZED.SL_MAT_TYPE_F32_C2,
                 ZED.SL_MAT_TYPE_F32_C3,
                 ZED.SL_MAT_TYPE_F32_C4]
    numchannels = [1,2,3,4,1,2,3,4]
    mateltypes = [Cuchar, Cuchar, Cuchar, Cuchar, Cfloat, Cfloat, Cfloat, Cfloat]
    set_value_functions = [sl_mat_set_value_uchar,
                           sl_mat_set_value_uchar2,
                           sl_mat_set_value_uchar3,
                           sl_mat_set_value_uchar4,
                           sl_mat_set_value_float,
                           sl_mat_set_value_float2,
                           sl_mat_set_value_float3,
                           sl_mat_set_value_float4]
    get_value_functions = [sl_mat_get_value_uchar,
                           sl_mat_get_value_uchar2,
                           sl_mat_get_value_uchar3,
                           sl_mat_get_value_uchar4,
                           sl_mat_get_value_float,
                           sl_mat_get_value_float2,
                           sl_mat_get_value_float3,
                           sl_mat_get_value_float4]
    set_to_functions = [sl_mat_set_to_uchar,
                        sl_mat_set_to_uchar2,
                        sl_mat_set_to_uchar3,
                        sl_mat_set_to_uchar4,
                        sl_mat_set_to_float,
                        sl_mat_set_to_float2,
                        sl_mat_set_to_float3,
                        sl_mat_set_to_float4,]
    mem = ZED.SL_MEM_CPU
    for (mat_type, numchannel, mateltype, set_value, get_value, set_to) ∈ zip(mat_types, 
                                                                              numchannels, 
                                                                              mateltypes,
                                                                              set_value_functions,
                                                                              get_value_functions,
                                                                              set_to_functions)
        image_ptr = sl_mat_create_new(width, height, mat_type, mem)
        @test sl_mat_is_init(image_ptr) === true
        @test sl_mat_get_height(image_ptr) == height
        @test sl_mat_get_width(image_ptr) == width
        @test sl_mat_get_channels(image_ptr) == numchannel
        @test sl_mat_get_memory_type(image_ptr) == mem

        zerovalue = [mateltype(0) for _ ∈ 1:numchannel]
        set_to_err = set_to(image_ptr, zerovalue, mem)
        @test set_to_err == ZED.SL_ERROR_CODE_SUCCESS
        frames = getframe(image_ptr, mateltype, get_value)
        X = zeros(mateltype, height, width, numchannel) 
        @test frames == X

        col = rand(1:width)
        row = rand(1:height)
        value = if mateltype == Cuchar
            [mateltype(rand(1:100)) for _ ∈ 1:numchannel]
        else
            [mateltype(randn()) for _ ∈ 1:numchannel]
        end
        set_value(image_ptr, col, row, value, mem)
        @test get_value(image_ptr, col, row, mem) == value

        frames = getframe(image_ptr, mateltype, get_value)
        @test size(frames) == (height, width, numchannel)
        X[row,col,:] = value
        @test frames == X

        sl_mat_free(image_ptr, mem)
        @test sl_mat_is_init(image_ptr) === false
    end

end