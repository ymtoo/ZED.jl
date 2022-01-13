export USB_DEVICE, SL_ERROR_CODE, SL_RESOLUTION, SL_UNIT, SL_COORDINATE_SYSTEM, SL_MEM, 
	SL_INPUT_TYPE, SL_REFERENCE_FRAME, SL_VIDEO_SETTINGS, SL_VIEW, SL_SPATIAL_MAP_TYPE, 
	SL_SPATIAL_MAPPING_STATE, SL_MESH_FILTER, SL_MESH_FILE_FORMAT, SL_SENSING_MODE, 
	SL_DEPTH_MODE, SL_FLIP_MODE, SL_SVO_COMPRESSION_MODE, SL_MAT_TYPE

export SL_InitParameters, SL_RuntimeParameters, SL_PositionalTrackingParameters,
	SL_SpatialMappingParameters 

############################# MAT Types ###########################################################

"""
uchar2
"""
mutable struct SL_Uchar2
    x::Cuchar
    y::Cuchar
end
SL_Uchar2() = SL_Uchar2(Cuchar(0), Cuchar(0))

"""
uchar3
"""
mutable struct SL_Uchar3 
    x::Cuchar
    y::Cuchar
    z::Cuchar
end
SL_Uchar3() = SL_Uchar3(Cuchar(0), Cuchar(0), Cuchar(0))

"""
uchar4
"""
mutable struct SL_Uchar4
    x::Cuchar
    y::Cuchar
    z::Cuchar
    w::Cuchar
end
SL_Uchar4() = SL_Uchar4(Cuchar(0), Cuchar(0), Cuchar(0), Cuchar(0))

"""
Vector2
"""
mutable struct SL_Vector2 
    x::Cfloat
    y::Cfloat
end
SL_Vector2() = SL_Vector2(Cfloat(0), Cfloat(0))

"""
Vector3
"""
mutable struct SL_Vector3 
    x::Cfloat
    y::Cfloat
    z::Cfloat
end
SL_Vector3() = SL_Vector3(Cfloat(0), Cfloat(0), Cfloat(0))

"""
Vector4
"""
mutable struct SL_Vector4
    x::Cfloat
    y::Cfloat
    z::Cfloat
    w::Cfloat
end
SL_Vector4() = SL_Vector4(Cfloat(0), Cfloat(0), Cfloat(0), Cfloat(0))

#############################  ###########################################################

"""
Quaternion.
"""
mutable struct SL_Quaternion
    x::Cfloat
    y::Cfloat
    z::Cfloat
    w::Cfloat
end

@enum USB_DEVICE begin
	USB_DEVICE_OCULUS
	USB_DEVICE_HTC
	USB_DEVICE_STEREOLABS
end

