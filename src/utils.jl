export savergba, savedepth

"""
Get a nanosecond precision epoch timestamp to a datetime.

https://stackoverflow.com/questions/54195315/how-to-convert-a-nanosecond-precision-epoch-timestamp-to-a-datetime-in-julia
"""
function nanounix2datetime(x)
    sec = x ÷ 10^9
    ms = x ÷ 10^6 - sec * 10^3
    ns = x % 10^6
    origin = unix2datetime(sec)
    ms = Millisecond(ms)
    ns = Nanosecond(ns)
    origin + ms + ns
end

"""
Save a RGBA image to `path`.  
"""
function savergba(x::AbstractArray{Cuchar,3}, path::AbstractString)
    m, n, _ = size(x)
    img = zeros(BGRA, m, n)
    for i ∈ 1:m
        for j ∈ 1:n
            img[i,j] = RGBA((x[i,j,[3,2,1,4]] ./ 255)...)
        end
    end
    save(path, img) 
end

"""
Save a depth image to `path`.  
"""
function savedepth(x::AbstractArray{T,3}, path::AbstractString) where {T}
    m, n, _ = size(x)
    img = zeros(N0f16, m, n)
    normalized = (2 ^ 16 - 1)
    for i ∈ 1:m
        for j ∈ 1:n
            x1 = x[i,j,1]
            img[i,j] = if isnan(x1) || isinf(x1)
                T(0.0) # set to zero if it is NaN or Inf (undefined)
            else
               x1 ./ normalized
            end
        end
    end
    save(path, img) 
end
