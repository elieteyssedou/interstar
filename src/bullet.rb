class Bullet
	attr_accessor :x, :y, :life
	attr_reader :texture, :sound, :width, :height

	def initialize(angle, x, y, vx, vy, who = 0)
		@who = who
		if (@who == 1)
			@texture = Gosu::Image.new("media/images/bullet.png")
		elsif (@who == 2)
			@texture = Gosu::Image.new("media/images/bulletvs.png")
		end
		@sound = Gosu::Sample.new("media/samples/shot.mp3")
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
	end

	def move(dt)
		@x += @vx * dt / 15
		@y += @vy * dt / 15
	end

	def draw
		if @life > -1
			@texture.draw_rot(@x, @y, 1, @angle) 
			@life = -1 if @life == 0
		end
	end
end