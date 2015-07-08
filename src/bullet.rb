class Rocket
	attr_accessor :x, :y, :life, :force
	attr_reader :texture, :width, :height, :angle, :who

	def initialize(angle, x, y, vx, vy, who = 0)
		@who = who
		if (@who == 1)
			@texture = Gosu::Image.new("media/images/rocket.png")
		elsif (@who == 2)
			@texture = Gosu::Image.new("media/images/rocketvs.png")
		end
		@boom = Gosu::Sample.new("media/samples/boom.mp3")
		@launch = Gosu::Sample.new("media/samples/rocket.mp3")
		@x = x
		@y = y
		@vx = vx
		@vy = vy
		@angle = angle
		@vx += Gosu::offset_x(@angle, 5.0)
		@vy += Gosu::offset_y(@angle, 5.0)

		@width = @texture.width
		@height = @texture.height
		@life = 1
		@force = 3

		@launch.play(0.06, 2)
	end

	def boom
		@boom.play(0.10, 1)
	end

	def move(dt)
		@x += @vx * dt / 12
		@y += @vy * dt / 12
	end

	def draw
		if @life > -1
			@texture.draw_rot(@x, @y, 2, @angle) 
			@life = -1 if @life == 0
		end
	end
end

class Bullet
	attr_accessor :x, :y, :life, :force
	attr_reader :texture, :width, :height, :angle, :who

	def initialize(angle, x, y, vx, vy, who = 0)
		@who = who
		if (@who == 1)
			@texture = Gosu::Image.new("media/images/bullet.png")
		elsif (@who == 2)
			@texture = Gosu::Image.new("media/images/bulletvs.png")
		end
		@boom = Gosu::Sample.new("media/samples/shot.mp3")
		@launch = Gosu::Sample.new("media/samples/punch.mp3")
		@x = x
		@y = y
		@vx = vx
		@vy = vy
		@angle = angle
		@vx += Gosu::offset_x(@angle, 5.0)
		@vy += Gosu::offset_y(@angle, 5.0)

		@width = @texture.width
		@height = @texture.height
		@life = 1
		@force = 1

		@launch.play(0.08, 0.5)
	end

	def boom
		@boom.play(0.15, 1)
	end

	def move(dt)
		@x += @vx * dt / 10
		@y += @vy * dt / 10
	end

	def draw
		if @life > -1
			@texture.draw_rot(@x, @y, 2, @angle) 
			@life = -1 if @life == 0
		end
	end
end