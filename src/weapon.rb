class Bubble
	attr_accessor :life

	def initialize(who = 0)
		@skin = Gosu::Image.new("media/images/bubble.png")
		@life = 1
	end

	def hit
		@life -= 1
	end

	def draw(x, y)
		@skin.draw_rot(x, y, 3, 0)
	end
end