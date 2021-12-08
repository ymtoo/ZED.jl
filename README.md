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
### Tutorial 2: Image capture
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
i = 0
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

# open the camera
path_svo = "demo.svo"
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
i = 0
while (i < numframes)
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

        frames[:,:,:,i+1] = getframe(image_ptr, ZED.SL_MAT_TYPE_U8_C4)
        svo_position = get_svo_position(camera_id)
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

### Retrieve
- sl_retrieve_image