"""
Lists error codes in the ZED SDK.
"""
@enum SL_ERROR_CODE begin
	SL_ERROR_CODE_SUCCESS # Standard code for successful behavior.
	SL_ERROR_CODE_FAILURE # Standard code for unsuccessful behavior.
	SL_ERROR_CODE_NO_GPU_COMPATIBLE # No GPU found or CUDA capability of the device is not supported.
	SL_ERROR_CODE_NOT_ENOUGH_GPU_MEMORY # Not enough GPU memory for this depth mode, try a different mode (such as PERFORMANCE), or increase the minimum depth value (see InitParameters::depth_minimum_distance).
	SL_ERROR_CODE_CAMERA_NOT_DETECTED # The ZED camera is not plugged or detected.
	SL_ERROR_CODE_SENSORS_NOT_INITIALIZED # The MCU that controls the sensors module has an invalid Serial Number. You can try to recover it launching the 'ZED Diagnostic' tool from the command line with the option '-r'.
	SL_ERROR_CODE_SENSORS_NOT_AVAILABLE # a ZED-M or ZED2/2i camera is detected but the sensors (imu,barometer...) cannot be opened. Only for ZED-M or ZED2/2i devices. Unplug/replug is required
	SL_ERROR_CODE_INVALID_RESOLUTION # In case of invalid resolution parameter, such as a upsize beyond the original image size in Camera::retrieveImage 
	SL_ERROR_CODE_LOW_USB_BANDWIDTH # This issue can occurs when you use multiple ZED or a USB 2.0 port (bandwidth issue).
	SL_ERROR_CODE_CALIBRATION_FILE_NOT_AVAILABLE # ZED calibration file is not found on the host machine. Use ZED Explorer or ZED Calibration to get one.
	SL_ERROR_CODE_INVALID_CALIBRATION_FILE # ZED calibration file is not valid, try to download the factory one or recalibrate your camera using 'ZED Calibration'.
	SL_ERROR_CODE_INVALID_SVO_FILE # The provided SVO file is not valid.
	SL_ERROR_CODE_SVO_RECORDING_ERROR # An recorder related error occurred (not enough free storage, invalid file).
	SL_ERROR_CODE_SVO_UNSUPPORTED_COMPRESSION # An SVO related error when NVIDIA based compression cannot be loaded.
	SL_ERROR_CODE_END_OF_SVOFILE_REACHED # SVO end of file has been reached, and no frame will be available until the SVO position is reset.
	SL_ERROR_CODE_INVALID_COORDINATE_SYSTEM # The requested coordinate system is not available.
	SL_ERROR_CODE_INVALID_FIRMWARE # The firmware of the ZED is out of date. Update to the latest version.
	SL_ERROR_CODE_INVALID_FUNCTION_PARAMETERS # An invalid parameter has been set for the function. 
	SL_ERROR_CODE_CUDA_ERROR # In grab() or retrieveXXX() only, a CUDA error has been detected in the process. Activate verbose in SL_Camera::open for more info.*/
	SL_ERROR_CODE_CAMERA_NOT_INITIALIZED # In grab() only, ZED SDK is not initialized. Probably a missing call to SL_Camera::open.
	SL_ERROR_CODE_NVIDIA_DRIVER_OUT_OF_DATE # Your NVIDIA driver is too old and not compatible with your current CUDA version. 
	SL_ERROR_CODE_INVALID_FUNCTION_CALL # The call of the function is not valid in the current context. Could be a missing call of SL_Camera::open. 
	SL_ERROR_CODE_CORRUPTED_SDK_INSTALLATION # The SDK wasn't able to load its dependencies or somes assets are missing, the installer should be launched. 
	SL_ERROR_CODE_INCOMPATIBLE_SDK_VERSION # The installed SDK is incompatible SDK used to compile the program. 
	SL_ERROR_CODE_INVALID_AREA_FILE # The given area file does not exist, check the path. 
	SL_ERROR_CODE_INCOMPATIBLE_AREA_FILE # The area file does not contain enought data to be used or the SL_DEPTH_MODE used during the creation of the area file is different from the one currently set. */
	SL_ERROR_CODE_CAMERA_FAILED_TO_SETUP # Failed to open the camera at the proper resolution. Try another resolution or make sure that the UVC driver is properly installed.*/
	SL_ERROR_CODE_CAMERA_DETECTION_ISSUE # Your ZED can not be opened, try replugging it to another USB port or flipping the USB-C connector.*/
	SL_ERROR_CODE_CANNOT_START_CAMERA_STREAM # Cannot start camera stream. Make sure your camera is not already used by another process or blocked by firewall or antivirus.*/
	SL_ERROR_CODE_NO_GPU_DETECTED # No GPU found, CUDA is unable to list it. Can be a driver/reboot issue.*/
	SL_ERROR_CODE_PLANE_NOT_FOUND # Plane not found, either no plane is detected in the scene, at the location or corresponding to the floor, or the floor plane doesn't match the prior given*/
	SL_ERROR_CODE_MODULE_NOT_COMPATIBLE_WITH_CAMERA # The Object detection module is only compatible with the ZED 2*/
	SL_ERROR_CODE_MOTION_SENSORS_REQUIRED # The module needs the sensors to be enabled (see InitParameters::disable_sensors) */
	SL_ERROR_CODE_MODULE_NOT_COMPATIBLE_WITH_CUDA_VERSION # The module needs a newer version of CUDA */
end

"""
Represents the available resolution defined in the `cameraResolution` list.
Note: The VGA resolution does not respect the 640*480 standard to better fit the camera sensor (672*376 is used).
"""
@enum SL_RESOLUTION begin
    SL_RESOLUTION_HD2K # 2208*1242, available framerates: 15 fps.
	SL_RESOLUTION_HD1080 # 1920*1080, available framerates: 15, 30 fps.
	SL_RESOLUTION_HD720 # 1280*720, available framerates: 15, 30, 60 fps.
	SL_RESOLUTION_VGA # 672*376, available framerates: 15, 30, 60, 100 fps.
end

"""
Lists available unit for measures.
"""
@enum SL_UNIT begin
	SL_UNIT_MILLIMETER # International System, 1/1000 METER. 
	SL_UNIT_CENTIMETER # International System, 1/100 METER. 
	SL_UNIT_METER # International System, 1 METER. 
	SL_UNIT_INCH # Imperial Unit, 1/12 FOOT. 
	SL_UNIT_FOOT # Imperial Unit, 1 FOOT. 
