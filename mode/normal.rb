class Vi < View
    def normal(event)
        key = event.key

        if @multiplier
            multiplier = @multiplier
        else
            multiplier = 1
        end

        case key
        when ':'
            @command = ':'

            @mode = :command
        when '$'
            x = @lines[@y].length-1

            case @pending
            when 'c', 'd'
                (x - @x + 1).times { @lines[@y].delete_at(@x) }

                @x -= 1 if @x > 0
            else
                @x = x
            end

            @mode = :insert if @pending == 'c'
        when '0'
            @x = 0
        when '1'..'9'
            pending = @pending

            if @multiplier
                new_multiplier = (@multiplier.to_s + key).to_i
            else
                new_multiplier = key.to_i
            end
        when 'a'
            @x += 1 if !@lines[@y].empty?

            @mode = :insert
        when 'c'
            pending = 'c'
        when 'd'
            case @pending
            when 'd'
                @lines.delete_at(@y)

                @x = 0
                @y -= 1 if @y == @lines.length && @y > 0

                @lines = [[]] if @lines.empty?
            else
                pending = 'd'
            end
        when 'j'
            y = @y + [multiplier, @lines.length-1 - @y].min

            case @pending
            when 'd'
                (y - @y + 1).times { @lines.delete_at(@y) }

                @x = 0
                @y -= 1 if @y == @lines.length && @y > 0

                @lines = [[]] if @lines.empty?
            else
                @x = [0, [@x, @lines[y].length-1].min].max
                @y = y
            end
        when 'k'
            y = @y - [multiplier, @y].min

            case @pending
            when 'd'
                (@y - y + 1).times { @lines.delete_at(y) }

                @x = 0
                @y = [0, y - 1].max

                @lines = [[]] if @lines.empty?
            else
                @x = [0, [@x, @lines[y].length-1].min].max
                @y = y
            end
        when 'h'
            @x -= [multiplier, @x].min

            @mode = :insert if @pending == 'c'
        when 'l'
            @x += [0, [multiplier, @lines[@y].length-1 - @x].min].max

            @mode = :insert if @pending == 'c'
        when 'i'
            @mode = :insert
        when 'o'
            @lines.insert(@y + 1, [] * multiplier)

            @x = 0
            @y += 1

            @mode = :insert
        when 'r'
            @mode = :replace
        when 's'
            @lines[@y].delete_at(@x)

            @mode = :insert
        when 'x'
            @lines[@y].delete_at(@x)
        when 'A'
            @x = @lines[@y].length

            @mode = :insert
        when 'D'
            x = @lines[@y].length-1

            (x - @x + 1).times { @lines[@y].delete_at(@x) }

            @x -= 1 if @x > 0
        when 'G'
            @x = 0
            @y = @lines.length-1
        when 'J'
            @lines[@y] += @lines[@y + 1]

            @lines.delete_at(@y + 1)
        when 'O'
            @lines.insert(@y, [] * multiplier)

            @x = 0

            @mode = :insert
        when :Escape
            pending = nil
        else
            if key.length != 1
                pending = @pending

                new_multiplier = @multiplier
            end
        end

        @pending = pending

        @multiplier = new_multiplier
    end
end