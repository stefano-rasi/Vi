class Vi < View
    def command(event)
        key = event.key

        handled = true

        case key
        when :Enter
            case @command
            when ':q'
                on_close()
            when ':w'
                on_save()
            end

            @command = nil

            @mode = :normal
        when :Escape
            @command = nil

            @mode = :normal
        else
            if key.length == 1
                @command = '' if !@command

                @command += key
            else
                handled = false
            end
        end

        handled
    end
end