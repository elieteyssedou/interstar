class Asteroid
	attr_reader :x, :y, :force, :angle, :width, :height, :who
	attr_accessor :life, :die

	def initialize
		@i = rand(1..4)
		if @i == 1
			@animation = Gosu::Image::load_tiles("media/images/rocks.png", 256, 256, :tileable => false)
		else
			@animation = Gosu::Image::load_tiles("media/images/asteroid.png", 128, 128, :tileable => false)
		end

		r = rand(1..2)
		if r == 1
			@x = rand(-WinX..-64)
		else
			@x = rand(WinX + 64..(WinX * 2))
		end
		r = rand(1..2)
		if r == 1
			@y = rand(-WinY..-64)
		else
			@y = rand(WinY + 64..(WinY * 2))
		end
		
		r1 = rand((WinX / 5)..(WinX / 5 * 4))
  		r2 = rand((WinY / 5)..(WinY / 5 * 4))
		@angle = Gosu::angle(@x, @y, r1, r2)
		@vx = Gosu::offset_x(@angle, rand(4..10))
		@vy = Gosu::offset_y(@angle, rand(4..10))

		@lst_hole = Gosu::milliseconds
		
		@who = 3
		@life = 2
		@life += 1 if @i == 1
		@force = 3
		@angle = 0

		@width = @animation[0].width
		@height = @animation[0].height

		@bool = false
		@die = false
		@pass = false
	end

	def hit(force, angle)
		if @i != 1
			@vx = @vx + Gosu::offset_x(angle, @vx / 4)
			@vy = @vx + Gosu::offset_y(angle, @vx / 4)
		end
		@life -= force
		# @boom.play(0.4, 2) if @life <= 0
		@die = true if @life <= 0
	end

	def hole_warp(x, y, angle)
		if (Gosu::milliseconds - @lst_hole > 3000)
			@angle = angle + 90
			@x = x + Gosu::offset_x(@angle, 5)
			@y = y + Gosu::offset_y(@angle, 5)
			@vx = Gosu::offset_x(@angle, @vx) + Gosu::offset_x(@angle, 5)
			@vy = Gosu::offset_y(@angle, @vy) + Gosu::offset_y(@angle, 5)
			@lst_hole = Gosu::milliseconds
			return 1
		else
			return 0
		end
	end

	def hole_acc(angle)
		if @i == 1
			@vx += Gosu::offset_x(angle, 0.05)
			@vy += Gosu::offset_y(angle, 0.05)
		else
			@vx += Gosu::offset_x(angle, 0.2)
			@vy += Gosu::offset_y(angle, 0.2)
		end
	end

	def lst_hole
		Gosu::milliseconds - @lst_hole
	end

	def move(dt)
		@x += @vx * dt / 15
		@y += @vy * dt / 15
		@pass = true if (@x < WinX && @x > 0 ) && (@y < WinY && @y > 0)
		@die = true if @pass == true && (@x > WinX + 64 || @x < 0 - 64) && (@y > WinY + 64 || @y < 0 - 64)
	end

	def draw
		if @bool == false
			@t1 = Gosu::milliseconds / 20 % @animation.size / 2
			@bool = true
		end
		t = Gosu::milliseconds / 20 % @animation.size / 2
		@animation[(t - @t1)].draw_rot(@x, @y, 6, @angle)
		if t == @animation.size / 2 - 1
			# @die = true
			@bool = false
		end
	end
end