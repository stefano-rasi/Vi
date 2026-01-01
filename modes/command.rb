class Vi
    def command(event)
        key = event.key

        case key
        when :Enter
            @command = nil

            @mode = :normal
        when :Escape
            @command = nil

            @mode = :normal
        else
            if key.length == 1
                @command = '' if !@command

                @command += key
            end
        end
    end
end