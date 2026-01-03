class Vi < View
    def normal(event)
        key = event.key

        handled = true

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

            if @pending == 'd'
                history

                (x - @x + 1).times do
                    @lines[@y].delete_at(@x)
                end

                @x = [@x - 1, 0].max
            else
                @x = x
            end
        when '0'
            if @multiplier
                new_multiplier = (@multiplier.to_s + key).to_i
            else
                @x = 0
            end
        when '1'..'9'
            pending = @pending

            if @multiplier
                new_multiplier = (@multiplier.to_s + key).to_i
            else
                new_multiplier = key.to_i
            end
        when 'a'
            history

            if !@lines[@y].empty?
                @x += 1
            end

            @mode = :insert
        when 'd'
            if @pending == 'd'
                history

                @lines.delete_at(@y)

                @x = 0

                if @y == @lines.length
                    @y = [@y - 1, 0].max
                end

                @lines = [[]] if @lines.empty?
            else
                pending = 'd'
            end
        when 'j'
            y = @y + [multiplier, @lines.length-1 - @y].min

            if @pending == 'd'
                history

                (y - @y + 1).times do
                    @lines.delete_at(@y)
                end

                @x = 0

                if @y == @lines.length
                    @y = [@y - 1, 0].max
                end

                @lines = [[]] if @lines.empty?
            else
                @x = [[@x, @lines[y].length-1].min, 0].max
                @y = y
            end
        when 'k'
            y = @y - [multiplier, @y].min

            if @pending == 'd'
                history

                (@y - y + 1).times do
                    @lines.delete_at(y)
                end

                @x = 0
                @y = [y - 1, 0].max

                @lines = [[]] if @lines.empty?
            else
                @x = [[@x, @lines[y].length-1].min, 0].max
                @y = y
            end
        when 'h'
            @x -= [multiplier, @x].min
        when 'l'
            @x += [[multiplier, @lines[@y].length-1 - @x].min, 0].max
        when 'i'
            history

            @mode = :insert
        when 'p'
            history

            if @yank
                @lines.insert(@y, @yank)

                @y += 1
            end
        when 'o'
            history

            @lines.insert(@y + 1, [] * multiplier)

            @x = 0
            @y += 1

            @mode = :insert
        when 'r'
            @mode = :replace
        when 's'
            history

            @lines[@y].delete_at(@x)

            @mode = :insert
        when 'u'
            if !@history.empty?
                @lines = @history.pop

                if @y >= @lines.length
                    @y = [@lines.length-1, 0].max
                end

                if @x >= @lines[@y].length
                    @x = [@lines[@y].length-1, 0].max
                end
            end
        when 'x'
            history

            @lines[@y].delete_at(@x)

            if @x >= @lines[@y].length
                @x = @lines[@y].length-1
            end
        when 'y'
            if @pending == 'y'
                @yank = @lines[@y].clone
            else
                pending = 'y'
            end
        when 'A'
            history

            @x = @lines[@y].length

            @mode = :insert
        when 'D'
            history

            x = @lines[@y].length-1

            (x - @x + 1).times do
                @lines[@y].delete_at(@x)
            end

            @x = [@x - 1, 0].max
        when 'G'
            @x = 0
            @y = @lines.length-1
        when 'H'
            @x = 0
            @y = 0
        when 'J'
            history

            @lines[@y] += @lines[@y + 1]

            @lines.delete_at(@y + 1)
        when 'O'
            history

            @lines.insert(@y, [] * multiplier)

            @x = 0

            @mode = :insert
        when :Escape
            pending = nil
        else
            if key.length != 1 || event.ctrlKey
                handled = false

                pending = @pending

                new_multiplier = @multiplier
            end
        end

        @pending = pending

        @multiplier = new_multiplier

        handled
    end
end