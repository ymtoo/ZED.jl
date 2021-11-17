export sl_mat_create_new, sl_mat_is_init, sl_mat_free, sl_mat_get_infos, 
    sl_mat_get_width, sl_mat_get_height, sl_mat_get_channels, 
    sl_mat_get_memory_type, sl_mat_set_value_uchar, sl_mat_set_value_float,
    sl_mat_get_value_uchar, sl_mat_get_value_float

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
    i_mem = ccall((:sl_mat_get_memory_type, zed), Cint, (Ptr{Cint},), image_ptr)
    SL_MEM(i_mem-1) # memory type indexing starts from 1? 
end

function sl_mat_set_value_uchar(image_ptr, 
                                col::T, 
                                row::T, 
                                value::Cuchar, 
                                mem::SL_MEM) where {T<:Integer}
    err = ccall((:sl_mat_set_value_uchar, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Cuchar, Cuint), 
                image_ptr, col, row, value, mem) # 1-based indexing
    SL_ERROR_CODE(err)
end
function sl_mat_set_value_uchar(image_ptr, 
                                col::T, 
                                row::T, 
                                value::Array{Cuchar}, 
                                mem::SL_MEM) where {T<:Integer}
    length(value) > 1 && throw(ArgumentError("`value` is an array of one element."))
    sl_mat_set_value_uchar(image_ptr, col, row, first(value), mem)
end

function sl_mat_set_value_float(image_ptr, 
                                col::T, 
                                row::T, 
                                value::VT, 
                                mem::SL_MEM) where {T<:Integer, VT<:AbstractFloat}
    err = ccall((:sl_mat_set_value_float, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Cfloat, Cuint), 
                image_ptr, col, row, value, mem) # 1-based indexing
    SL_ERROR_CODE(err)
end
function sl_mat_set_value_float(image_ptr, 
                                col::T, 
                                row::T, 
                                value::Array{VT}, 
                                mem::SL_MEM) where {T<:Integer, VT<:AbstractFloat}
    length(value) > 1 && throw(ArgumentError("`value` is an array of one element."))
    sl_mat_set_value_float(image_ptr, col, row, first(value), mem)
end

function sl_mat_get_value_uchar(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = zeros(Cuchar, 1) 
    err = ccall((:sl_mat_get_value_uchar, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Ptr{Cuchar}, Cuint), 
                image_ptr, col, row, buffer, mem)    
    if err == 0
        buffer # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end

function sl_mat_get_value_float(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = zeros(Cfloat, 1) 
    err = ccall((:sl_mat_get_value_float, zed), 
                Cint, (Ptr{Cint}, Cint, Cint, Ptr{Cfloat}, Cuint), 
                image_ptr, col, row, buffer, mem)    
    if err == 0
        buffer # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end