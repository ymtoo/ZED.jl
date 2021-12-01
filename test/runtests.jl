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
    @test instances(SL_DEPTH_MODE) == (ZED.SL_DEPTH_MODE_NONE, ZED.SL_DEPTH_MODE_PERFORMANCE, ZED.SL_DEPTH_MODE_QUALITY, ZED.SL_DEPTH_MODE_ULTRA)
    @test instances(SL_FLIP_MODE) == (ZED.SL_FLIP_MODE_OFF, ZED.SL_FLIP_MODE_ON, ZED.SL_FLIP_MODE_AUTO)

end

@testset "interface" begin

    [@test typeof(sl_find_usb_device(USB_DEVICE(i))) == Bool for i ∈ 0:2]
    @test typeof(sl_get_sdk_version()) == String

end

@testset "mat" begin

    width = 100
    height = 200
    mat_types = [ZED.SL_MAT_TYPE_U8_C1,
                 ZED.SL_MAT_TYPE_U8_C2,
                 ZED.SL_MAT_TYPE_U8_C3,
                 ZED.SL_MAT_TYPE_U8_C4,
                 ZED.SL_MAT_TYPE_F32_C1,
                 ZED.SL_MAT_TYPE_F32_C2,
                 ZED.SL_MAT_TYPE_F32_C3,
                 ZED.SL_MAT_TYPE_F32_C4]
    numchannels = [1,2,3,4,1,2,3,4]
    buffer_types = [Cuchar, Cuchar, Cuchar, Cuchar, Cfloat, Cfloat, Cfloat, Cfloat]
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
    mem = ZED.SL_MEM_CPU
    for (mat_type, numchannel, buffer_type, set_value, get_value) ∈ zip(mat_types, 
                                                                        numchannels, 
                                                                        buffer_types,
                                                                        set_value_functions,
                                                                        get_value_functions)
        image_ptr = sl_mat_create_new(width, height, mat_type, mem)
        @test sl_mat_is_init(image_ptr) === true
        @test sl_mat_get_height(image_ptr) == height
        @test sl_mat_get_channels(image_ptr) == numchannel
        @test sl_mat_get_memory_type(image_ptr) == mem

        col = rand(1:width)
        row = rand(1:height)
        value = if buffer_type == Cuchar
            [buffer_type(rand(1:100)) for _ ∈ 1:numchannel]
        else
            [buffer_type(randn()) for _ ∈ 1:numchannel]
        end
        set_value(image_ptr, col, row, value, mem)
        @test get_value(image_ptr, col, row, mem) == value

        sl_mat_free(image_ptr, mem)
        @test sl_mat_is_init(image_ptr) === false
    end

   
    


end