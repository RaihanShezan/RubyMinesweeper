require 'colorize'

class Cell
    COLORS = [:light_yellow, :blue, :green, :magenta, :red, :light_blue, :light_green, :light_magenta, :light_red]

    attr_reader :is_bomb, :revealed, :flagged
    attr_accessor :value, :selected
    def initialize
        @value, @is_bomb, @revealed, @flagged, @selected = 0, false, false, false, false
    end

    def insert_bomb
        @value = "*"
        @is_bomb = true
    end

    def reveal
        @revealed = true
    end

    def flag
        @flagged = true
    end

    def unflag
        @flagged = false
    end

    def print_cell
        if @revealed
            val = (@value == 0) ? "   " : (" " + self.value.to_s + " ")
            case @value
            when '*' then print "💣 ".colorize(COLORS[0]).on_red
            when (1..8) 
                if @selected
                    print val.colorize(COLORS[@value]).on_light_white
                else
                    print val.colorize(COLORS[@value])
                end
            else 
                if @selected
                    print val.colorize(:light_black).on_light_white
                else
                    print val.colorize(:light_black)
                end
            end
        elsif @flagged
            print (" 🚩").colorize(:background => @selected ? :light_white : :light_black)
        else
            print ("   ").colorize(:background => @selected ? :light_white : :light_black)
        end
    end
end