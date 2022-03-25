using Pkg
Pkg.activate(".")

using ZED

res_dict = Dict(
    "HD2K" => ZED.SL_RESOLUTION_HD2K,
    "HD1080" => ZED.SL_RESOLUTION_HD1080,
    "HD720" => ZED.SL_RESOLUTION_HD720,
    "VGA" => ZED.SL_RESOLUTION_VGA,
)

resolution_string = length(ARGS) < 1 ? "HD720" : ARGS[1]
resolution = res_dict[resolution_string]

@info "Resolution: $(resolution)"

# create a ZED camera
camera_id = 0
sl_create_camera(camera_id)

init_param = SL_InitParameters(camera_id)
init_param.resolution = resolution
init_param.camera_fps = 15
init_param.depth_maximum_distance = 40
init_param.depth_minimum_distance = -1
init_param.coordinate_unit = ZED.SL_UNIT_METER
init_param.camera_disable_self_calib = true # set to `true` for repeatability
init_param.enable_image_enhancement = true

# open the camera
state = sl_open_camera(camera_id, init_param, "", "", 0, "", "", "")
if state != SL_ERROR_CODE(0)
    error("Error Open")
end

rt_param = SL_RuntimeParameters()

root = length(ARGS) < 2 ? "./data/$(resolution_string)" : ARGS[2]

function u8c42rgba(x::AbstractArray{Cuchar,3})
    mapslices(x; dims=3) do x1
        GLMakie.RGBAf((x1[[3,2,1,4]] ./ 0xff)...)
    end |> a -> dropdims(a; dims=3)
end

imagewidth = sl_get_width(camera_id) 
imageheight = sl_get_height(camera_id) 

leftimage_dir = joinpath(root, "left")
rightimage_dir = joinpath(root, "right")

SL_MEM = ZED.SL_MEM_CPU
leftimage_ptr = sl_mat_create_new(imagewidth, 
                                    imageheight, 
                                    ZED.SL_MAT_TYPE_U8_C4, 
                                    SL_MEM)
rightimage_ptr = sl_mat_create_new(imagewidth, 
                                    imageheight, 
                                    ZED.SL_MAT_TYPE_U8_C4, 
                                    SL_MEM)
!isdir(leftimage_dir) && mkpath(leftimage_dir)
!isdir(rightimage_dir) && mkpath(rightimage_dir)

let 
    # leftimageviz = Observable(u8c42rgba(zeros(Cuchar, imageheight, imagewidth, 4)) |> rotr90)
    # rightimageviz = Observable(u8c42rgba(zeros(Cuchar, imageheight, imagewidth, 4)) |> rotr90)
    # fig = Figure(resolution = (1600, 700))
    # display(fig)
    # ax1 = Axis(fig[1,1], title = "Left")
    # ax2 = Axis(fig[1,2], title = "Right")
    # hidedecorations!(ax1)
    # hidedecorations!(ax2)
    # image!(ax1, leftimageviz)
    # image!(ax2, rightimageviz)
    i = 1

    while true
        state = sl_grab(camera_id, rt_param)
        if state == SL_ERROR_CODE(0)

            sl_retrieve_image(camera_id, 
                            leftimage_ptr, 
                            ZED.SL_VIEW_LEFT_UNRECTIFIED, # uncalibrated
                            SL_MEM, 
                            imagewidth, 
                            imageheight)
            #leftimage = getframe(leftimage_ptr, Cuchar, sl_mat_get_value_uchar4)
            #leftimageviz[] = u8c42rgba(leftimage) |> rotr90

            sl_retrieve_image(camera_id, 
                            rightimage_ptr, 
                            ZED.SL_VIEW_RIGHT_UNRECTIFIED, # uncalibrated
                            SL_MEM, 
                            imagewidth, 
                            imageheight)
            #rightimage = getframe(rightimage_ptr, Cuchar, sl_mat_get_value_uchar4)
            #rightimageviz[] = u8c42rgba(rightimage) |> rotr90
        
            filename = lpad("$(i)", 5, "0") * ".png"
            leftimage_path = joinpath(leftimage_dir, filename)
            rightimage_path = joinpath(rightimage_dir, filename)

            #savergba(leftimage, leftimage_path)
            #savergba(rightimage, rightimage_path)
            sl_mat_write(leftimage_ptr, leftimage_path)
            sl_mat_write(rightimage_ptr, rightimage_path)
            println("Frame #$(i) is saved.")
            i += 1
            
        end
    end
