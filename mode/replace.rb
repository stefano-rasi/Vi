class Vi < View
    def replace(event)
        if event.ctrlKey || event.altKey || event.metaKey
            false
        else
            key = event.key

            handled = true

            case key
            when :Escape
                @mode = :normal
            else
                if key.length == 1
                    @lines[@y][@x] = key

                    @mode = :normal
                else
                    handled = false
                end
            end

            handled
        end
    end
end