require 'lib/View/html'
require 'lib/View/view'
require 'lib/View/window'

require_relative 'mode/insert'
require_relative 'mode/normal'
require_relative 'mode/command'
require_relative 'mode/replace'

class Vi < View
    draw do
        HTML.div 'vi-view', "#{@mode}-mode", ('focus' if @focus) do |element|
            element.tabIndex = 0

            HTML.div 'lines' do
                y = 0

                @lines.each do |line|
                    HTML.div 'line' do
                        x = 0

                        if line.empty?
                            HTML.div 'character', ('cursor' if x == @x && y == @y) do |element|
                                _html '&nbsp;'

                                @cursor = element if x == @x && y == @y
                            end
                        else
                            line.each do |character|
                                HTML.div 'character', ('cursor' if x == @x && y == @y) do |element|
                                    if character == ' '
                                        _html '&nbsp;'
                                    else
                                        _text character
                                    end

                                    @cursor = element if x == @x && y == @y
                                end

                                x += 1
                            end

                            if y == @y && @x == x
                                HTML.div 'character cursor' do |element|
                                    @cursor = element
                                end
                            end
                        end
                    end

                    y += 1
                end
            end

            HTML.div 'status-bar' do
                if @mode == :command
                    HTML.div 'command' do
                        _text ":#{@command}"
                    end
                else
                    HTML.div 'mode' do
                        _text "--#{@mode.upcase}--"
                    end
                end

                if @pending || @multiplier
                    HTML.div 'pending' do |html|
                        _text "#{@pending}#{@multiplier}"
                    end
                end
            end
        end
    end

    def initialize(text, last=false)
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

        if last
            @y = @lines.length-1
        else
            @x = 0
        end

        @mode = :normal

        Window.addEventListener('keydown', &method(:on_keydown))
    end

    def text
        @lines.map { |line| line.join('') }.join("\n")
    end

    def focus()
        @element.focus()
    end

    def scroll()
        @cursor.scrollIntoView({block: :nearest})
    end

    def on_keydown(event)
        event = Native(event)

        if Document.activeElement == @element
            event.preventDefault()
            event.stopPropagation()

            case @mode
            when :normal
                normal(event)
            when :insert
                insert(event)
            when :replace
                replace(event)
            when :command
                command(event)
            end

            draw
            scroll
            focus
        end
    end

    def on_save(&block)
        if block_given?
            @on_save_block = block
        else
            @on_save_block.call(text)
        end
    end

    def on_close(&block)
        if block_given?
            @on_close_block = block
        else
            @on_close_block.call()
        end
    end
end