end

"""
Lists available coordinates systems for positional tracking and 3D measures.
Image html CoordinateSystem.png
"""
@enum SL_COORDINATE_SYSTEM begin
	SL_COORDINATE_SYSTEM_IMAGE # Standard coordinates system in computer vision. Used in OpenCV : see here : http://docs.opencv.org/2.4/modules/calib3d/doc/camera_calibration_and_3d_reconstruction.html 
	SL_COORDINATE_SYSTEM_LEFT_HANDED_Y_UP # Left-Handed with Y up and Z forward. Used in Unity with DirectX. 
	SL_COORDINATE_SYSTEM_RIGHT_HANDED_Y_UP # Right-Handed with Y pointing up and Z backward. Used in OpenGL. 
	SL_COORDINATE_SYSTEM_RIGHT_HANDED_Z_UP # Right-Handed with Z pointing up and Y forward. Used in 3DSMax. 
	SL_COORDINATE_SYSTEM_LEFT_HANDED_Z_UP # Left-Handed with Z axis pointing up and X forward. Used in Unreal Engine. 
	SL_COORDINATE_SYSTEM_RIGHT_HANDED_Z_UP_X_FWD # Right-Handed with Z pointing up and X forward. Used in ROS (REP 103). 
end

"""
List available memory type
"""
@enum SL_MEM begin
	SL_MEM_CPU # CPU Memory (Processor side).
	SL_MEM_GPU  # GPU Memory (Graphic card side).
end

@enum SL_INPUT_TYPE begin
	SL_INPUT_TYPE_USB
	SL_INPUT_TYPE_SVO
	SL_INPUT_TYPE_STREAM
end

"""
Defines which type of position matrix is used to store camera path and pose.
"""
@enum SL_REFERENCE_FRAME begin
	SL_REFERENCE_FRAME_WORLD  # The transform of SL_Pose will contains the motion with reference to the world frame (previously called PATH).
	SL_REFERENCE_FRAME_CAMERA # The transform of SL_Pose will contains the motion with reference to the previous camera frame (previously called POSE).
end

"""
Lists available camera settings for the ZED camera (contrast, hue, saturation, gain...).
Warning: GAIN and EXPOSURE are linked in auto/default mode (see `SL_Camera::setCameraSettings`).
"""
@enum SL_VIDEO_SETTINGS begin
	SL_VIDEO_SETTINGS_BRIGHTNESS # Defines the brightness control. Affected value should be between 0 and 8.
	SL_VIDEO_SETTINGS_CONTRAST # Defines the contrast control. Affected value should be between 0 and 8.
	SL_VIDEO_SETTINGS_HUE # Defines the hue control. Affected value should be between 0 and 11.
	SL_VIDEO_SETTINGS_SATURATION # Defines the saturation control. Affected value should be between 0 and 8.
	SL_VIDEO_SETTINGS_SHARPNESS # Defines the digital sharpening control. Affected value should be between 0 and 8.
	SL_VIDEO_SETTINGS_GAMMA # Defines the ISP gamma control. Affected value should be between 1 and 9.
	SL_VIDEO_SETTINGS_GAIN # Defines the gain control. Affected value should be between 0 and 100 for manual control.
	SL_VIDEO_SETTINGS_EXPOSURE # Defines the exposure control. Affected value should be between 0 and 100 for manual control. The exposition is mapped linearly in a percentage of the following max values. 
							   # Special case for the setExposure(0) that corresponds to 0.17072ms. The conversion to milliseconds depends on the framerate: <ul><li>15fps setExposure(100) -> 19.97ms</li><li>30fps setExposure(100) -> 19.97ms</li><li>60fps setExposure(100) -> 10.84072ms</li><li>100fps setExposure(100) -> 10.106624ms</li></ul>
	SL_VIDEO_SETTINGS_AEC_AGC # Defines if the Gain and Exposure are in automatic mode or not. Setting a Gain or Exposure through @GAIN or @EXPOSURE values will automatically set this value to 0.
	SL_VIDEO_SETTINGS_AEC_AGC_ROI # Defines the region of interest for automatic exposure/gain computation. To be used with overloaded @setCameraSettings/@getCameraSettings functions.
	SL_VIDEO_SETTINGS_WHITEBALANCE_TEMPERATURE # Defines the color temperature value. Setting a value will automatically set @WHITEBALANCE_AUTO to 0. Affected value should be between 2800 and 6500 with a step of 100.
	SL_VIDEO_SETTINGS_WHITEBALANCE_AUTO # Defines if the White balance is in automatic mode or not
	SL_VIDEO_SETTINGS_LED_STATUS # Defines the status of the camera front LED. Set to 0 to disable the light, 1 to enable the light. Default value is on. Requires Camera FW 1523 at least.
	SL_VIDEO_SETTINGS_LAST
