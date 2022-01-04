export sl_find_usb_device, sl_create_camera, sl_close_camera, sl_open_camera, sl_is_opened,
    sl_get_sdk_version, sl_get_camera_firmware, sl_grab, sl_enable_recording,
    sl_disable_recording, sl_pause_recording, sl_enable_positional_tracking, 
    sl_disable_positional_tracking, sl_get_svo_position, sl_set_svo_position

export sl_get_width, sl_get_height, sl_get_current_timestamp, sl_get_svo_number_of_frames

export sl_enable_spatial_mapping, sl_disable_spatial_mapping, sl_get_spatial_mapping_state,
    sl_extract_whole_spatial_map, sl_save_mesh, sl_filter_mesh

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
- opt\\_settings\\_path : optional settings path. Equivalent to `InitParameters::optional_settings_path`.
- opencv\\_calib\\_path : optional openCV calibration file. Equivalent to `InitParameters::optional_opencv_calibration_file`.

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

"""
Creates a file for recording the ZED's output into a .SVO or .AVI video.
An SVO is Stereolabs' own format designed for the ZED. It holds the video 
feed with timestamps as well as info about the camera used to record it.

# Arguments
- camera_id : id of the camera instance.
- filename : filename of the SVO file.
- compression\\_mode : compression mode. Can be one for the `SL_SVO_COMPRESSION_MODE` enum.
- bitrate : overrides default bitrate of the SVO file, in KBits/s. Only works if `SVO_COMPRESSION_MODE` is H264 or H265.
- target_fps : defines the target framerate for the recording module.
- transcode : in case of streaming input, if set to false, it will avoid decoding/re-encoding and convert directly streaming input to a SVO file.
              This saves a encoding session and can be especially useful on NVIDIA Geforce cards where the number of encoding session is limited.

# Returns
- an ERROR_CODE that defines if SVO file was successfully created and can be filled with images.
"""
function sl_enable_recording(camera_id::T, 
                             filename::AbstractString, 
                             compression_mode::SL_SVO_COMPRESSION_MODE, 
                             bitrate::T, 
                             target_fps::T, 
                             transcode::Bool) where {T<:Integer}
    err = ccall((:sl_enable_recording, zed), 
                Cint, 
                (Cint, Cstring, Cuint, Cuint, Cint, Cuchar), 
                Cint(camera_id), filename, compression_mode, Cuint(bitrate), 
                target_fps, transcode)
    SL_ERROR_CODE(err)
end

"""
Disables the recording initiated by `sl_enable_recording()` and closes the generated file.

# Arguments
- camera_id : id of the camera instance.
"""
function sl_disable_recording(camera_id::T) where {T<:Integer}
    ccall((:sl_disable_recording, zed), Cvoid, (Cint,), Cint(camera_id))
end

"""
Pauses or resumes the recording.

# Arguments
- camera_id : id of the camera instance.
- status : if true, the recording is paused. If false, the recording is resumed.
"""
function sl_pause_recording(camera_id::T, status::Bool) where {T<:Integer}    
    ccall((:sl_pause_recording, zed), Cvoid, (Cint, Cuchar), Cint(camera_id), status)
end

"""
Initializes and starts the positional tracking processes.
This function allows you to enable the position estimation of the SDK. It only has to be called once in the camera's lifetime.

# Arguments
- camera_id : id of the camera instance.
- tracking_param : positional tracking parameters.
- area_file_path : area localization file that describes the surroundings, saved from a previous tracking session.

# Returns
SL_ERROR_CODE::SUCCESS if everything went fine, ERROR_CODE::FAILURE otherwise.
"""
function sl_enable_positional_tracking(camera_id::T, 
                                       tracking_param::SL_PositionalTrackingParameters, 
                                       area_file_path::String) where {T<:Integer} 
    err = ccall((:sl_enable_positional_tracking, zed), 
                Cint, 
                (Cint, Ref{SL_PositionalTrackingParameters}, Cstring), 
                camera_id, tracking_param, area_file_path)
    SL_ERROR_CODE(err)
end

"""
Disables the positional tracking.

# Arguments
- camera_id : id of the camera instance.
- area_file_path : if set, saves the spatial memory into an '.area' file.
"""
function sl_disable_positional_tracking(camera_id::T, area_file_path::String) where {T<:Integer} 
    ccall((:sl_disable_positional_tracking, zed), Cvoid, (Cint, Cstring), camera_id, area_file_path)
end

"""
Gets the current position of the SVO being recorded to.

# Arguments
- camera_id : id of the camera instance.

# Returns
The current SVO position;
"""
function sl_get_svo_position(camera_id::T) where {T<:Integer}
    ccall((:sl_get_svo_position, zed), Cint, (Cint,), camera_id)
end

"""
Sets the playback cursor to the desired frame number in the SVO file.
This function allows you to move around within a played-back SVO file. After calling, the next call to grab() will read the provided frame number.

# Arguments
- camera_id : id of the camera instance.
- frame_number : the number of the deired frame to be decoded.
"""
function sl_set_svo_position(camera_id::T, frame_number::T) where {T<:Integer}
    numframes = sl_get_svo_number_of_frames(camera_id)
    frame_number > numframes && @warn "`frame_number` is greater than total number of frames"
    ccall((:sl_set_svo_position, zed), Cvoid, (Cint, Cint), camera_id, frame_number)
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
- indatetime : if false, timestamp is in integer, else in datetime.

