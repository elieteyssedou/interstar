class Smoke
	attr_reader :die
	def initialize(x, y, angle, who)
		@x = x
		@y = y
		@angle = angle
		if who == 1
			@animation = Gosu::Image::load_tiles("media/images/smoke.png", 32, 32, :tileable => false)
		else
			@animation = Gosu::Image::load_tiles("media/images/smokevs.png", 32, 32, :tileable => false)
		end
		@die = false
		@bool = false
	end

	def draw
		if @bool == false
			@t1 = Gosu::milliseconds / 100 % @animation.size
			@bool = true
		end
		t = Gosu::milliseconds / 100 % @animation.size
		@animation[(t - @t1)].draw_rot(@x, @y, 1, @angle)
		if t == @animation.size - 1
			@die = true
			@bool = false
		end
	end
end