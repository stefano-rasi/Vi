require_relative 'mode/insert'
require_relative 'mode/normal'
require_relative 'mode/command'
require_relative 'mode/replace'

module ViEditor
    attr_reader :x
    attr_reader :y

    attr_reader :mode
    attr_reader :lines

    attr_reader :command
    attr_reader :pending
    attr_reader :multiplier

    def initialize(text, position=:start)
        @mode = :normal

        @history = []

        if text
            lines = text.split("\n")

            if lines.is_a? Array
                @lines = lines.map { |line| line.split('') }
            else
                @lines = [lines.split('')]
            end
        else
            @lines = [[]]
        end

        @x = 0

        if position == :end
            @y = @lines.length-1
        else
            @y = 0
        end
    end

    def text
        @lines.map { |line|
            line.join('')
        }.join("\n")
    end

    def scroll()
        @cursor.scrollIntoView({block: :nearest})
    end

    def history()
        @history << @lines.map { |line|
            line.clone
        }
    end

    def key(key, ctrl_key=false, alt_key=false)
        case @mode
        when :insert
            insert(key, ctrl_key, alt_key)
        when :normal
            normal(key, ctrl_key, alt_key)
        when :command
            command(key, ctrl_key, alt_key)
        when :replace
            replace(key, ctrl_key, alt_key)
        end
    end

    def on_quit(&block)
        if block_given?
            @on_close_block = block
        elsif @on_close_block
            @on_close_block.call()
        end
    end

    def on_save(&block)
        if block_given?
            @on_save_block = block
        elsif @on_save_block
            @on_save_block.call(text)
        end
    end
end