end

"""
Lists available views.
"""
@enum SL_VIEW begin
	SL_VIEW_LEFT #Left BGRA image. Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4.  
	SL_VIEW_RIGHT # Right BGRA image. Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4. 
	SL_VIEW_LEFT_GRAY # Left GRAY image. Each pixel contains 1 usigned char. SL_MAT_TYPE_U8_C1. 
	SL_VIEW_RIGHT_GRAY # Right GRAY image. Each pixel contains 1 usigned char. SL_MAT_TYPE_U8_C1. 
	SL_VIEW_LEFT_UNRECTIFIED # Left BGRA unrectified image. Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4. 
	SL_VIEW_RIGHT_UNRECTIFIED # Right BGRA unrectified image. Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4. 
	SL_VIEW_LEFT_UNRECTIFIED_GRAY # Left GRAY unrectified image. Each pixel contains 1 usigned char. SL_MAT_TYPE_U8_C1. 
	SL_VIEW_RIGHT_UNRECTIFIED_GRAY # Right GRAY unrectified image. Each pixel contains 1 usigned char. SL_MAT_TYPE_U8_C1. 
	SL_VIEW_SIDE_BY_SIDE # Left and right image (the image width is therefore doubled). Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4. 
	SL_VIEW_DEPTH # Color rendering of the depth. Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4. Use `MEASURE` "MEASURE_DEPTH" with `Camera.retrieveMeasure()` to get depth values.
	SL_VIEW_CONFIDENCE # Color rendering of the depth confidence. Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4. 
	SL_VIEW_NORMALS # Color rendering of the normals. Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4. 
	SL_VIEW_DEPTH_RIGHT # Color rendering of the right depth mapped on right sensor. Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4. 
	SL_VIEW_NORMALS_RIGHT # Color rendering of the normals mapped on right sensor. Each pixel contains 4 usigned char (B,G,R,A). SL_MAT_TYPE_U8_C4. 
end

"""
Gives the spatial mapping state.
"""
@enum SL_SPATIAL_MAPPING_STATE begin
	SL_SPATIAL_MAPPING_STATE_INITIALIZING #The spatial mapping is initializing.
	SL_SPATIAL_MAPPING_STATE_OK # The depth and tracking data were correctly integrated in the fusion algorithm.
	SL_SPATIAL_MAPPING_STATE_NOT_ENOUGH_MEMORY # The maximum memory dedicated to the scanning has been reach, the mesh will no longer be updated.
	SL_SPATIAL_MAPPING_STATE_NOT_ENABLED # Camera::enableSpatialMapping() wasn't called (or the scanning was stopped and not relaunched).
	SL_SPATIAL_MAPPING_STATE_FPS_TOO_LOW # Effective FPS is too low to give proper results for spatial mapping. 
										 # Consider using PERFORMANCES parameters (DEPTH_MODE_PERFORMANCE, low camera resolution (VGA,HD720), spatial mapping low resolution)
end

"""
\brief Lists the types of spatial maps that can be created.
"""
@enum SL_SPATIAL_MAP_TYPE begin
	SL_SPATIAL_MAP_TYPE_MESH # Represents a surface with faces, 3D points are linked by edges, no color information.
	SL_SPATIAL_MAP_TYPE_FUSED_POINT_CLOUD # Geometry is represented by a set of 3D colored points.
end

"""
\brief Lists available mesh filtering intensity.
"""
@enum SL_MESH_FILTER begin
	SL_MESH_FILTER_LOW # Clean the mesh by closing small holes and removing isolated faces.
	SL_MESH_FILTER_MEDIUM # Soft decimation and smoothing.
	SL_MESH_FILTER_HIGH # Decimate the number of triangles and apply a soft smooth.
end


"""
Lists available mesh file formats.
"""
@enum SL_MESH_FILE_FORMAT begin
	SL_MESH_FILE_FORMAT_PLY # Contains only vertices and faces.
	SL_MESH_FILE_FORMAT_PLY_BIN # Contains only vertices and faces, encoded in binary.
	SL_MESH_FILE_FORMAT_OBJ # Contains vertices, normals, faces and textures informations if possible.
