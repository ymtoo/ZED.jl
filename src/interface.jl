export sl_find_usb_device, sl_create_camera, sl_close_camera, sl_open_camera, sl_is_opened,
    sl_get_sdk_version, sl_get_camera_firmware, sl_grab

export sl_get_width, sl_get_height, sl_get_current_timestamp

############################# Utility Functions ###################################################

"""
Forces unload of all instances.
"""
function sl_unload_all_instances()
    ccall((:sl_unload_all_instances, zed), Cvoid, ())
end

"""
Checks usb devices connected.

# Arguments
- device : type of device to find.

# Returns: 
- `true` if connected.
"""
function sl_find_usb_device(device::USB_DEVICE)
    ccall((:sl_find_usb_device, zed), Bool, (USB_DEVICE,), device)
end

"""
Creates a camera with resolution mode, fps and id for linux.

# Arguments
- camera_id : id of the camera to be added.
- verbose : enable verbose mode.

# Returns
- `true` if the camera has been created successfully.
"""
function sl_create_camera(camera_id::T) where {T<:Integer} 
    ccall((:sl_create_camera, zed), Bool, (Cint,), Cint(camera_id))
end

"""
Destroys the camera and disable the textures.

# Arguments
- camera_id: id of the camera instance.
"""
function sl_close_camera(camera_id::T) where {T<:Integer}
    ccall((:sl_close_camera, zed), Cvoid, (Cint,), camera_id)
end

"""
Opens the camera depending on the init parameters.

# Arguments
- camera_id : id of the camera.
- init_param : structure containing all the initial parameters.
- path_svo : filename of the svo (for SVO input).
- ip : ip of the camera to open (for Stream input).
- stream_port : port of the camera to open (for Stream input).
- output_file : sdk verbose log file. Redirect the SDK verbose message to file.
- opt_settings_path : optional settings path. Equivalent to `InitParameters::optional_settings_path`.
- opencv_calib_path : optional openCV calibration file. Equivalent to `InitParameters::optional_opencv_calibration_file`.

# Returns
- an error code giving information about the internal process. If SUCCESS (0) is returned, the camera is ready to use. 
Every other code indicates an error and the program should be stopped.
"""
function sl_open_camera(camera_id::T, 
                        init_param::SL_InitParameters, 
                        path_svo::ST,
                        ip::ST,
                        stream_port::T,
                        output_file::ST,
                        opt_settings_path::ST,
                        opencv_calib_path::ST) where {T<:Integer,ST<:AbstractString}
    err = ccall((:sl_open_camera, zed), 
                Cint, 
                (Cint, Ref{SL_InitParameters}, Cstring, Cstring, Cint, Cstring, Cstring, Cstring), 
                Cint(camera_id), Ref(init_param), path_svo, ip, Cint(stream_port), output_file, opt_settings_path, opencv_calib_path)
    SL_ERROR_CODE(err)
end

"""
Reports if the camera has been successfully opened.

# Arguments
- camera_id : id of the camera.

# Returns
- `true` if the ZED is already setup, otherwise `false`.
"""
function sl_is_opened(camera_id::T) where {T<:Integer} 
    ccall((:sl_is_opened, zed), Bool, (Cint,), Cint(camera_id))
end

"""
Returns the version of the currently installed ZED SDK.

# Returns
- the ZED SDK version installed.
"""
function sl_get_sdk_version()
    ver = ccall((:sl_get_sdk_version, zed), Cstring, ())
    unsafe_string(ver)
end

"""
Gets the ZED camera Current Firmware version.

# Arguments
- camera_id : id of the camera instance.

# Returns
- the firmware of the camera.
"""
function sl_get_camera_firmware(camera_id::T) where {T<:Integer} 
    ccall((:sl_get_camera_firmware, zed), Cint, (Cint,), camera_id)
end

"""
Grabs the lastest images from the camera.

# Arguments
- camera_id : id of the camera instance.
- runtime : structure containing all the runtime parameters.

# Returns
- an error code giving information about the internal process."SUCCESS" if the method succeeded.
"""
function sl_grab(camera_id::T, rt_param::SL_RuntimeParameters) where {T<:Integer}
    err = ccall((:sl_grab, zed), 
                Cint, 
                (Cint, Ref{SL_RuntimeParameters}), 
                Cint(camera_id), Ref(rt_param))
    SL_ERROR_CODE(err)
end


############################# Camera ##############################################################

"""
Returns the width of the current image.

# Arguments
- camera_id : id of the camera instance.

# Returns
- width of the image.
"""
function sl_get_width(camera_id::T) where {T<:Integer}
    ccall((:sl_get_width, zed), Cint, (Cint,), camera_id)
end

"""
Returns the height of the current image.

# Arguments
- camera_id : id of the camera instance.

# Returns
- height of the image.
"""
function sl_get_height(camera_id::T) where {T<:Integer}
    ccall((:sl_get_height, zed), Cint, (Cint,), camera_id)
end

"""
Get the Timestamp at the time the frame has been extracted from USB stream. (should be called after a grab).

# Arguments
- camera_id : id of the camera instance.

# Return
- the Camera timestamp.
"""
function sl_get_current_timestamp(camera_id::T) where {T<:Integer}
    ccall((:sl_get_current_timestamp, zed), Culonglong, (Cint,), Cint(camera_id))
end