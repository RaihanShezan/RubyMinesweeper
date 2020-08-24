require 'set'
require_relative 'cell'

class Board
    attr_reader :bomb_revealed, :size, :total_bombs
    def initialize(size, total_bombs)
        @board = Array.new(size) { Array.new(size) {Cell.new} }
        @size, @total_bombs = size, total_bombs
        @bomb_positions, @non_bombs = [], []
        @revealed_positions, @bomb_revealed = Set.new, false
        populate_board(total_bombs)
        cell([0,0]).selected = true
    end

    def select(pos)
        cell(pos).selected = true
    end

    def unselect(pos)
        cell(pos).selected = false
    end

    def flag_cell(pos)
        if cell(pos).revealed 
            print "\nCan't flag cell which is already revealed\n"
            sleep 2
        elsif cell(pos).flagged
            print "\nCell already flagged. Unflag first to reveal\n"
            sleep 2
        else
            cell(pos).flag
        end
    end

    def unflag_cell(pos)
        if cell(pos).revealed 
            print "\nCan't unflag cell which is already revealed\n"
            sleep 2
        elsif !cell(pos).flagged
            print "\nCell not flagged yet\n"
            sleep 2
        else
            cell(pos).unflag
        end
    end

    def reveal_cell(pos)
        if cell(pos).flagged 
            print "\nUnflag cell first to reveal\n"
            sleep 2
        elsif cell(pos).revealed
            print "\nCell already revealed\n"
            sleep 2
        else
            cell(pos).reveal
            if cell(pos).is_bomb
                @bomb_revealed = true 
                @bomb_positions.delete(pos)
            end
            @revealed_positions << pos
            reveal_neighbors(pos)
        end
    end
    
    def reveal_next_bomb
        if @bomb_positions.empty?
            false
        else
            cell(@bomb_positions.shift).reveal
            true
        end
    end

    def print_board
        puts "    #{(0...size).map{|i| i.to_s.center(3)}.join(" ")} ".on_black
        @board.each_with_index do |row, i|
            print "#{i}".center(4).on_black
            row.each {|cell| print "#{cell.print_cell} ".on_black}
            print " \n"
            print "#{" "*(size+1)*4}\n".on_black
        end
    end

    def solved?
        @non_bombs.all? {|pos| cell(pos).revealed}
    end

    def flag_count
        @board.flatten.count {|cell| cell.flagged}
    end

    private

    def populate_board(total_bombs)
        (0...size).each do |i| 
            (0...size).each {|j| @non_bombs << [i,j]}
        end
        @bomb_positions = @non_bombs.sample(total_bombs)        
        @bomb_positions.each do |pos|
            cell(pos).insert_bomb
            @non_bombs.delete(pos)
        end
        @non_bombs.each {|pos| number_cell(pos)}        
    end

    def number_cell(pos)
        cell(pos).value = get_neighbors(pos).count {|position| cell(position).is_bomb}
    end

    def get_neighbors(pos)
        neighbors = []
        x, y = pos
        (x-1..x+1).each do |r|
            (y-1..y+1).each do |c|
                neighbors << [r, c] if valid_position?([r,c]) && !(r == x && c == y)
            end
        end
        neighbors
    end

    def reveal_neighbors(pos)
        not_bomb = get_neighbors(pos).reject {|pos| cell(pos).is_bomb}
        to_reveal = not_bomb.reject {|pos| @revealed_positions.include?(pos)}

        return if get_neighbors(pos).any? {|n| cell(n).is_bomb}
        return if to_reveal.empty?

        to_reveal.each do |pos|
            cell(pos).reveal
            @revealed_positions << pos
            reveal_neighbors(pos)
        end
    end

    def cell(at_position)
        x, y = at_position
        @board[x][y]
    end

    def valid_position?(pos)
        x, y = pos
        x.between?(0,size-1) && y.between?(0,size-1)
    end
end