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
                            if @mode == :insert && x == @x && y == @y
                                HTML.input 'cursor' do |input|
                                    @input = input
                                end
                            else
                                HTML.div 'character', ('cursor' if x == @x && y == @y) do |element|
                                    element.innerHtml '&nbsp;'

                                    if x == @x && y == @y
                                        @cursor = element
                                    end
                                end
                            end
                        else
                            line.each do |character|
                                if @mode == :insert && x == @x && y == @y
                                    HTML.input 'cursor' do |input|
                                        @input = input
                                    end
                                end

                                HTML.div 'character', ('cursor' if x == @x && y == @y) do |element|
                                    if character == ' '
                                        element.innerHtml = '&nbsp;'
                                    else
                                        element.textContent = character
                                    end

                                    if x == @x && y == @y
                                        @cursor = element
                                    end
                                end

                                x += 1
                            end

                            if @mode == :insert && y == @y && @x == x
                                HTML.input 'cursor' do |input|
                                    @input = input
                                end
                            end
                        end
                    end

                    y += 1
                end
            end

            HTML.div 'status-bar' do
                if @mode == :command
                    HTML.div 'command' do |element|
                        element.textContent = @command
                    end
                else
                    HTML.div 'mode' do |element|
                        element.textContent = "--#{@mode.upcase}--"
                    end
                end

                if @pending || @multiplier
                    HTML.div 'pending' do |element|
                        element.textContent = "#{@pending}#{@multiplier}"
                    end
                end
            end
        end
    end

    def initialize(text, last=false)
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

        if last
            @y = @lines.length-1
        else
            @y = 0
        end

        Window.addEventListener('keydown', &method(:on_keydown))
        Window.addEventListener('compositionend', &method(:on_compositionend))
    end

    def text
        @lines.map { |line| line.join('') }.join("\n")
    end

    def focus()
        if @mode == :insert
            @input.focus()
        else
            @element.focus()
        end
    end

    def scroll()
        @cursor.scrollIntoView({block: :nearest})
    end

    def history()
        @history << @lines.map { |line|
            line.clone
        }
    end

    def on_keydown(event)
        event = Native(event)

        if [@input, @element].include? Document.activeElement
            handled = nil

            case @mode
            when :normal
                handled = normal(event)
            when :insert
                handled = insert(event)
            when :replace
                handled = replace(event)
            when :command
                handled = command(event)
            end

            if handled != false
                event.preventDefault()
                event.stopPropagation()

                draw
                scroll
                focus
            end
        end
    end

    def on_compositionend(event)
        event = Native(event)

        event.data.split('').each do |character|
            @lines[@y].insert(@x, character)

            @x += 1
        end

        draw
        scroll
        focus
    end

    def on_save(&block)
        if block_given?
            @on_save_block = block
        elsif @on_save_block
            @on_save_block.call(text)
        end
    end

    def on_close(&block)
        if block_given?
            @on_close_block = block
        elsif @on_close_block
            @on_close_block.call()
        end
    end
end