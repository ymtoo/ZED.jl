export sl_mat_create_new, sl_mat_is_init, sl_mat_free, sl_mat_get_infos, 
    sl_mat_get_width, sl_mat_get_height, sl_mat_get_channels, 
    sl_mat_get_memory_type 

export sl_mat_set_value_uchar, sl_mat_set_value_uchar2, 
    sl_mat_set_value_uchar3, sl_mat_set_value_uchar4,
    sl_mat_get_value_uchar, sl_mat_get_value_uchar2,
    sl_mat_get_value_uchar3, sl_mat_get_value_uchar4
    
export sl_mat_set_value_float, sl_mat_set_value_float2,
    sl_mat_set_value_float3, sl_mat_set_value_float4,
    sl_mat_get_value_float, sl_mat_get_value_float2,
    sl_mat_get_value_float3, sl_mat_get_value_float4

export sl_mat_set_to_uchar, sl_mat_set_to_uchar2,
       sl_mat_set_to_uchar3, sl_mat_set_to_uchar4,
       sl_mat_set_to_float, sl_mat_set_to_float2,
       sl_mat_set_to_float3, sl_mat_set_to_float4

export getframe

export sl_mat_read, sl_mat_write

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

"""
Sets a value to a specific point in the matrix.

# Arguments
- ptr : Ptr to the Mat.
- col : specifies the column.
- raw : specifices the row.
- value : the value to be set.
- mem : Whether Mat should exist on CPU or GPU memory (SL_MEM).

# Returns
ERROR_CODE::SUCCESS if everything went well, ERROR_CODE::FAILURE otherwise.
"""
function sl_mat_set_value_uchar(image_ptr, 
                                col::T, 
                                row::T, 
                                value::Cuchar, 
                                mem::SL_MEM) where {T<:Integer}
    err = ccall((:sl_mat_set_value_uchar, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Cuchar, Cuint), 
                image_ptr, col-1, row-1, value, mem) # 1-based indexing
    SL_ERROR_CODE(err)
end
function sl_mat_set_value_uchar(image_ptr, 
                                col::T, 
                                row::T, 
                                value::Vector{Cuchar}, 
                                mem::SL_MEM) where {T<:Integer}
    length(value) != 1 && throw(ArgumentError("`value` is an array of 1 element."))
    sl_mat_set_value_uchar(image_ptr, col, row, first(value), mem)
end

"""
Sets a value to a specific point in the matrix.

# Arguments
- ptr : Ptr to the Mat.
- col : specifies the column.
- raw : specifices the row.
- value : the value to be set.
- mem : Whether Mat should exist on CPU or GPU memory (SL_MEM).

# Returns
ERROR_CODE::SUCCESS if everything went well, ERROR_CODE::FAILURE otherwise.
"""
function sl_mat_set_value_uchar2(image_ptr, 
                                 col::T, 
                                 row::T, 
                                 value::Vector{Cuchar}, 
                                 mem::SL_MEM) where {T<:Integer} 
    length(value) != 2 && throw(ArgumentError("`value` is an array of 2 elements."))
    value1= SL_Uchar2(value...)
    err = ccall((:sl_mat_set_value_uchar2, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, SL_Uchar2, Cuint), 
                image_ptr, col-1, row-1, value1, mem) 
    SL_ERROR_CODE(err)
end

function sl_mat_set_value_uchar3(image_ptr, 
                                 col::T, 
                                 row::T, 
                                 value::Vector{Cuchar}, 
                                 mem::SL_MEM) where {T<:Integer} 
    length(value) != 3 && throw(ArgumentError("`value` is an array of 3 elements."))
    value1= SL_Uchar3(value...)
    err = ccall((:sl_mat_set_value_uchar3, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, SL_Uchar3, Cuint), 
                image_ptr, col-1, row-1, value1, mem) 
    SL_ERROR_CODE(err)
end

function sl_mat_set_value_uchar4(image_ptr, 
                                 col::T, 
                                 row::T, 
                                 value::Vector{Cuchar}, 
                                 mem::SL_MEM) where {T<:Integer} 
    length(value) != 4 && throw(ArgumentError("`value` is an array of 4 elements."))
    value1= SL_Uchar4(value...)
    err = ccall((:sl_mat_set_value_uchar4, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, SL_Uchar4, Cuint), 
                image_ptr, col-1, row-1, value1, mem) 
    SL_ERROR_CODE(err)
end

