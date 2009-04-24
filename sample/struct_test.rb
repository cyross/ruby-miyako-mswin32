SSTx = Struct.new(:a, :b, :c)

class TestX
  def initialize
    @v = SSTx.new(1,2,3)
  end
  def render_inner(a,b,c)
    puts a
    puts b
    puts c
  end
  def render
    render_inner(*@v)
  end
end

x = TestX.new
x.render