end

"""
Lists available depth sensing modes.

# SL_SENSING_MODE_STANDARD
This mode outputs ZED standard depth map that preserves edges and depth accuracy.
* Applications example: Obstacle detection, Automated navigation, People detection, 3D reconstruction, measurements.

# SL_SENSING_MODE_FILL
This mode outputs a smooth and fully dense depth map.
* Applications example: AR/VR, Mixed-reality capture, Image post-processing.
"""
@enum SL_SENSING_MODE begin
	SL_SENSING_MODE_STANDARD
	SL_SENSING_MODE_FILL
end

"""
Lists available depth computation modes.
"""
@enum SL_DEPTH_MODE begin
	SL_DEPTH_MODE_NONE # This mode does not compute any depth map. Only rectified stereo images will be available.
	SL_DEPTH_MODE_PERFORMANCE # Computation mode optimized for speed.
	SL_DEPTH_MODE_QUALITY # Computation mode designed for challenging areas with untextured surfaces.
	SL_DEPTH_MODE_ULTRA # Computation mode favorising edges and sharpness. Requires more GPU memory and computation power.
end

@enum SL_FLIP_MODE begin
	SL_FLIP_MODE_OFF # default behavior
	SL_FLIP_MODE_ON # Images and camera sensors data are flipped useful when your camera is mounted upside down
	SL_FLIP_MODE_AUTO # Live mode: use the camera orientation (if an IMU is available) to set the flip mode. SVO mode: read the state of this enum when recorded
end

"""
Lists available compression modes for SVO recording.

SL_SVO_COMPRESSION_MODE_LOSSLESS is an improvement of previous lossless compression (used in ZED Explorer), even if size may be bigger, compression time is much faster.
"""
@enum SL_SVO_COMPRESSION_MODE begin
	SL_SVO_COMPRESSION_MODE_LOSSLESS # PNG/ZSTD (lossless) CPU based compression : avg size = 42% (of RAW).
	SL_SVO_COMPRESSION_MODE_H264 # H264(AVCHD) GPU based compression : avg size = 1% (of RAW). Requires a NVIDIA GPU
	SL_SVO_COMPRESSION_MODE_H265 # H265(HEVC) GPU based compression: avg size = 1% (of RAW). Requires a NVIDIA GPU, Pascal architecture or newer
end

"""
List available Mat formats.
"""
@enum SL_MAT_TYPE begin
	SL_MAT_TYPE_F32_C1 # float 1 channel.
	SL_MAT_TYPE_F32_C2 # float 2 channels.
	SL_MAT_TYPE_F32_C3 # float 3 channels.
	SL_MAT_TYPE_F32_C4 # float 4 channels.
	SL_MAT_TYPE_U8_C1 # unsigned char 1 channel.
	SL_MAT_TYPE_U8_C2 # unsigned char 2 channels.
	SL_MAT_TYPE_U8_C3 # unsigned char 3 channels.
	SL_MAT_TYPE_U8_C4 # unsigned char 4 channels.
	SL_MAT_TYPE_U16_C1 # unsigned short 1 channel.
end

