# ZED.jl

This is a Julia wrapper around [zed-c-api](https://github.com/stereolabs/zed-c-api) for the [ZED SDK](https://www.stereolabs.com/developers/release/).

## Installation
### Prerequisites
- You must have zed-c-api installed. (See the [build & install instructions](https://github.com/stereolabs/zed-c-api#installing-the-c-api))
- Supported OS: Linux

## Usage
### Tutorial 2: Image capture
```julia
using ZED

# open camera 
camera_id = 0
sl_create_camera(camera_id)

init_param = SL_InitParameters(camera_id)
init_param.depth_maximum_distance = 40
init_param.depth_minimum_distance = -1
init_param.coordinate_unit = ZED.SL_UNIT_METER

state = sl_open_camera(camera_id, init_param, "", "", 0, "", "", "")
if state != 0
    println("Error Open")
    return 1
end

rt_param = SL_RuntimeParameters()

width = sl_get_width(camera_id) # 1920
height = sl_get_height(camera_id) # 1080

image_ptr = sl_mat_create_new(width, height, ZED.SL_MAT_TYPE_U8_C4, ZED.SL_MEM_CPU)

# Capture 50 frames and stop
i = 0
while (i < 50)
	# Grab an image
	state = sl_grab(camera_id, rt_param)
    if state == SL_ERROR_CODE(0)
	    # Get the left image
	    sl_retrieve_image(camera_id, image_ptr, ZED.SL_VIEW_LEFT, ZED.SL_MEM_CPU, width, height)
        println("Image resolution: $(sl_mat_get_width(image_ptr)) x $(sl_mat_get_height(image_ptr)) || $(sl_get_current_timestamp(camera_id))")
        i += 1
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

