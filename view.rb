require 'lib/View/html'
require 'lib/View/view'

require 'lib/View/window'

require_relative 'view'

class ViView < View
    draw do
        HTML.div 'vi-view', "#{@mode}-mode" do
            HTML.div 'lines' do
                y = 0

                @lines.each do |line|
                    HTML.div 'line' do
                        x = 0

                        if line.empty?
                            HTML.div 'character', ('cursor' if x == @x && y == @y) do |element|
                                if x == @x && y == @y
                                    @cursor = element
                                end
                            end
                        else
                            line.each do |character|
                                HTML.div 'character', ('cursor' if x == @x && y == @y) do |element|
                                    _text character

                                    if x == @x && y == @y
                                        @cursor = element
                                    end
                                end

                                x += 1
                            end

                            if y == @y && @x == x
                                HTML.div 'character cursor last' do |element|
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
                        _text "--#{@mode}--"
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

    def initialize(text)
        @x = 0
        @y = 0

        @mode = :normal

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

        Window.addEventListener('keydown', &method(:on_keydown))
    end

    def text
        @lines.map { |line| line.join('') }.join("\n")
    end

    def scroll()
        @cursor.scrollIntoView({block: :nearest})
    end

    def on_keydown(event)
        event = Native(event)

        mode = @mode

        case mode
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
    end
end

Window.addEventListener('load') do
    vi = ViView.new("line 1\nline 2\nline 3\nline 4")

    Document.body.appendChild(vi.element)
end