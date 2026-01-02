class Vi < View
    def insert(event)
        key = event.key

        handled = true

        case key
        when :Enter
            @lines.insert(@y + 1, [])

            @x = 0
            @y += 1
        when :Escape
            @x -= 1 if @x > 0

            @mode = :normal
        when :Backspace
            @lines[@y].delete_at(@x - 1)

            @x -= 1 if @x > 0
        else
            if key.length == 1
                @lines[@y].insert(@x, key)

                @x += 1
            else
                handled = false
            end
        end

        handled
    end
end