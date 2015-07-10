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

		@lsthole = Gosu::milliseconds

		@width = @texture.width
		@height = @texture.height
		@life = 1
		@force = 3

		@launch.play(0.06, 2)
	end

	def hole_warp(x, y, angle)
		if (Gosu::milliseconds - @lsthole > 1000)
			@angle = angle + 90
			@x = x + Gosu::offset_x(@angle, 5)
			@y = y + Gosu::offset_y(@angle, 5)
			@vx = Gosu::offset_x(@angle, @vx) + Gosu::offset_x(@angle, 20)
			@vy = Gosu::offset_y(@angle, @vy) + Gosu::offset_y(@angle, 20)
			@lsthole = Gosu::milliseconds
		end
	end

	def hole_acc(angle)
		@vx += Gosu::offset_x(angle, 0.2)
		@vy += Gosu::offset_y(angle, 0.2)
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
			@texture.draw_rot(@x, @y, 1, @angle) 
			@life = -1 if @life == 0
		end
	end
end
