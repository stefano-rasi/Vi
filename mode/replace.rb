class Vi < View
    def replace(event)
        key = event.key

        case key
        when :Escape
            @mode = :normal
        else
            if key.length == 1
                @lines[@y][@x] = key

                @mode = :normal
            end
        end
    end
end