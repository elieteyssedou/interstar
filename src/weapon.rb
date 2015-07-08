class Bubble
	attr_accessor :life

	def initialize(who = 0)
		# @skin = Gosu::Image.new("media/images/bubble.png")
		if who == 1
			@animation = Gosu::Image::load_tiles("media/images/shieldvs.png", 192, 192, :tileable => false)
		elsif who == 2
			@animation = Gosu::Image::load_tiles("media/images/shield.png", 192, 192, :tileable => false)
		end
		@ti = Gosu::milliseconds / 100 % @animation.size
		@bool = false
		@life = 1
	end

	def hit
		@life -= 1
	end

	def draw(x, y)
		if @bool == false
			@t1 = Gosu::milliseconds / 100 % @animation.size
			@bool = true
		end
		t = Gosu::milliseconds / 100 % @animation.size
		@animation[(t - @t1)].draw_rot(x, y, 6, 0, 0.5, 0.45)
		if t == @animation.size - 1
			@die = true
			@bool = false
		end
		# @skin.draw_rot(x, y, 3, 0)
	end
end