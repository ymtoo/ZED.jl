export sl_mat_create_new, sl_mat_is_init, sl_mat_free, sl_mat_get_infos, 
    sl_mat_get_width, sl_mat_get_height, sl_mat_get_channels, 
    sl_mat_get_memory_type

function sl_mat_create_new(width::T, height::T, mat_type::SL_MAT_TYPE, mem::SL_MEM) where {T<:Integer}
    ccall((:sl_mat_create_new, zed), 
          Ptr{Cint}, 
          (Cint, Cint, Cuint, Cuint), 
          Cint(width), Cint(height), mat_type, mem)
end

"""
Tells if the Mat has been initialized.

ptr : Ptr to the Mat.
Return: True if the Mat has been initialized.
"""
function sl_mat_is_init(image_ptr::Ptr{Cint})
    ccall((:sl_mat_is_init, zed), Bool, (Ptr{Cint},), image_ptr)
end

function sl_mat_free(image_ptr::Ptr{Cint}, mem::SL_MEM)
    ccall((:sl_mat_free, zed), Cvoid, (Ptr{Cint}, Cuint), image_ptr, mem)
end

function sl_mat_get_infos(image_ptr::Ptr{Cint})
    buffer = zeros(Cchar, 100) 
    val = ccall((:sl_mat_get_infos, zed), 
                Cvoid, 
                (Ptr{Cint}, Ptr{Cchar}), 
                image_ptr, buffer)
    if val == C_NULL
        error("sl_mat_get_infos")
    end
    unsafe_string(pointer(buffer))
end

"""
Gets the Width of the matrix.

image_ptr : Ptr to the Mat.
Return: The width of the matrix.
"""
function sl_mat_get_width(image_ptr::Ptr{Cint})
    ccall((:sl_mat_get_width, zed), Cint, (Ptr{Cint},), image_ptr)
end

"""
Gets the Height of the matrix.

image_ptr : Ptr to the Mat.
Return: The height of the matrix.
"""
function sl_mat_get_height(image_ptr::Ptr{Cint})
    ccall((:sl_mat_get_height, zed), Cint, (Ptr{Cint},), image_ptr)
end


function sl_mat_get_channels(image_ptr::Ptr{Cint})
    ccall((:sl_mat_get_channels, zed), Cint, (Ptr{Cint},), image_ptr)
end

function sl_mat_get_memory_type(image_ptr::Ptr{Cint})
    ccall((:sl_mat_get_memory_type, zed), Cint, (Ptr{Cint},), image_ptr)
end

# function sl_mat_get_value_uchar(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM ) where {T<:Integer}
#     value = Uc
# end