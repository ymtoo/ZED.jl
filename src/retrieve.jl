export sl_retrieve_image, sl_retrieve_measure

function sl_retrieve_image(camera_id::T, 
                           image_ptr::Ptr{Cint}, 
                           sl_view::SL_VIEW, 
                           mem::SL_MEM, 
                           width::DT, 
                           height::DT) where {T<:Integer,DT<:Integer} 
    err = ccall((:sl_retrieve_image, zed), 
                Cint,
                (Cint, Ptr{Cint}, Cuint, Cuint, Cint, Cint), 
                camera_id, image_ptr, sl_view, mem, width, height)
    SL_ERROR_CODE(err)
end

"""
Retrieves a measure texture from the ZED SDK. Use this to get an individual texture \
from the last grabbed frame with measurements in every pixel - such as depth map, \
confidence map etc. Measure textures are not human-viewable but don't lose accuracy, \
unlike image textures.

# Arguments
- camera_id : id of the camera instance.
- measure_ptr : pointer to the measure texture.
- type : Measure type (depth, confidence, xyz, etc). See \ref SL_MEASURE.
- mem : Whether the measure should be on CPU or GPU memory. See \ref SL_MEM.
- width : width of the texture in pixel.
- height : height of the texture in pixel.

# Returns
"SUCCESS" if the retrieve succeeded.
"""
function sl_retrieve_measure(camera_id::T, 
                             measure_ptr::Ptr{Cint},
                             type::SL_MEASURE,
                             mem::SL_MEM, 
                             width::DT, 
                             height::DT) where {T<:Integer,DT<:Integer} 
    err = ccall((:sl_retrieve_measure, zed), 
                Cint,
                (Cint, Ptr{Cint}, Cuint, Cuint, Cint, Cint),
                camera_id, measure_ptr, type, mem, width, height)
    SL_ERROR_CODE(err)
end