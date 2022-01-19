module ZED

using Dates
using DocStringExtensions
using Images

include("utils.jl")
include("types.jl")
include("interface.jl")
include("mat.jl")
include("retrieve.jl")

const LIBDIR = joinpath(dirname(pathof(@__MODULE__)), "..", "lib")

const zed = if Sys.islinux()
                joinpath(LIBDIR, "Linux/libsl_zed_c.so")
            elseif Sys.iswindows()
                # TODO
                error("Not implemented")
            elseif Sys.isapple()
                # TODO
                error("Not implemented")
            end

end # module