"""
Struct containing all parameters passed to the SDK when initializing the ZED.
These parameters will be fixed for the whole execution life time of the camera.
For more details, see the InitParameters class in the SDK API documentation:
https://www.stereolabs.com/docs/api/structsl_1_1InitParameters.html

$(FIELDS)
"""
mutable struct SL_InitParameters
	"""
	The SDK can handle different input types:
	- Select a camera by its ID (/dev/video<i>X</i> on Linux, and 0 to N cameras connected on Windows)
	- Select a camera by its serial number
	- Open a recorded sequence in the SVO file format
	- Open a streaming camera from its IP address and port
  	This parameter allows you to select to desired input.
	"""
	input_type::SL_INPUT_TYPE
	"""
	Define the chosen camera resolution. Small resolutions offer higher framerate and lower computation time (SL_RESOLUTION).\n
	In most situations, the `SL_RESOLUTION` "RESOLUTION_HD720" at 60 fps is the best balance between image quality and framerate.\n
	Available resolutions are listed here: RESOLUTION.\n 
	default : `SL_RESOLUTION` "RESOLUTION_HD720"
	"""
	resolution::SL_RESOLUTION
	"""
	Requested camera frame rate. If set to 0, the highest FPS of the specified `camera_resolution` will be used.\n
	See `SL_RESOLUTION` for a list of supported framerates. \n default : 0
	Note: If the requested camera_fps is unsupported, the closest available FPS will be used.
	"""
	camera_fps::Cint 
	"""Id of the `Camera`."""
	camera_device_id::Cint 
	"""
	If you are using the camera upside down, setting this parameter to FLIP_MODE_ON will cancel its rotation. The images will be horizontally flipped.\n
	default : FLIP_MODE_AUTO
	From ZED SDK 3.2 a new FLIP_MODE enum was introduced to add the automatic flip mode detection based on the IMU gravity detection. This only works for ZED-M or ZED2 cameras.
	"""
	camera_image_flip::SL_FLIP_MODE
	"""
	At initialization, the `Camera` runs a self-calibration process that corrects small offsets from the device's factory calibration.\n
	A drawback is that calibration parameters will slightly change from one run to another, which can be an issue for repeatability.\n
	If set to true, self-calibration will be disabled and calibration parameters won't be optimized.\n
	default : false
	Note: In most situations, self calibration should remain enabled.
	Note: You can also trigger the self-calibration at anytime after open() by calling `Camera::UpdateSelfCalibration()`, even if this parameter is set to true.
	"""
	camera_disable_self_calib::Bool
	"""
	By default, the SDK only computes a single depth map, aligned with the left camera image.\n
	This parameter allows you to enable the `MEASURE` "MEASURE_DEPTH_RIGHT" and other `MEASURE` "MEASURE_<XXX>_RIGHT" at the cost of additional computation time.\n
	For example, mixed reality pass-through applications require one depth map per eye, so this parameter can be activated.
	\n default : false
	"""
	enable_right_side_measure::Bool
	"""
	When playing back an SVO file, each call to `Camera::grab()` will extract a new frame and use it.\n
	However, this ignores the real capture rate of the images saved in the SVO file.\n
	Enabling this parameter will bring the SDK closer to a real simulation when playing back a file by using the images' timestamps. However, calls to `Camera::grab()` will return an error when trying to play too fast, and frames will be dropped when playing too slowly.
	\n default : false
	"""
	svo_real_time_mode::Bool
	"""
	The SDK offers several `SL_DEPTH_MODE` options offering various levels of performance and accuracy.
	\n This parameter allows you to set the `SL_DEPTH_MODE` that best matches your needs.
	\n default : `SL_DEPTH_MODE` "DEPTH_MODE_PERFORMANCE"
	"""
	depth_mode::SL_DEPTH_MODE
	"""
	Regions of the generated depth map can oscillate from one frame to another. These oscillations result from a lack of texture (too homogeneous) on an object and by image noise.
	\n This parameter enables a stabilization filter that reduces these oscillations.
	\n default : true
	Note: The stabilization uses the positional tracking to increase its accuracy, so the Positional Tracking module will be enabled automatically when set to true.\n
	"""
	depth_stabilization::Cint
	"""
	This parameter allows you to specify the minimum depth value (from the camera) that will be computed, measured in the `UNIT` you define.
	\n In stereovision (the depth technology used by the camera), looking for closer depth values can have a slight impact on performance and memory consumption.
	\n On most of modern GPUs, performance impact will be low. However, the impact of memory footprint will be visible.
	\n In cases of limited computation power, increasing this value can provide better performance.
	\n default : (-1) corresponding to 700 mm for a ZED/ZED2 and 300 mm for ZED Mini.
	Note: With a ZED camera you can decrease this value to 300 mm whereas you can set it to 100 mm using a ZED Mini and 200 mm for a ZED2. In any case this value cannot be greater than 3 meters.
	Note: Specific value (0) : This will set the depth minimum distance to the minimum authorized value :
								- 300mm for ZED
								- 100mm for ZED-M
								- 200mm for ZED2
	"""
	depth_minimum_distance::Cfloat
	"""
	Defines the current maximum distance that can be computed in the defined `UNIT`.
	When estimating the depth, the SDK uses this upper limit to turn higher values into `TOO_FAR` ones.
	Note: Changing this value has no impact on performance and doesn't affect the positional tracking nor the spatial mapping. (Only the depth, point cloud, normals)
	"""
	depth_maximum_distance::Cfloat
	"""
	This parameter allows you to select the unit to be used for all metric values of the SDK. (depth, point cloud, tracking, mesh, and others) (SL_UNIT).
	\n default : `SL_UNIT` "UNIT_MILLIMETER"
	"""
	coordinate_unit::SL_UNIT
	"""
	Positional tracking, point clouds and many other features require a given `SL_COORDINATE_SYSTEM` to be used as reference.
	This parameter allows you to select the `SL_COORDINATE_SYSTEM` used by the `Camera` to return its measures.
	\n This defines the order and the direction of the axis of the coordinate system.
	\n default : `SL_COORDINATE_SYSTEM` "COORDINATE_SYSTEM_IMAGE"
	"""
	coordinate_system::SL_COORDINATE_SYSTEM
	"""
	By default the SDK will use the most powerful NVIDIA graphics card found.
	However, when running several applications, or using several cameras at the same time, splitting the load over available GPUs can be useful.
	This parameter allows you to select the GPU used by the `Camera` using an ID from 0 to n-1 GPUs in your PC.
	\n default : -1
	Note: A non-positive value will search for all CUDA capable devices and select the most powerful.
	"""
	sdk_gpu_id::Cint
	"""
	This parameter allows you to enable the verbosity of the SDK to get a variety of runtime information in the console.
	When developing an application, enabling verbose mode can help you understand the current SDK behavior.
	\n However, this might not be desirable in a shipped version.
	\n default : false
	\note The verbose messages can also be exported into a log file. See `sdk_verbose_log_file` for more.
	"""
	sdk_verbose::Bool
	"""
	Force the motion sensors opening of the ZED 2 / ZED-M to open the camera.
	\n default : false.
	\n If set to false, the SDK will try to <b>open and use</b> the IMU (second USB device on USB2.0) and will open the camera successfully even if the sensors failed to open.
	\n This can be used for example when using a USB3.0 only extension cable (some fiber extension for example).
	\n This parameter only impacts the LIVE mode.
	\n If set to true, the camera will fail to open if the sensors cannot be opened. This parameter should be used when the IMU data must be available, such as Object Detection module or when the gravity is needed.
	Note: This setting is not taken into account for ZED camera since it does not include sensors.
	"""
	sensors_required::Bool
	"""
	Enable or Disable the Enhanced Contrast Technology, to improve image quality.
	\n default : true.
	\n If set to true, image enhancement will be activated in camera ISP. Otherwise, the image will not be enhanced by the IPS.
	\n This only works for firmware version starting from 1523 and up.
	"""
	enable_image_enhancement::Bool
	"""
	Define a timeout in seconds after which an error is reported if the `open()`` command fails.
	Set to '-1' to try to open the camera endlessly without returning error in case of failure.
	Set to '0' to return error in case of failure at the first attempt.
	\n This parameter only impacts the LIVE mode.
	"""
	open_timeout_sec::Cfloat
