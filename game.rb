require_relative 'board'
require 'yaml'
require 'io/console'

class Game
    attr_reader :size
    def initialize(player_name, size, difficulty)
        @board = Board.new(size, (size * difficulty))
        @player_name, @size, @difficulty = player_name, size, difficulty
        @attempts, @elapsed, @cursor_pos = 0, 0, [0,0]
    end

    def play
        starting = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @elapsed
        won, lost = false, false
        until won || lost
            system "clear"
            @board.print_board
            ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            @elapsed = ending - starting
            time_string = get_time_string(@elapsed)
            print "\nBombs: #{@board.total_bombs} | "
            print "Flags: #{@board.flag_count}/#{@board.total_bombs} | "
            print "Attempts: #{@attempts}\n"
            print "Time Elapsed: #{time_string}\n"
            make_a_move()
            @attempts += 1
            won, lost = @board.solved?, @board.bomb_revealed
        end
        
        if won
            system "clear"
            @board.print_board
            print "\nCongrats! You Won!\n"
            sleep 3
            save_and_print_score()
        elsif lost 
            print_lost_animation()
            print "\nYou Lost the Game\n"
            sleep 3
        end
    end

    private

    def get_time_string(elapsed)
        time_str = ""
        if elapsed < 60
            time_str = elapsed.to_i.to_s + " seconds"
        elsif elapsed < 3600
            time_str = (elapsed / 60).to_i.to_s + " minutes " + (elapsed % 60).to_i.to_s + " seconds"
        else
            time_str = (elapsed / 3600).to_i.to_s + " hours " + (elapsed / 60).to_i.to_s + " minutes " + (elapsed % 60).to_i.to_s + " seconds"
        end
        time_str
    end

    def make_a_move
        instructions = "\nInstructions:"
        instructions += "\n     > Press UP/DOWN/LEFT/RIGHT arrow key to navigate"
        instructions += "\n     > Press ENTER to reveal a cell"
        instructions += "\n     > Press SPACE to flag a cell"
        instructions += "\n     > Press BACKSPACE to unflag a cell"
        instructions += "\n     > Press ESCAPE to exit the game\n\n"
        
        print instructions
        cmd = get_command()
        case cmd
        when "\e[A" then move_cursor(-1, 0)
        when "\e[B" then move_cursor(1, 0)
        when "\e[C" then move_cursor(0, 1)
        when "\e[D" then move_cursor(0, -1)
        when "\r" then @board.reveal_cell(@cursor_pos)
        when " " then @board.flag_cell(@cursor_pos)
        when "\177" then @board.unflag_cell(@cursor_pos)
        when "\e" then exit 101
        else 
            puts "#{cmd.inspect} is not a valid key"
            sleep 2 
        end
    end

    def move_cursor(x_val, y_val)
        past_pos = @cursor_pos.dup
        @cursor_pos[0] = (@cursor_pos[0] + x_val) % size
        @cursor_pos[1] = (@cursor_pos[1] + y_val) % size
        @board.unselect(past_pos)
        @board.select(@cursor_pos)
    end

    def get_command
        STDIN.echo = false
        STDIN.raw!
      
        input = STDIN.getc.chr
        if input == "\e" then
          input << STDIN.read_nonblock(3) rescue nil
          input << STDIN.read_nonblock(2) rescue nil
        end
      ensure
        STDIN.echo = true
        STDIN.cooked!
      
        return input
    end

    def get_position
        pos = gets.chomp
        until pos.match?(/\d,\d/) && pos.split(",").map(&:to_i).all? {|i| i.between?(0, size-1)}
            print "\nInvalid position. Try again > "
            pos = gets.chomp
        end
        pos.split(",").map(&:to_i)
    end

    def print_lost_animation
        system "clear"
        while @board.reveal_next_bomb
            system "clear"
            @board.print_board
            sleep 0.2
        end
    end

    def save_and_print_score
        past_file = Dir["scores/#{@size}_#{@difficulty}.yml"]
        past_score = YAML.load(File.read("scores/#{@size}_#{@difficulty}.yml")) unless past_file.empty?
        scores = past_file.empty? ? [] : deep_dup(past_score)
        file = File.open("scores/#{@size}_#{@difficulty}.yml", "w+")
        current_score = [@player_name, @elapsed]
        scores << current_score
        scores.sort! {|a, b| a.last <=> b.last}
        scores = scores[0...20]
        file.write(scores.to_yaml)
        position = scores.index(current_score) || nil
        print_score(scores, position)
    end

    def deep_dup(array)
        array.map {|el| el.is_a?(Array) ? deep_dup(el) : el}
    end

    def print_score(scores, position)
        system "clear"
        if position.nil?
            print "You didn't make it within Top 20".center(60)
        else
            print "Wow! You positioned #{position+1} in top 20 list".center(60)
        end
        print "\n\n"
        print "Top 20 Scores".center(60)
        print "\n"
        print "Board size: #{@size} | Difficulty Level: #{@difficulty}".center(60)
        print "\n"
        print "="*60 + "\n\n\n"
        print "Player Name".center(30) + "Time to Solve".center(30)
        print "\n"
        print "="*60 + "\n"

        scores.each_with_index do |score, idx|
            if idx == position
                print score.first.center(30).colorize(:light_yellow).on_black
                print get_time_string(score.last).center(30).colorize(:light_yellow).on_black
            else                
                print score.first.center(30)
                print get_time_string(score.last).center(30)
            end
            print "\n" + "-"*60 + "\n"
        end
        sleep 5
    end
end