end

# function plot_save(camera_id, rt_param, root)

#     imagewidth = sl_get_width(camera_id) 
#     imageheight = sl_get_height(camera_id) 

#     leftimage_dir = joinpath(root, "left")
#     rightimage_dir = joinpath(root, "right")
    
#     SL_MEM = ZED.SL_MEM_CPU
#     leftimage_ptr = sl_mat_create_new(imagewidth, 
#                                         imageheight, 
#                                         ZED.SL_MAT_TYPE_U8_C4, 
#                                         SL_MEM)
#     rightimage_ptr = sl_mat_create_new(imagewidth, 
#                                         imageheight, 
#                                         ZED.SL_MAT_TYPE_U8_C4, 
#                                         SL_MEM)

#     leftimageviz = Observable(u8c42rgba(zeros(Cuchar, imageheight, imagewidth, 4)) |> rotr90)
#     rightimageviz = Observable(u8c42rgba(zeros(Cuchar, imageheight, imagewidth, 4)) |> rotr90)
#     fig = Figure(resolution = (1600, 700))
#     display(fig)
#     ax1 = Axis(fig[1,1], title = "Left")
#     ax2 = Axis(fig[1,2], title = "Right")
#     hidedecorations!(ax1)
#     hidedecorations!(ax2)
#     image!(ax1, leftimageviz)
#     image!(ax2, rightimageviz)
#     i = 1
#     # lefimages = Array{Cuchar}[]
#     # rightimages = Array{Cuchar}[]

#     while true
#         state = sl_grab(camera_id, rt_param)
#         if state == SL_ERROR_CODE(0)

#             sl_retrieve_image(camera_id, 
#                             leftimage_ptr, 
#                             ZED.SL_VIEW_LEFT_UNRECTIFIED, # uncalibrated
#                             SL_MEM, 
#                             imagewidth, 
#                             imageheight)
#             leftimage = getframe(leftimage_ptr, Cuchar, sl_mat_get_value_uchar4)
#             leftimageviz[] = u8c42rgba(leftimage) |> rotr90
#             #push!(leftimages, leftimage)

#             sl_retrieve_image(camera_id, 
#                             rightimage_ptr, 
#                             ZED.SL_VIEW_RIGHT_UNRECTIFIED, # uncalibrated
#                             SL_MEM, 
#                             imagewidth, 
#                             imageheight)
#             rightimage = getframe(rightimage_ptr, Cuchar, sl_mat_get_value_uchar4)
#             rightimageviz[] = u8c42rgba(rightimage) |> rotr90
#             #push!(rightimages, rightimage)

#             # filename = lpad("$(i)", 5, "0") * ".png"
#             # leftimage_path = joinpath(leftimage_dir, filename)
#             # rightimage_path = joinpath(rightimage_dir, filename)

#             #savergba(leftimage, leftimage_path)
#             #savergba(rightimage, rightimage_path)
#             # on(events(fig).keyboardbutton) do event
#             #     if event.key == Keyboard.s
#             #         filename = lpad("$(i)", 5, "0") * ".png"
#             #         leftimage_path = joinpath(leftimage_dir, filename)
#             #         rightimage_path = joinpath(rightimage_dir, filename)
#             #         savergba(leftimage, leftimage_path)
#             #         savergba(rightimage, rightimage_path)
#             #         println("Frame #$(i) is saved.")
#             #         i += 1
#             #     end
#             # end
#         end
#     end
# end

# plot_save(camera_id, rt_param, root)

sl_close_camera(camera_id)