end
function SL_InitParameters(camera_id::T) where {T<:Integer}
	SL_InitParameters(SL_INPUT_TYPE_USB,
					  SL_RESOLUTION_HD720,
					  Cint(0),
					  Cint(camera_id),
					  SL_FLIP_MODE_AUTO,
					  false,
					  false,
					  false,
					  SL_DEPTH_MODE_PERFORMANCE,
					  Cint(1),
					  Cfloat(-1),
					  Cfloat(-1),
					  SL_UNIT_MILLIMETER,
					  SL_COORDINATE_SYSTEM_IMAGE,
					  Cint(-1),
					  false,
					  false,
					  true,
					  Cfloat(5))
end

"""
Parameters that define the behavior of the grab.

$(FIELDS)
"""
mutable struct SL_RuntimeParameters
	"""
	Defines the algorithm used for depth map computation, more info : `SENSING_MODE` definition.
	\n default : `SENSING_MODE_STANDARD`
	"""
	sensing_mode::SL_SENSING_MODE
	"""
	Provides 3D measures (point cloud and normals) in the desired reference frame (default is `REFERENCE_FRAME_CAMERA`)
	\n default : `REFERENCE_FRAME_CAMERA`
	"""
	reference_frame::SL_REFERENCE_FRAME 
	"""
	Defines if the depth map should be computed.
	\n If false, only the images are available.
	\n default : true
	"""
	enable_depth::Bool
	"""
	Threshold to reject depth values based on their confidence.
	\n Each depth pixel has a corresponding confidence. (`MEASURE` "MEASURE_CONFIDENCE"), the confidence range is [1,100].
	\n By default, the confidence threshold is set at 100, meaning that no depth pixel will be rejected.
	\n Decreasing this value will remove depth data from both objects edges and low textured areas, to keep only confident depth estimation data.
	"""
	confidence_threshold::Cint
	"""
	Threshold to reject depth values based on their texture confidence.
	\n The texture confidence range is [1,100].
	\n By default, the texture confidence threshold is set at 100, meaning that no depth pixel will be rejected.
	\n Decreasing this value will remove depth data from image areas which are uniform.
	"""
	texture_confidence_threshold::Cint
