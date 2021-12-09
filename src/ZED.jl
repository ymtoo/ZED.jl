module ZED

using Dates
using DocStringExtensions

include("utils.jl")
include("types.jl")
include("interface.jl")
include("mat.jl")
include("retrieve.jl")

const zed = if Sys.islinux()
                "../lib/Linux/libsl_zed_c.so"
            elseif Sys.iswindows()
                # TODO
                error("Not implemented")
            elseif Sys.isapple()
                # TODO
                error("Not implemented")
            end

end # module
