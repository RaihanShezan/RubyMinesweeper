######################################################################
########## Run minesweeper.rb in terminal to play this game ##########
######################################################################

require_relative 'game'

class Minesweeper
    def run
        player_name = get_player_name()
        cmd = get_command(player_name)

        begin
            case cmd
            when 'L' then g = load_saved(player_name)
            when ''
                difficulty = select_difficulty(player_name)
                g = Game.new(player_name, *difficulty)
            end
            g.play
        rescue SystemExit => e
            if e.status == 101
                system 'clear'
                until cmd == 'Y' || cmd == 'N'
                    print "Do you want to save the game? (Y/N) > "
                    cmd = gets.chomp.upcase
                end
                case cmd
                when 'Y' then save_game(player_name, g)                
                when 'N' then print "\nGame closed before completion\n\n"
                end
            end
        end
    end

    private

    def print_welcome(player_name = "")
        player = (player_name == "") ? "" : ("HI " + player_name.upcase + "! ")
        system "clear"
        print "\n\n" + "*"*70 + "\n"
        print "#{player}WELCOME TO MINESWEEPER".center(70)
        print "\n" + "*"*70 + "\n\n"
    end

    def get_player_name
        print_welcome()
        player_name = ""
        while player_name.empty?
            print "\nPlease enter your name > "
            player_name = gets.chomp.downcase
        end
        player_name
    end

    def get_command(player_name)
        print_welcome(player_name)
        print "Press"
        print "\n     > Enter to play a new game or"
        print "\n     > 'L' + Enter to load a previous game"
        print "\n\n> "
        cmd = gets.chomp.upcase
        until cmd == '' || cmd == 'L'
            print "\nWrong command. Try again > "
            cmd = gets.chomp.upcase
        end
        cmd
    end

    def select_difficulty(player_name)
        print_welcome(player_name)
        print "\nEnter board size to play (5 to 30) > "
        size = gets.chomp.to_i
        until size.between?(5, 30)
            print "\nEnter board size between 5 & 30 > "
            size = gets.chomp.to_i
        end

        print "\n\nChoose difficulty"
        lvl = "\n   > Level 1: Easy"
        lvl += "\n   > Level 2: Medium"
        lvl += "\n   > Level 3: Hard"
        print lvl
        print "\nEnter level number > "
        lvl_idx = gets.chomp.to_i
        until lvl_idx.between?(1,3)
            print "\nWrong level number. Try again > "
            lvl_idx = gets.chomp.to_i
        end
        [size, lvl_idx]
    end

    def load_saved(player_name)
        file_name = player_name.split.join("_")
        saved_games = Dir["saved/#{file_name}_*.yml"]
        print_welcome(player_name)
        if saved_games.empty?
            print "\nYou don't have any saved games.\n"
            exit 105
        else
            print "\nHere's the list of your saved games.\n"
            saved_games.each_with_index {|file, idx| print (idx + 1).to_s + ") " + file[6..-5] + "\n"}
            print "\nEnter file number to open > "
            idx = gets.chomp
            until idx.match?(/\d+/) && idx.to_i.between?(1, saved_games.length)
                print "\nWrong file number. Try again: "
                idx = gets.chomp
            end
            file = saved_games[idx.to_i - 1]
            YAML.load(File.read(file))
        end 
    end

    def save_game(player_name, game)
        file_name = player_name.split.join("_") + "_"
        file_count = Dir["saved/#{file_name}*.yml"]
        file_name += (file_count.length + 1).to_s
        File.open("saved/#{file_name}.yml", "w") { |file| file.write(game.to_yaml) }
        print "\nGame saved in file '#{file_name}'\n"
    end
end

if __FILE__ == $PROGRAM_NAME
    Minesweeper.new.run
end