require 'gosu'

class Tutorial < Gosu::Window
    def initialize
        super 640, 480
        @font = Gosu::Font.new(20)
        self.caption = "CASHMONEYBOMB"
        
        @background_image = Gosu::Image.new("media/cashback.jpeg", :tileable => true)

        @player = Player.new
        @player.warp(200, 340)

        @cash = Gosu::Image.load_tiles("media/Dollar-Bill-10.jpeg", 25, 25)
        @cashs = Array.new
        @font = Gosu::Font.new(20)

        @coin = Gosu::Image.load_tiles("media/coin.jpeg", 25, 25)
        @coins = Array.new
        @font = Gosu::Font.new(20)

        @bomb = Gosu::Image.load_tiles("media/bomb.jpeg", 25, 25)
        @bombs = Array.new
        @font = Gosu::Font.new(20)

        @f_screen = false
    end

    def update
        if @player.alive
            if Gosu.button_down? Gosu::KB_A or Gosu::button_down? Gosu::GP_LEFT
                @player.move_left
            end
            if Gosu.button_down? Gosu::KB_D or Gosu::button_down? Gosu::GP_RIGHT
                @player.move_right
            end

            @player.move
            @player.collect_cashs(@cashs)
            @player.collect_coins(@coins)
            @player.collect_bombs(@bombs)

            if rand(5) < 4 and @cashs.size < 7
                @cashs.push(Cash.new)
            end
            if rand(5) < 4 and @coins.size < 7
                @coins.push(Coin.new)
            end
            if rand(2) < 4 and @bombs.size < 4
                @bombs.push(Bomb.new)
            end
        else
            if Gosu.button_down? Gosu::KB_SPACE
                puts "key pressed"
                @player.set_up
            end
        end
    end

    def draw
        @player.draw
        @cashs.each { |cash| cash.draw}
        @coins.each { |coin| coin.draw}
        @bombs.each { |bomb| bomb.draw}
        @font.draw("Player 1: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::RED)
        # @font.draw("Lives: #{@player.lives}", 10, 10, 3.0, 1.0, 1.0, 0xffffffff)
        @background_image.draw(0, 0, ZOrder::BACKGROUND)

        lose_check
        f_screen_check
    end
        
    def f_screen_check
        if @f_screen
            @finish_image.draw(200, 50, ZOrder::UI)
            @font.draw("Final Score: #{@player.score}", 500, 600, ZOrder::UI, 2.0, 2.0, Gosu::Color::RED)
        end
    end

    def lose_check
        if @player.alive == false
            @font.draw("You lose. Press space to restart.", 85, 150, ZOrder::UI, 2.0, 2.0, Gosu::Color::RED)
        end
    end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end
end

module ZOrder
    BACKGROUND, CASHS, BOMBS, COINS, PLAYER, UI = *0..6
end

class Player
    attr_reader :alive

    def initialize
        @image = Gosu::Image.new("media/bigballer.jpeg") 
        @x = 0
        @y = 0
        # @lives = 3 
        @score = 0
        @alive = true
    end
    
    def set_up
        print "work"
        @score = 0
        @alive = true
    end
    
    def score
        @score
    end
    
    def collect_cashs(cashs)
        cashs.reject! { |cash| Gosu.distance(@x, @y, cash.x, cash.y) < 100 }
    end

    def collect_coins(coins)
        coins.reject! { |coin| Gosu.distance(@x, @y, coin.x, coin.y) < 70 }
    end

    def collect_bombs(bombs)
        bombs.reject! { |bomb| Gosu.distance(@x, @y, bomb.x, bomb.y) < 200 }
    end

    def collect_cashs(cashs)
        cashs.reject! do |cash|
            if Gosu.distance(@x, @y, cash.x, cash.y) < 35
                @score += 10
                true
            else
                false
            end
        end
    end

    def collect_bombs(bombs)
        bombs.reject! do |bomb|
            if Gosu.distance(@x, @y, bomb.x, bomb.y) < 100
                @alive = false
                true
            else
                false
            end
        end
    end

    def collect_coins(coins)
        coins.reject! do |coin|
            if Gosu.distance(@x, @y, coin.x, coin.y) < 50
                @score += 5
                true
            else
                false
            end
        end
    end
    
    def warp(x, y)
        @x, @y = x, y
    end
      
    def move_right
        @x += 7
    end
  
    def move_left
        @x -= 7 
    end
      
    def move
        @x %= 640
    end
    
    def draw
        @image.draw(@x, @y, 1)
    end

end

class Cash
    attr_reader :x, :y

    def initialize
        @image = Gosu::Image.new("media/Dollar-Bill-10.jpeg")
        @y = 0
        @x = @y = @velocity_x = @velocity_y = @angle = 0.0
        @x = rand * 640
    end

    def new_velocity
        @angle = rand * 360
        @velocity_x += Gosu::offset_x(@angle, 2.5)
        @velocity_y += Gosu::offset_y(@angle, 2.5)
    end

    def new_position
        @x = rand * 640
        @y = rand * 480

        if Math.sqrt((@x - 300)*(@x - 300)) <= 100
            @x = rand * 640
        end

        if Math.sqrt((@y - 300)*(@y - 300)) <= 100
            @y = rand * 640
        end
    end
    
    def move
        @y += 1.5
        @y %= 480

        @x += @velocity_x
        @y += @velocity_y
    end

    def draw
        @image.draw(@x, @y, 1)
        move
    end
    
end

class Coin
    attr_reader :x, :y

    def initialize
        @image = Gosu::Image.new("media/coin.jpeg")
        @y = 0
        @x = @y = @velocity_x = @velocity_y = @angle = 0.0
        @x = rand * 640
    end

    def new_velocity
        @angle = rand * 360
        @velocity_x += Gosu::offset_x(@angle, 2.5)
        @velocity_y += Gosu::offset_y(@angle, 2.5)
    end

    def new_position
        @x = rand * 640
        @y = rand * 480

        if Math.sqrt((@x - 300)*(@x - 300)) <= 100
            @x = rand * 640
        end

        if Math.sqrt((@y - 300)*(@y - 300)) <= 100
            @y = rand * 640
        end
    end
    
    def move
        @y += 3
        @y %= 480

        @x += @velocity_x
        @y += @velocity_y
    end

    def draw
        @image.draw(@x, @y, 1)
        move
    end

end


class Bomb
    attr_reader :x, :y

    def initialize
        @image = Gosu::Image.new("media/bomb.png")
        @y = 0
        @x = @y = @velocity_x = @velocity_y = @angle = 0.0
        @x = rand * 640
    end

    def new_velocity
        @angle = rand * 360
        @velocity_x += Gosu::offset_x(@angle, 2.5)
        @velocity_y += Gosu::offset_y(@angle, 2.5)

    end

    def new_position
        @x = rand * 640
        @y = rand * 480

        if Math.sqrt((@x - 300)*(@x - 300)) <= 100
            @x = rand * 640
        end

        if Math.sqrt((@y - 300)*(@y - 300)) <= 100
            @y = rand * 640
        end
    end
    
    def move
        @y += 5
        @y %= 480

        @x += @velocity_x
        @y += @velocity_y
    end

    def draw
        @image.draw(@x, @y, 1)
        move
    end
    
end

Tutorial.new.show