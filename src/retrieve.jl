export sl_retrieve_image

function sl_retrieve_image(camera_id::T, 
                           image_ptr::Ptr{Cint}, 
                           sl_view::SL_VIEW, 
                           mem::SL_MEM, 
                           width::DT, 
                           height::DT) where {T<:Integer,DT<:Integer} 
    err = ccall((:sl_retrieve_image, zed), 
                Cint,
                (Cint, Ptr{Cint}, Cuint, Cuint, Cint, Cint), 
                Cint(camera_id), image_ptr, sl_view, mem, Cint(width), Cint(height))
    SL_ERROR_CODE(err)
end