"""
Sets a value to a specific point in the matrix.

# Arguments
- ptr : Ptr to the Mat.
- col : specifies the column.
- raw : specifices the row.
- value : the value to be set.
- mem : Whether Mat should exist on CPU or GPU memory (SL_MEM).

# Returns
ERROR_CODE::SUCCESS if everything went well, ERROR_CODE::FAILURE otherwise.
"""
function sl_mat_set_value_float(image_ptr, 
                                col::T, 
                                row::T, 
                                value::V, 
                                mem::SL_MEM) where {T<:Integer, V<:AbstractFloat}
    err = ccall((:sl_mat_set_value_float, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Cfloat, Cuint), 
                image_ptr, col-1, row-1, value, mem) # 1-based indexing
    SL_ERROR_CODE(err)
end
function sl_mat_set_value_float(image_ptr, 
                                col::T, 
                                row::T, 
                                value::Vector{V}, 
                                mem::SL_MEM) where {T<:Integer,V<:AbstractFloat}
    length(value) != 1 && throw(ArgumentError("`value` is an array of one element."))
    sl_mat_set_value_float(image_ptr, col, row, first(value), mem)
end

function sl_mat_set_value_float2(image_ptr, 
                                 col::T, 
                                 row::T, 
                                 value::Vector{V}, 
                                 mem::SL_MEM) where {T<:Integer,V<:AbstractFloat} 
    length(value) != 2 && throw(ArgumentError("`value` is an array of 2 elements."))
    value1= SL_Vector2(value...)
    err = ccall((:sl_mat_set_value_float2, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, SL_Vector2, Cuint), 
                image_ptr, col-1, row-1, value1, mem) 
    SL_ERROR_CODE(err)
end

function sl_mat_set_value_float3(image_ptr, 
                                 col::T, 
                                 row::T, 
                                 value::Vector{V}, 
                                 mem::SL_MEM) where {T<:Integer,V<:AbstractFloat} 
    length(value) != 3 && throw(ArgumentError("`value` is an array of 3 elements."))
    value1= SL_Vector3(value...)
    err = ccall((:sl_mat_set_value_float3, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, SL_Vector3, Cuint), 
                image_ptr, col-1, row-1, value1, mem) 
    SL_ERROR_CODE(err)
end

function sl_mat_set_value_float4(image_ptr, 
                                 col::T, 
                                 row::T, 
                                 value::Vector{V}, 
                                 mem::SL_MEM) where {T<:Integer,V<:AbstractFloat} 
    length(value) != 4 && throw(ArgumentError("`value` is an array of 4 elements."))
    value1= SL_Vector4(value...)
    err = ccall((:sl_mat_set_value_float4, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, SL_Vector4, Cuint), 
                image_ptr, col-1, row-1, value1, mem) 
    SL_ERROR_CODE(err)
end