end
function SL_RuntimeParameters()
	SL_RuntimeParameters(SL_SENSING_MODE_STANDARD, 
						 SL_REFERENCE_FRAME_CAMERA, 
						 true, 
						 Cint(100), 
						 Cint(100))
end



"""
Parameters for positional tracking initialization.

$(FIELDS)
"""
mutable struct SL_PositionalTrackingParameters
	"""
	Rotation of the camera in the world frame when the camera is started. By default, it should be identity.
	"""
	initial_world_rotation::SL_Quaternion
	"""
	Position of the camera in the world frame when the camera is started. By default, it should be identity.
	"""
	initial_world_position::SL_Vector3
	"""
	This mode enables the camera to remember its surroundings. This helps correct positional tracking drift, and can be helpful for positioning
	different cameras relative to one other in space.
	default: true
	warning: This mode requires more resources to run, but greatly improves tracking accuracy. We recommend leaving it on by default.
	"""
	enable_area_memory::Bool
	"""
	This mode enables smooth pose correction for small drift correction.
	default: false
	"""
	enable_pose_smothing::Bool
	"""
	This mode initializes the tracking to be aligned with the floor plane to better position the camera in space.
	default: false
	note: This launches floor plane detection in the background until a suitable floor plane is found.
	The tracking is in POSITIONAL_TRACKING_STATE_SEARCHING state.
	warning: This features work best with the ZED-M since it needs an IMU to classify the floor.
	The ZED needs to look at the floor during initialization for optimum results.
	"""
	set_floor_as_origin::Bool
	"""
	This setting allows you define the camera as static. If true, it will not move in the environment. This allows you to set its position using initial_world_transform.
	All SDK functionalities requiring positional tracking will be enabled.
	Camera::getPosition() will return the value set as initial_world_transform for the PATH, and identity as the POSE.
	"""
	set_as_static::Bool
	"""
	This setting allows you to enable or disable IMU fusion. When set to false, only the optical odometry will be used.
	default: true
	note: This setting has no impact on the tracking of a ZED camera; only the ZED Mini uses a built-in IMU.
	"""
	enable_imu_fusion::Bool
end
function SL_PositionalTrackingParameters()
	SL_PositionalTrackingParameters(SL_Quaternion(Cfloat(0),Cfloat(0),Cfloat(0),Cfloat(1)),
									SL_Vector3(Cfloat(0), Cfloat(0), Cfloat(0)),
									true,
									false,
									false,
									false,
									true)
end

mutable struct SL_SpatialMappingParameters 
	"""
	Spatial mapping resolution in meters. Should fit \ref allowed_resolution (Default is 0.05f).
	"""
	resolution_meter::Cfloat
	"""
	Depth range in meters.
	Can be different from the value set by \ref setDepthMaxRangeValue.
	Set to 0 by default. In this case, the range is computed from resolution_meter
	and from the current internal parameters to fit your application.
	"""
	range_meter::Cfloat
	"""
	Set to true if you want to be able to apply the texture to your mesh after its creation.
	note This option will consume more memory.
	note This option is only available for \ref SPATIAL_MAP_TYPE_MESH
	"""
	save_texture::Bool
	"""
	Set to false if you want to ensure consistency between the mesh and its inner chunk data (default is false).
	note Updating the mesh is time-consuming. Setting this to true results in better performance.
	"""
	use_chunk_only::Bool
	"""
	The maximum CPU memory (in MB) allocated for the meshing process (default is 2048).
	"""
	max_memory_usage::Cint
	"""
	Specify if the order of the vertices of the triangles needs to be inverted. If your display process does not handle front and back face culling, you can use this to correct it.
	note This option is only available for \ref SPATIAL_MAP_TYPE_MESH
	"""
	reverse_vertex_order::Bool
	"""
	The type of spatial map to be created. This dictates the format that will be used for the mapping(e.g. mesh, point cloud). See \ref SPATIAL_MAP_TYPE
	"""
	map_type::SL_SPATIAL_MAP_TYPE
end
function SL_SpatialMappingParameters()
	SL_SpatialMappingParameters(Cfloat(0.05),
								Cfloat(0),
								false,
								false,
								Cint(2048),
								false,
								ZED.SL_SPATIAL_MAP_TYPE_MESH)
end