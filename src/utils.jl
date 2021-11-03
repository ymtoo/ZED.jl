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