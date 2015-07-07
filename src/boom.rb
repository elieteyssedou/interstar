class Boom
	attr_reader :die
	def initialize(x, y, angle, who)
		@x = x
		@y = y
		@angle = angle
		@@sound = Gosu::Sample.new("media/samples/shot.mp3")
		if who == 1
			@animation = Gosu::Image::load_tiles("media/images/boomvs.png", 75, 70, :tileable => false)
		else
			@animation = Gosu::Image::load_tiles("media/images/boom.png", 75, 70, :tileable => false)
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
		@animation[(t - @t1)].draw_rot(@x, @y, 6, @angle)
		if t == @animation.size - 1
			@die = true
			@bool = false
		end
	end

	def self.play
		@@sound.play(0.2, 0.5)
	end
end