"""
Returns the value of a specific point in the matrix. 

# Argments
- ptr : Ptr to the Mat.
- col : specifies the column.
- raw : specifices the row.
- value [Out] : the value to get.
- mem : Whether Mat should exist on CPU or GPU memory (SL_MEM).

# Returns
ERROR_CODE::SUCCESS if everything went well, ERROR_CODE::FAILURE otherwise.
"""
function sl_mat_get_value_uchar(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = zeros(Cuchar, 1) 
    err = ccall((:sl_mat_get_value_uchar, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Ptr{Cuchar}, Cuint), 
                image_ptr, col-1, row-1, buffer, mem)    
    if err == 0
        buffer # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end

"""
Returns the value of a specific point in the matrix. 

# Argments
- ptr : Ptr to the Mat.
- col : specifies the column.
- raw : specifices the row.
- value [Out] : the value to get.
- mem : Whether Mat should exist on CPU or GPU memory (SL_MEM).

# Returns
ERROR_CODE::SUCCESS if everything went well, ERROR_CODE::FAILURE otherwise.
"""
function sl_mat_get_value_uchar2(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = SL_Uchar2()
    err = ccall((:sl_mat_get_value_uchar2, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Ref{SL_Uchar2}, Cuint), 
                image_ptr, col-1, row-1, Ref(buffer), mem)    
    if err == 0
        [buffer.x, buffer.y] # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end

function sl_mat_get_value_uchar3(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = SL_Uchar3()
    err = ccall((:sl_mat_get_value_uchar3, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Ref{SL_Uchar3}, Cuint), 
                image_ptr, col-1, row-1, Ref(buffer), mem)    
    if err == 0
        [buffer.x, buffer.y, buffer.z] # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end

function sl_mat_get_value_uchar4(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = SL_Uchar4()
    err = ccall((:sl_mat_get_value_uchar4, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Ref{SL_Uchar4}, Cuint), 
                image_ptr, col-1, row-1, Ref(buffer), mem)    
    if err == 0
        [buffer.x, buffer.y, buffer.z, buffer.w] # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end

"""
Returns the value of a specific point in the matrix. 

# Argments
- ptr : Ptr to the Mat.
- col : specifies the column.
- raw : specifices the row.
- value [Out] : the value to get.
- mem : Whether Mat should exist on CPU or GPU memory (SL_MEM).

# Returns
ERROR_CODE::SUCCESS if everything went well, ERROR_CODE::FAILURE otherwise.
"""
function sl_mat_get_value_float(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = zeros(Cfloat, 1) 
    err = ccall((:sl_mat_get_value_float, zed), 
                Cint, (Ptr{Cint}, Cint, Cint, Ptr{Cfloat}, Cuint), 
                image_ptr, col-1, row-1, buffer, mem)    
    if err == 0
        buffer # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end

function sl_mat_get_value_float2(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = SL_Vector2()
    err = ccall((:sl_mat_get_value_float2, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Ref{SL_Vector2}, Cuint), 
                image_ptr, col-1, row-1, Ref(buffer), mem)    
    if err == 0
        [buffer.x, buffer.y] # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end

function sl_mat_get_value_float3(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = SL_Vector3()
    err = ccall((:sl_mat_get_value_float3, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Ref{SL_Vector3}, Cuint), 
                image_ptr, col-1, row-1, Ref(buffer), mem)    
    if err == 0
        [buffer.x, buffer.y, buffer.z] # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end

function sl_mat_get_value_float4(image_ptr::Ptr{Cint}, col::T, row::T, mem::SL_MEM) where {T<:Integer}
    buffer = SL_Vector4()
    err = ccall((:sl_mat_get_value_float4, zed), 
                Cint, 
                (Ptr{Cint}, Cint, Cint, Ref{SL_Vector4}, Cuint), 
                image_ptr, col-1, row-1, Ref(buffer), mem)    
    if err == 0
        [buffer.x, buffer.y, buffer.z, buffer.w] # return an array?
    else
        error("$(SL_ERROR_CODE(err))")
    end
end

"""
Fills the entire Mat with the given value.

# Arguments
- ptr : Ptr to the Mat.
- value : the value with which to fill the Mat.
- mem : Whether Mat should exist on CPU or GPU memory (SL_MEM).

# Returns
ERROR_CODE::SUCCESS if everything went well, ERROR_CODE::FAILURE otherwise.
"""
function sl_mat_set_to_uchar(image_ptr::Ptr{Cint}, value::Cuchar, mem::SL_MEM)
    err = ccall((:sl_mat_set_to_uchar, zed), 
                Cint, 
                (Ptr{Cint}, Cuchar, Cuint), 
                image_ptr, value, mem)
    SL_ERROR_CODE(err)
end
function sl_mat_set_to_uchar(image_ptr::Ptr{Cint}, value::Vector{Cuchar}, mem::SL_MEM)
    length(value) != 1 && throw(ArgumentError("`value` is an array of 1 elements."))
    sl_mat_set_to_uchar(image_ptr, first(value), mem)
end

function sl_mat_set_to_uchar2(image_ptr::Ptr{Cint}, value::Vector{Cuchar}, mem::SL_MEM)
    length(value) != 2 && throw(ArgumentError("`value` is an array of 2 elements."))
    value1 = SL_Uchar2(value...)
    err = ccall((:sl_mat_set_to_uchar2, zed), 
                Cint, 
                (Ptr{Cint}, SL_Uchar2, Cuint), 
                image_ptr, value1, mem)
    SL_ERROR_CODE(err)
end

function sl_mat_set_to_uchar3(image_ptr::Ptr{Cint}, value::Vector{Cuchar}, mem::SL_MEM)
    length(value) != 3 && throw(ArgumentError("`value` is an array of 3 elements."))
    value1 = SL_Uchar3(value...)
    err = ccall((:sl_mat_set_to_uchar3, zed), 
                Cint, 
                (Ptr{Cint}, SL_Uchar3, Cuint), 
                image_ptr, value1, mem)
    SL_ERROR_CODE(err)
end

function sl_mat_set_to_uchar4(image_ptr::Ptr{Cint}, value::Vector{Cuchar}, mem::SL_MEM)
    length(value) != 4 && throw(ArgumentError("`value` is an array of 4 elements."))
    value1 = SL_Uchar4(value...)
    err = ccall((:sl_mat_set_to_uchar4, zed), 
                Cint, 
                (Ptr{Cint}, SL_Uchar4, Cuint), 
                image_ptr, value1, mem)
    SL_ERROR_CODE(err)
end

function sl_mat_set_to_float(image_ptr::Ptr{Cint}, value::Cfloat, mem::SL_MEM)
    err = ccall((:sl_mat_set_to_float, zed), 
                Cint, 
                (Ptr{Cint}, Cfloat, Cuint), 
                image_ptr, value, mem)
    SL_ERROR_CODE(err)
end
function sl_mat_set_to_float(image_ptr::Ptr{Cint}, value::Vector{Cfloat}, mem::SL_MEM)
    length(value) != 1 && throw(ArgumentError("`value` is an array of 1 elements."))
    sl_mat_set_to_float(image_ptr, first(value), mem)
end

function sl_mat_set_to_float2(image_ptr::Ptr{Cint}, value::Vector{Cfloat}, mem::SL_MEM)
    length(value) != 2 && throw(ArgumentError("`value` is an array of 2 elements."))
    value1 = SL_Vector2(value...)
    err = ccall((:sl_mat_set_to_float2, zed), 
                Cint, 
                (Ptr{Cint}, SL_Vector2, Cuint), 
                image_ptr, value1, mem)
    SL_ERROR_CODE(err)
end

function sl_mat_set_to_float3(image_ptr::Ptr{Cint}, value::Vector{Cfloat}, mem::SL_MEM)
    length(value) != 3 && throw(ArgumentError("`value` is an array of 3 elements."))
    value1 = SL_Vector3(value...)
    err = ccall((:sl_mat_set_to_float3, zed), 
                Cint, 
                (Ptr{Cint}, SL_Vector3, Cuint), 
                image_ptr, value1, mem)
    SL_ERROR_CODE(err)
end

function sl_mat_set_to_float4(image_ptr::Ptr{Cint}, value::Vector{Cfloat}, mem::SL_MEM)
    length(value) != 4 && throw(ArgumentError("`value` is an array of 4 elements."))
    value1 = SL_Vector4(value...)
    err = ccall((:sl_mat_set_to_float4, zed), 
                Cint, 
                (Ptr{Cint}, SL_Vector4, Cuint), 
                image_ptr, value1, mem)
    SL_ERROR_CODE(err)
end

# const sl_mat_get = Dict(
#     SL_MAT_TYPE_F32_C1 => (sl_mat_get_value_float),
# 	SL_MAT_TYPE_F32_C2 => (sl_mat_get_value_float2),
# 	SL_MAT_TYPE_F32_C3 => (sl_mat_get_value_float3),
# 	SL_MAT_TYPE_F32_C4 => (sl_mat_get_value_float4),
# 	SL_MAT_TYPE_U8_C1 =>(sl_mat_get_value_uchar),
# 	SL_MAT_TYPE_U8_C2 => (sl_mat_get_value_uchar2),
# 	SL_MAT_TYPE_U8_C3 => (sl_mat_get_value_uchar3),
# 	SL_MAT_TYPE_U8_C4 => (sl_mat_get_value_uchar4)
# )

"""
Get an image frame from `image_ptr` 
"""
function getframe(image_ptr::Ptr{Cint}, mateltype, sl_mat_get_value)
    width = sl_mat_get_width(image_ptr)::Cint
    height = sl_mat_get_height(image_ptr)::Cint
    nchannels = sl_mat_get_channels(image_ptr)::Cint

    mem = sl_mat_get_memory_type(image_ptr)
    #sl_mat_get_value = sl_mat_get[mattype] 
    mat = zeros(mateltype, height, width, nchannels) 
    for col ??? 1:width
        for row ??? 1:height
            mat[row,col,:] = sl_mat_get_value(image_ptr, col, row, mem)
        end
    end
    mat
end

"""
Reads an image from a file. Supports .png and .jpeg. Only works if Mat has access to MEM_CPU.

# Arguments
- ptr : Ptr to the Mat.
- file_path : File path, including file name and extension.

# Returns
ERROR_CODE::SUCCESS if everything went well, ERROR_CODE::FAILURE otherwise.
"""
function sl_mat_read(image_ptr::Ptr{Cint}, file_path::String)
    err = ccall((:sl_mat_read, zed), 
                Cint, 
                (Ptr{Cint}, Cstring),
                image_ptr, file_path)
    SL_ERROR_CODE(err)
end

"""
Writes the Mat into a file as an image. Only works if Mat has access to MEM_CPU.

# Argments
- ptr : Ptr to the Mat.
- file_path : File path, including file name and extension.

# Returns
ERROR_CODE::SUCCESS if everything went well, ERROR_CODE::FAILURE otherwise.
"""
function sl_mat_write(image_ptr::Ptr{Cint}, file_path::String)
    nchannels = sl_mat_get_channels(image_ptr)
    nchannels == 2 && throw(ArgumentError("Channel of 2 is not supported. Refer to https://www.stereolabs.com/docs/api/classsl_1_1Mat.html#accab3cb8c395f6b32c897e549fef78a8 for more details"))
    err = ccall((:sl_mat_write, zed), 
                Cint, 
                (Ptr{Cint}, Cstring),
                image_ptr, file_path)
    SL_ERROR_CODE(err)
end