# Return
- the Camera timestamp.
"""
function sl_get_current_timestamp(camera_id::T; indatetime=false) where {T<:Integer}
    ts = ccall((:sl_get_current_timestamp, zed), Culonglong, (Cint,), Cint(camera_id))
    x = Int128(ts)
    indatetime ? nanounix2datetime(x) : x
end

"""
Gets the total number of frames in the loaded SVO file.

# Arguments
- camera_id : id of the camera instance.

# Return
- the total number of frames in the SVO file (-1 if the SDK is not reading a SVO).
"""
function sl_get_svo_number_of_frames(camera_id::T) where {T<:Integer}
    ccall((:sl_get_svo_number_of_frames, zed), Cint, (Cint,), camera_id)
end

"""
Sets a value in the ZED's camera settings.

# Arguments
- camera_id : id of the camera instance.
- mode : Setting to be changed
- value : new value
"""
function sl_set_camera_settings(camera_id::T, mode::SL_VIDEO_SETTINGS, value::T) where {T<:Integer}

end

############################# Spatial Mapping #####################################################


"""
Initializes and begins the spatial mapping processes.

# Arguments
- camera_id : id of the camera instance.
- type : Spatial mapping type (see \ref SL_SPATIAL_MAP_TYPE).

# Returns
SUCCESS if everything went fine, ERROR_CODE::FAILURE otherwise.
"""
function sl_enable_spatial_mapping(camera_id::T, mapping_param::SL_SpatialMappingParameters) where {T<:Integer}
    err = ccall((:sl_enable_spatial_mapping, zed),
                Cint,
                (Cint, Ref{SL_SpatialMappingParameters}),
                camera_id, mapping_param)
    SL_ERROR_CODE(err)
end

"""
Disables the Spatial Mapping process.

# Arguments
- camera_id : id of the camera instance.
"""
function sl_disable_spatial_mapping(camera_id::T) where {T<:Integer}
    ccall((:sl_disable_spatial_mapping, zed), Cvoid, (Cint,), camera_id)
end

"""
Gets the current state of spatial mapping.

# Arguments
- camera_id : id of the camera instance.

# Returns
The current state (SL_SPATIAL_MAPPING_STATE) of the spatial mapping process
"""
function sl_get_spatial_mapping_state(camera_id::T) where {T<:Integer}
    state = ccall((:sl_get_spatial_mapping_state, zed), 
                  Cint, 
                  (Cint,),
                  camera_id)
    SL_SPATIAL_MAPPING_STATE(state)
end

"""
Extracts the current spatial map from the spatial mapping process.

# Arguments
- camera_id : id of the camera instance.

# Returns 
SUCCESS if the mesh is filled and available, otherwise FAILURE.
"""
function sl_extract_whole_spatial_map(camera_id::T) where {T<:Integer}
    err = ccall((:sl_extract_whole_spatial_map, zed), 
                Cint,
                (Cint,),
                camera_id)
    SL_ERROR_CODE(err)
end

"""
Saves the scanned mesh in a specific file format.
# Arguments
- camera_id : id of the camera instance.
- filename : Path and filename of the mesh.
- format : File format (extension). Can be .obj, .ply or .bin.

# Returns
True if the file was successfully saved, false otherwise.
"""
function sl_save_mesh(camera_id::T, filename::String, format::SL_MESH_FILE_FORMAT) where {T<:Integer}
    ccall((:sl_save_mesh, zed), 
          Bool,
          (Cint, Cstring, Cuint),
          camera_id, filename, format)
end

"""
Filters a mesh to removes triangles while still preserving its overall shaper (though less accurate).

# Arguments
- camera_id : id of the camera instance.
- filter_params : Filter level. Higher settings remore more triangles (SL_MeshFilterParameters::MESH_FILTER).
- nb_ vertices : Array of the number of vertices in each submesh.
- nb_triangles : Array of the number of triangles in each submesh.
- nb_sub_meshes : Number of submeshes.
- updated_indices : List of all submeshes updated since the last update.
- nb_vertices_tot :  Total number of updated vertices in all submeshes.
- nb_triangles_tot : Array of the number of triangles in each submesh.
- max_submesh : Maximum number of submeshes that can be handled.

# Returns
True if the filtering was successful, false otherwise.
"""
function sl_filter_mesh(camera_id::T, 
                        filter_params::SL_MESH_FILTER, 
                        nb_vertices::T, 
                        nb_triangles::T, 
                        nb_updated_submeshes::T, 
                        updated_indices::T, 
                        nb_vertices_tot::T, 
                        nb_triangles_tot::T, 
                        max_submesh::T) where {T<:Integer}
    nb_vertices1 = Libc.malloc(nb_vertices)
    nb_triangles1 = Libc.malloc(nb_triangles)
    nb_updated_submeshes1 = Libc.malloc(nb_updated_submeshes)
    updated_indices1 = Libc.malloc(updated_indices)
    nb_vertices_tot1 = Libc.malloc(nb_vertices_tot)
    nb_triangles_tot1 = Libc.malloc(nb_triangles_tot)
    state = ccall((:sl_filter_mesh, zed),
                  Bool,
                  (Cint, Cuint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Cint),
                  camera_id, filter_params, nb_vertices1, nb_triangles1, nb_updated_submeshes1, updated_indices1, nb_vertices_tot1, nb_triangles_tot1, max_submesh)
    Libc.free(nb_vertices1)
    Libc.free(nb_triangles1)
    Libc.free(nb_updated_submeshes1)
    Libc.free(updated_indices1)
    Libc.free(nb_vertices_tot1)
    Libc.free(nb_triangles_tot1)
    state
end