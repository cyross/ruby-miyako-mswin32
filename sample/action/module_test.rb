#encoding: utf-8
module Test1
  def update(*params)
    p params
  end
end

class Test2
  include Test1

  def update
    p "123"
  end
end

class Test3
  def initialize
    @d = Test2.new
  end

  def update(*param)
    @d.update(*param)
  end
end

c = Test3.new
c.update