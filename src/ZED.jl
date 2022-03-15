module ZED

using Requires
using DocStringExtensions

using Dates
using Images
using StaticArrays

include("utils.jl")
include("types.jl")
include("interface.jl")
include("mat.jl")
include("retrieve.jl")

const LIBDIR = joinpath(dirname(pathof(@__MODULE__)), "..", "lib")

const zed = if Sys.islinux()
                if Sys.ARCH == :x86_64
                    joinpath(LIBDIR, "Linux/x86_64/libsl_zed_c.so")
                elseif Sys.ARCH == :aarch64
                    joinpath(LIBDIR, "Linux/aarch64/libsl_zed_c.so")
                else
                    error("Not implemented")
                end
            elseif Sys.iswindows()
                # TODO
                error("Not implemented")
            elseif Sys.isapple()
                # TODO
                error("Not implemented")
            end

end # module
