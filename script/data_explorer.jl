using Mux, WebIO
using Interact, Plots


const CHANNEL_NAMES = ["water", "rain", "winddir", "windlevel", "temp", "pressure", "humidity", "sun"]

function app(req) # req is a Mux request dictionary
    px=widget(0:0.01:.3, label="px")
    py=widget(0:0.01:.3, label="py")
    plane = widget(Dict("x=0" => 1, "y=0" => 2), label="Section plane")
    interactive_plot = map(plotsos, px, py, plane)
    return vbox(
        hbox(px, py, plane),
        interactive_plot)
end

function dashboard(req)
    options = Observable(CHANNEL_NAMES)
    return hbox(
        vbox(
            dropdown(CHANNEL_NAMES),
            dropdown(options))
            
    )
end


# Start server
webio_serve(page("/", dashboard), 8000)
# Keep program running
print("Server started. Press Enter to stop.")
readline(stdin)
print("bye.\n")
