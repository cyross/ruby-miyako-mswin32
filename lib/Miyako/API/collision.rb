# -*- encoding: utf-8 -*-
=begin
--
Miyako v2.1
Copyright (C) 2007-2009  Cyross Makoto

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
++
=end

module Miyako
  #==矩形当たり判定領域(コリジョン)クラス
  # コリジョンの範囲は、元データ(スプライト等)の左上端を[0.0,0.0]として考案する
  # コリジョンで使用する値は、実数での設定が可能
  class Collision
    # 関連づけられたインスタンス
    attr_reader :body
    # コリジョンの範囲([x,y,w,h])
    attr_reader :rect
    # コリジョンの中心点([x,y])
    attr_reader :center
    # コリジョンの半径
    attr_reader :radius

    #===コリジョンのインスタンスを作成する
    # 幅・高さが0以下のときは例外が発生する
    # 内部では、矩形当たり判定相手の時でも対応できるように矩形情報に変換して同時に持っている。
    # そのとき、引数circumがtrueのときは、円を矩形の外接円と認識して、内部の矩形(正方形)の長さを算出する。
    # circumがfalseのときは、円を矩形の内接円と認識して、内部の矩形(正方形)の長さを算出する。
    #_rect_:: コリジョンを設定する範囲
    #_circum_:: 矩形当たり判定とみなす時、円を外接円とするときはtrueを設定する。デフォルトはtrue
    #返却値:: 作成されたコリジョン
    def initialize(rect, circum = true)
      @rect = Rect.new(*(rect.to_a[0..3]))
      raise MiyakoValueError, "Illegal width! #{@rect[2]}" if @rect[2] < Float::EPSILON
      raise MiyakoValueError, "Illegal height! #{@rect[3]}" if @rect[3] < Float::EPSILON
      w = @rect[2].to_f
      h = @rect[2].to_f
      @center = Point.new(@rect[0].to_f + w / 2.0, @rect[1].to_f + h / 2.0)
      @radius = circum ? Math.sqrt(w ** 2 + h ** 2) / 2.0 : [w, h].min / 2.0
      @body = nil
    end

    def initialize_copy(obj) #:nodoc:
      @rect = @rect.dup
      @center = @center.dup
    end

    #===当たり判定とインスタンスを関連づける
    #当たり判定と、それをもとにしたインスタンスとの関連がわかりにくいときに使用する
    #引数にcollision=メソッドの有無を調査して、持っているときは、collision=メソッドを
    #自分自身を引数にして呼び出す(collision=メソッドを持っているのは現状でSpriteクラスのみ)
    #_obj_:: 関連づける元のインスタンス
    #返却値:: 自分自身を帰す
    def bind(obj)
      @body = obj
      @body.collision = self if @body.class.method_defined?(:collision=)
      return self
    end

    #===CollisionExクラスのインスタンスを生成する
    #自分自身に位置情報を渡してCollisionExクラスのインスタンスを生成する
    #_pos_:: CollisionEx生成時に渡す位置。省略時は[0,0]
    #返却値:: CollisionEx構造体
    def to_ex(pos=[0,0])
      CollisionEx.new(@rect, pos)
    end

    #===当たり判定を行う(領域が重なっている)
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def collision?(pos1, c2, pos2)
      return Collision.collision?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(領域がピクセル単位で隣り合っている)
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が隣り合っていれば true を返す
    def meet?(pos1, c2, pos2)
      return Collision.meet?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(どちらかの領域がもう一方にすっぽり覆われている))
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def cover?(pos1, c2, pos2)
      return Collision.cover?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(レシーバがc2を覆っている)
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def covers?(pos1, c2, pos2)
      return Collision.covers?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(レシーバがc2に覆われている)
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def covered?(pos1, c2, pos2)
      return Collision.covered?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(領域が重なっている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def Collision.collision?(c1, pos1, c2, pos2)
      l1 = pos1[0] + c1.rect[0]
      t1 = pos1[1] + c1.rect[1]
      r1 = l1 + c1.rect[2] - 1
      b1 = t1 + c1.rect[3] - 1
      l2 = pos2[0] + c2.rect[0]
      t2 = pos2[1] + c2.rect[1]
      r2 = l2 + c2.rect[2] - 1
      b2 = t2 + c2.rect[3] - 1
      v =  0
      v |= 1 if l1 <= l2 && l2 <= r1
      v |= 1 if l1 <= r2 && r2 <= r1
      v |= 2 if t1 <= t2 && t2 <= b1
      v |= 2 if t1 <= b2 && b2 <= b1
      return v == 3
    end

    #===当たり判定を行う(領域がピクセル単位で隣り合っている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が隣り合っていれば true を返す
    def Collision.meet?(c1, pos1, c2, pos2)
      l1 = pos1[0] + c1.rect[0]
      t1 = pos1[1] + c1.rect[1]
      r1 = l1 + c1.rect[2]
      b1 = t1 + c1.rect[3]
      l2 = pos2[0] + c2.rect[0]
      t2 = pos2[1] + c2.rect[1]
      r2 = l2 + c2.rect[2]
      b2 = t2 + c2.rect[3]
      v =  0
      v |= 1 if r1 == l2
      v |= 1 if b1 == t2
      v |= 1 if l1 == r2
      v |= 1 if t1 == b2
      return v == 1
    end

    #===当たり判定を行う(どちらかの領域がもう一方にすっぽり覆われている))
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def Collision.cover?(c1, pos1, c2, pos2)
      l1 = pos1[0] + c1.rect[0]
      t1 = pos1[1] + c1.rect[1]
      r1 = l1 + c1.rect[2]
      b1 = t1 + c1.rect[3]
      l2 = pos2[0] + c2.rect[0]
      t2 = pos2[1] + c2.rect[1]
      r2 = l2 + c2.rect[2]
      b2 = t2 + c2.rect[3]
      v =  0
      v |= 1 if l1 >= l2 && r1 <= r2
      v |= 2 if t1 >= t2 && b1 <= b2
      v |= 4 if l2 >= l1 && r2 <= r1
      v |= 8 if t2 >= t1 && b2 <= b1
      return v & 3 == 3 || v & 12 == 12
    end

    #===当たり判定を行う(c1がc2を覆っている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def Collision.covers?(c1, pos1, c2, pos2)
      l1 = pos1[0] + c1.rect[0]
      t1 = pos1[1] + c1.rect[1]
      r1 = l1 + c1.rect[2]
      b1 = t1 + c1.rect[3]
      l2 = pos2[0] + c2.rect[0]
      t2 = pos2[1] + c2.rect[1]
      r2 = l2 + c2.rect[2]
      b2 = t2 + c2.rect[3]
      v =  0
      v |= 1 if l2 >= l1 && r2 <= r1
      v |= 2 if t2 >= t1 && b2 <= b1
      return v & 3 == 3
    end

    #===当たり判定を行う(c1がc2に覆われている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def Collision.covered?(c1, pos1, c2, pos2)
      l1 = pos1[0] + c1.rect[0]
      t1 = pos1[1] + c1.rect[1]
      r1 = l1 + c1.rect[2]
      b1 = t1 + c1.rect[3]
      l2 = pos2[0] + c2.rect[0]
      t2 = pos2[1] + c2.rect[1]
      r2 = l2 + c2.rect[2]
      b2 = t2 + c2.rect[3]
      v =  0
      v |= 1 if l1 >= l2 && r1 <= r2
      v |= 2 if t1 >= t2 && b1 <= b2
      return v & 3 == 3
    end

    #== インスタンスの内容を解放する
    #返却値:: なし
    def dispose
      @rect = nil
    end
  end

  #==円形当たり判定領域(サークルコリジョン)クラス
  # 円形の当たり判定を実装する。
  # コリジョンは中心位置と半径で構成され、円形当たり判定同士で衝突判定を行う
  # コリジョンで使用する値は、実数での設定が可能
  class CircleCollision
    extend Forwardable

    # 関連づけられたインスタンス
    attr_reader :body
    # コリジョンの中心点([x,y])
    attr_reader :center
    # コリジョンの半径
    attr_reader :radius
    # コリジョンの範囲([x,y,w,h])
    attr_reader :rect

    #===コリジョンのインスタンスを作成する
    # コリジョンの半径が0もしくはマイナスのとき例外が発生する
    # 内部では、矩形当たり判定相手の時でも対応できるように矩形情報に変換して同時に持っている。
    # そのとき、引数circumがtrueのときは、円を矩形の外接円と認識して、内部の矩形(正方形)の長さを算出する。
    # circumがfalseのときは、円を矩形の内接円と認識して、内部の矩形(正方形)の長さを算出する。
    #_center_:: コリジョンを設定する範囲
    #_radius_:: コリジョンの半径
    #_circum_:: 矩形当たり判定とみなす時、円を外接円とするときはtrueを設定する。デフォルトはtrue
    #返却値:: 作成されたコリジョン
    def initialize(center, radius, circum = true)
      raise MiyakoValueError, "illegal radius! #{radius}" if radius < Float::EPSILON
      @center = Point.new(*(center.to_a[0..1]))
      @radius = radius
      if circum
        rad = @radius.to_f / Math.sqrt(2.0)
        @rect = Rect.new(@center[0]-rad, @center[1]-rad, rad*2.0, rad*2.0)
      else
        @rect = Rect.new(@center[0]-@radius, @center[1]-@radius, @radius*2.0, @radius*2.0)
      end
      @body = nil
    end

    def initialize_copy(obj) #:nodoc:
      @rect = @rect.dup
      @center = @center.dup
    end

    #===当たり判定とインスタンスを関連づける
    #当たり判定と、それをもとにしたインスタンスとの関連がわかりにくいときに使用する
    #引数にcollision=メソッドの有無を調査して、持っているときは、collision=メソッドを
    #自分自身を引数にして呼び出す(collision=メソッドを持っているのは現状でSpriteクラスのみ)
    #_obj_:: 関連づける元のインスタンス
    #返却値:: 自分自身を帰す
    def bind(obj)
      @body = obj
      @body.collision = self if @body.class.method_defined?(:collision=)
      return self
    end

    #===CircleCollisionExクラスのインスタンスを生成する
    #自分自身に位置情報を渡してCircleCollisionExクラスのインスタンスを生成する
    #_pos_:: CircleCollisionEx生成時に渡す位置。省略時は[0,0]
    #返却値:: CircleCollisionEx構造体
    def to_ex(pos=[0,0])
      CircleCollisionEx.new(@center, @radius, pos)
    end

    #===当たり判定間の距離を算出する
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def interval(pos1, c2, pos2)
      return CircleCollision.interval(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(領域が重なっている)
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def collision?(pos1, c2, pos2)
      return CircleCollision.collision?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(領域がピクセル単位で隣り合っている)
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が隣り合っていれば true を返す
    def meet?(pos1, c2, pos2)
      return CircleCollision.meet?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(どちらかの領域がもう一方にすっぽり覆われている))
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def cover?(pos1, c2, pos2)
      return CircleCollision.cover?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(レシーバがc2を覆っている)
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def covers?(pos1, c2, pos2)
      return CircleCollision.covers?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(レシーバがc2に覆われている)
    #_pos1_:: 自分自身の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def covered?(pos1, c2, pos2)
      return CircleCollision.covered?(self, pos1, c2, pos2)
    end

    #===当たり判定間の距離を算出する
    # ２つの当たり判定がどの程度離れているかを算出する。
    # 返ってくる値は、衝突していなければ正の実数、衝突していれば負の実数で返ってくる
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 当たり判定間の距離
    def CircleCollision.interval(c1, pos1, c2, pos2)
      #2点間の距離を求める
      d = Math.sqrt((((c1.center[0].to_f + pos1[0].to_f) - (c2.center[0].to_f + pos2[0].to_f)) ** 2) +
                    (((c1.center[1].to_f + pos1[1].to_f) - (c2.center[1].to_f + pos2[1].to_f)) ** 2))
      #半径の和を求める
      r  = c1.radius.to_f + c2.radius.to_f
      distance = d - r
      return distance.abs < Float::EPSILON ? 0.0 : distance
    end

    #===当たり判定を行う(領域が重なっている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def CircleCollision.collision?(c1, pos1, c2, pos2)
      #2点間の距離を求める
      d = (((c1.center[0] + pos1[0]) - (c2.center[0] + pos2[0])) ** 2) +
          (((c1.center[1] + pos1[1]) - (c2.center[1] + pos2[1])) ** 2)
      #半径の和を求める
      r  = (c1.radius + c2.radius) ** 2
      return d <= r
    end

    #===当たり判定を行う(領域がピクセル単位で隣り合っている)
    # 但し、実際の矩形範囲が偶数の時は性格に判定できない場合があるため注意
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が隣り合っていれば true を返す
    def CircleCollision.meet?(c1, pos1, c2, pos2)
      #2点間の距離を求める
      d = (((c1.center[0] + pos1[0]) - (c2.center[0] + pos2[0])) ** 2) +
          (((c1.center[1] + pos1[1]) - (c2.center[1] + pos2[1])) ** 2)
      #半径の和を求める
      r  = (c1.radius + c2.radius) ** 2
      return d == r
    end

    #===当たり判定を行う(どちらかの領域がもう一方にすっぽり覆われている))
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def CircleCollision.cover?(c1, pos1, c2, pos2)
      #2点間の距離を求める
      d = ((c1.center[0] + pos1[0]) - (c2.center[0] + pos2[0])) ** 2 +
          ((c1.center[1] + pos1[1]) - (c2.center[1] + pos2[1])) ** 2
      #半径の差分を求める
      r  = c1.radius ** 2 - 2 * (c1.radius * c2.radius) + c2.radius ** 2
      return d <= r
    end

    #===当たり判定を行う(c1がc2を覆っている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def CircleCollision.covers?(c1, pos1, c2, pos2)
      #2点間の距離を求める
      d = ((c1.center[0] + pos1[0]) - (c2.center[0] + pos2[0])) ** 2 +
          ((c1.center[1] + pos1[1]) - (c2.center[1] + pos2[1])) ** 2
      #半径の差分を求める
      r1 = c1.radius
      r2 = c2.radius
      r  = r1 ** 2 - 2 * (r1 * r2) + r2 ** 2
      return r1 >= r2 && d <= r
    end

    #===当たり判定を行う(c1がc2に覆われている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_pos1_:: c1の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #_pos2_:: c2の位置(Point/Rect/Square構造体、2要素以上の配列、もしくはx,yメソッドを持つインスタンス)
    #返却値:: 領域が覆われていれば true を返す
    def CircleCollision.covered?(c1, pos1, c2, pos2)
      #2点間の距離を求める
      d = ((c1.center[0] + pos1[0]) - (c2.center[0] + pos2[0])) ** 2 +
          ((c1.center[1] + pos1[1]) - (c2.center[1] + pos2[1])) ** 2
      #半径の差分を求める
      r1 = c1.radius
      r2 = c2.radius
      r  = r2 ** 2 - 2 * (r1 * r2) + r1 ** 2
      return r2 >= r1 && d <= r
    end

    #== インスタンスの内容を解放する
    #返却値:: なし
    def dispose
      @point = nil
    end
  end

  #==位置情報付き矩形当たり判定領域(コリジョン)クラス
  #コリジョンの範囲は、元データ(スプライト等)の左上端を[0.0,0.0]として考案する
  #コリジョンで使用する値は、実数での設定が可能
  class CollisionEx < Collision
    #コリジョンの位置(Point構造体)
    attr_reader :pos

    #===コリジョンのインスタンスを作成する
    # 幅・高さが0以下のときは例外が発生する
    # 内部では、矩形当たり判定相手の時でも対応できるように矩形情報に変換して同時に持っている。
    # そのとき、引数circumがtrueのときは、円を矩形の外接円と認識して、内部の矩形(正方形)の長さを算出する。
    # circumがfalseのときは、円を矩形の内接円と認識して、内部の矩形(正方形)の長さを算出する。
    #_rect_:: コリジョンを設定する範囲
    #_pos_:: コリジョンの位置
    #_circum_:: 矩形当たり判定とみなす時、円を外接円とするときはtrueを設定する。デフォルトはtrue
    #返却値:: 作成されたコリジョン
    def initialize(rect, pos, circum = true)
      super(rect, circum)
      @pos = Point.new(*pos.to_a)
    end

    #===Collisionクラスのインスタンスを生成する
    #自分自身から位置情報を除いてCollisionクラスのインスタンスを生成する
    #返却値:: Collision構造体
    def to_col
      Collision.new(@rect)
    end

    #===当たり判定を行う(領域が重なっている)
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def collision?(c2)
      return Collision.collision?(self, self.pos, c2, c2.pos)
    end

    #===当たり判定を行う(領域がピクセル単位で隣り合っている)
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 領域が隣り合っていれば true を返す
    def meet?(c2)
      return Collision.meet?(self, self.pos, c2, c2.pos)
    end

    #===当たり判定を行う(どちらかの領域がもう一方にすっぽり覆われている))
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 領域が覆われていれば true を返す
    def cover?(c2)
      return Collision.cover?(self, self.pos, c2, c2.pos)
    end

    #===当たり判定を行う(レシーバがc2を覆っている)
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 領域が覆われていれば true を返す
    def covers?(pos1, c2, pos2)
      return Collision.covers?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(レシーバがc2に覆われている)
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 領域が覆われていれば true を返す
    def covered?(pos1, c2, pos2)
      return Collision.covered?(self, pos1, c2, pos2)
    end

    #===当たり判定を行う(領域が重なっている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def CollisionEx.collision?(c1, c2)
      return Collision.collision?(c1, c1.pos, c2, c2.pos)
    end

    #===当たり判定を行う(領域がピクセル単位で隣り合っている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 領域が隣り合っていれば true を返す
    def CollisionEx.meet?(c1, pos1, c2, pos2)
      return Collision.meet?(c1, c1.pos, c2, c2.pos)
    end

    #===当たり判定を行う(どちらかの領域がもう一方にすっぽり覆われている))
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 領域が覆われていれば true を返す
    def CollisionEx.cover?(c1, pos1, c2, pos2)
      return Collision.cover?(c1, c1.pos, c2, c2.pos)
    end

    #===当たり判定を行う(c1がc2を覆っている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 領域が覆われていれば true を返す
    def CollisionEx.covers?(c1, pos1, c2, pos2)
      return Collision.covers?(c1, c1.pos, c2, c2.pos)
    end

    #===当たり判定を行う(c1がc2に覆われている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 領域が覆われていれば true を返す
    def CollisionEx.covered?(c1, pos1, c2, pos2)
      return Collision.covered?(c1, c1.pos, c2, c2.pos)
    end

    #== インスタンスの内容を解放する
    #返却値:: なし
    def dispose
      super
      @pos = nil
    end
  end

  #==位置情報付き円形当たり判定領域(サークルコリジョン)クラス
  #円形の当たり判定を実装する。
  #コリジョンは中心位置と半径で構成され、円形当たり判定同士で衝突判定を行う
  #コリジョンで使用する値は、実数での設定が可能
  class CircleCollisionEx < CircleCollision
    #===コリジョンのインスタンスを作成する
    #コリジョンの半径が0もしくはマイナスのとき例外が発生する
    #内部では、矩形当たり判定相手の時でも対応できるように矩形情報に変換して同時に持っている。
    #そのとき、引数circumがtrueのときは、円を矩形の外接円と認識して、内部の矩形(正方形)の長さを算出する。
    #circumがfalseのときは、円を矩形の内接円と認識して、内部の矩形(正方形)の長さを算出する。
    #_center_:: コリジョンを設定する範囲
    #_radius_:: コリジョンの半径
    #_pos_::    コリジョンの位置
    #_circum_:: 矩形当たり判定とみなす時、円を外接円とするときはtrueを設定する。デフォルトはtrue
    #返却値:: 作成されたコリジョン
    def initialize(center, radius, pos, circum = true)
      super(center, radius, circum)
      @pos = Point.new(*pos.to_a)
    end

    #===CicleCollisionクラスのインスタンスを生成する
    #自分自身から位置情報を除いてCircleCollisionクラスのインスタンスを生成する
    #返却値:: CircleCollision構造体
    def to_col
      CircleCollision.new(@center, @radius)
    end

    #===当たり判定間の距離を算出する
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def interval(c2)
      return CircleCollision.interval(self, self.pos, c2, c2.pos)
    end

    #===当たり判定を行う(領域が重なっている)
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def collision?(c2)
      return CircleCollision.collision?(self, self.pos, c2, c2.pos)
    end

    #===当たり判定を行う(領域がピクセル単位で隣り合っている)
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 領域が隣り合っていれば true を返す
    def meet?(c2)
      return CircleCollision.meet?(self, self.pos, c2, c2.pos)
    end

    #===当たり判定を行う(どちらかの領域がもう一方にすっぽり覆われている))
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 領域が覆われていれば true を返す
    def cover?(c2)
      return CircleCollision.cover?(self, self.pos, c2, c2.pos)
    end

    #===当たり判定を行う(レシーバがc2を覆っている)
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 領域が覆われていれば true を返す
    def covers?(c2)
      return CircleCollision.covers?(self, self.pos, c2, c2.pos)
    end

    #===当たり判定を行う(レシーバがc2に覆われている)
    #_c2_:: 判定対象のコリジョンインスタンス
    #返却値:: 領域が覆われていれば true を返す
    def covered?(c2)
      return CircleCollision.covered?(self, self.pos, c2, c2.pos)
    end

    #===当たり判定間の距離を算出する
    # ２つの当たり判定がどの程度離れているかを算出する。
    # 返ってくる値は、衝突していなければ正の実数、衝突していれば負の実数で返ってくる
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 当たり判定間の距離
    def CircleCollisionEx.interval(c1, c2)
      return CircleCollision.interval(c1, c1.pos, c2, c2.pos)
    end

    #===当たり判定を行う(領域が重なっている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 1ピクセルでも重なっていれば true を返す
    def CircleCollisionEx.collision?(c1, c2)
      return CircleCollision.collision?(c1, c1.pos, c2, c2.pos)
    end

    #===当たり判定を行う(領域がピクセル単位で隣り合っている)
    # 但し、実際の矩形範囲が偶数の時は性格に判定できない場合があるため注意
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 領域が隣り合っていれば true を返す
    def CircleCollisionEx.meet?(c1, c2)
      return CircleCollision.meet?(c1, c1.pos, c2, c2.pos)
    end

    #===当たり判定を行う(どちらかの領域がもう一方にすっぽり覆われている))
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 領域が覆われていれば true を返す
    def CircleCollisionEx.cover?(c1, c2)
      return CircleCollision.cover?(c1, c1.pos, c2, c2.pos)
    end

    #===当たり判定を行う(c1がc2を覆っている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 領域が覆われていれば true を返す
    def CircleCollisionEx.covers?(c1, c2)
      return CircleCollision.covers?(c1, c1.pos, c2, c2.pos)
    end

    #===当たり判定を行う(c1がc2に覆われている)
    #_c1_:: 判定対象のコリジョンインスタンス(1)
    #_c2_:: 判定対象のコリジョンインスタンス(2)
    #返却値:: 領域が覆われていれば true を返す
    def CircleCollisionEx.covered?(c1, c2)
      return CircleCollision.covered?(c1, c1.pos, c2, c2.pos)
    end

    #== インスタンスの内容を解放する
    #返却値:: なし
    def dispose
      super
      @pos = nil
    end
  end

  #==コリジョン管理クラス
  # 複数のコリジョンと元オブジェクトを配列の様に一括管理できる
  # 当たり判定を一括処理することで高速化を図る
  class Collisions
    include Enumerable
    extend Forwardable

    #===コリジョンのインスタンスを作成する
    # points引数の各要素は、以下の3つの条件のどれかに適合する必要がある。しない場合は例外が発生する
    # 1)[x,y]の要素を持つ配列
    # 2)Point構造体、Rect構造体、もしくはSquare構造体
    # 3)x,yメソッドを持つ
    #_collisions_:: コリジョンの配列。デフォルトは []
    #_points_:: 位置情報の配列。デフォルトは []
    #返却値:: 作成されたインスタンス
    def initialize(collisions=[], points=[])
      @collisions = Array.new(collisions).zip(points)
    end

    def initialize_copy(obj) #:nodoc:
      @collisions = @collisions.dup
    end

    def deep_dup_collision #:nodocs:
      @collisions = @collisions.deep_dup
      return self
    end

    #===要素も複製した複製インスタンスを返す
    #返却値:: 複製したインスタンスを返す
    def deep_dup
      ret = self.dup
      ret.deep_dup_collision
    end

    #===コリジョンと位置情報を追加する
    # point引数は、以下の3つの条件のどれかに適合する必要がある。しない場合は例外が発生する
    # 1)[x,y]の要素を持つ配列
    # 2)Point構造体、Rect構造体、もしくはSquare構造体
    # 3)x,yメソッドを持つ
    #_collisions_:: コリジョン
    #_point_:: 位置情報
    #返却値:: 自分自身を返す
    def add(collision, point)
      @collisions << [collision, point]
      return self
    end

    #===インスタンスに、コリジョンと位置情報の集合を追加する
    # points引数の各要素は、以下の3つの条件のどれかに適合する必要がある。しない場合は例外が発生する
    # 1)[x,y]の要素を持つ配列
    # 2)Point構造体、Rect構造体、もしくはSquare構造体
    # 3)x,yメソッドを持つ
    #_collisions_:: コリジョンの配列
    #_points_:: 位置情報の配列
    #返却値:: 自分自身を返す
    def append(collisions, points)
      @collisions.concat(collisions.zip(points))
      return self
    end

    #===インデックス形式でのコリジョン・本体の取得
    #_idx_:: 配列のインデックス番号
    #返却値:: インデックスに対応したコリジョンと位置情報との対。
    #インデックスが範囲外の時はnilが返る
    def [](idx)
      return @collisions[idx]
    end

    #===コリジョン・本体の削除
    #_idx_:: 配列のインデックス番号
    #返却値:: 削除したコリジョンと本体との対
    #インデックスが範囲外の時はnilが返る
    def delete(idx)
      return @collisions.delete_at(idx)
    end

    #===インデックス形式でのコリジョン・本体の取得
    #_idx_:: 配列のインデックス番号
    #返却値:: インデックスに対応したコリジョンと本体との対
    def clear
      @collisions.clear
      return self
    end

    #===タッピングを行う
    # ブロックを渡すことにより、タッピングを行う
    # ブロック内の引数は、|コリジョン,本体|の２が渡される
    #返却値:: 自分自身を返す
    def each
      @collisions.each{|cb| yield cb[0], cb[1] }
      return self
    end

    #===タッピングを行う
    # ブロックを渡すことにより、タッピングを行う
    # ブロック内の引数は、|コリジョン,本体|の２が渡される
    #_idx_:: 配列のインデックス
    #返却値:: 自分自身を返す
    def tap(idx)
      yield @collisions[idx][0], @collisions[idx][1]
      return self
    end

    #===当たり判定を行う(配列要素がcと重なっている)
    # 重なったコリジョンが一つでもあれば、最初に引っかかったコリジョンを返す
    # 重なったコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: コリジョンと本体の対。
    def collision?(c, pos)
      return @collisions.detect{|cc| c.collision?(pos, cc[0], cc[1])}
    end

    #===当たり判定を行う(配列要素のどれかがcとピクセル単位で隣り合っている)
    # 隣り合ったコリジョンが一つでもあれば、最初に引っかかったコリジョンを返す
    # 隣り合ったコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: 隣り合っていれば true を返す
    def meet?(c, pos)
      return @collisions.detect{|cc| c.meet?(pos, cc[0], cc[1])}
    end

    #===当たり判定を行う(配列要素とcのどちらかが、もう一方にすっぽり覆われている))
    # 覆われたコリジョンが一つでもあれば、最初に引っかかったコリジョンを返す
    # 覆われたコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: 領域が覆われていれば true を返す
    def cover?(c, pos)
      return @collisions.detect{|cc| c.cover?(pos, cc[0], cc[1])}
    end

    #===当たり判定を行う(配列要素のどれかがcを覆っている))
    # 覆われたコリジョンが一つでもあれば、最初に引っかかったコリジョンを返す
    # 覆われたコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: 領域が覆われていれば true を返す
    def covers?(c, pos)
      return @collisions.detect{|cc| c.covers?(pos, cc[0], cc[1])}
    end

    #===当たり判定を行う(配列要素のどれかがcに覆われている))
    # 覆われたコリジョンが一つでもあれば、最初に引っかかったコリジョンを返す
    # 覆われたコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: 領域が覆われていれば true を返す
    def covered?(c, pos)
      return @collisions.detect{|cc| c.covered?(pos, cc[0], cc[1])}
    end

    #===当たり判定を行う(配列要素とcが重なっている)
    # 重なったコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 重なったコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: コリジョンと本体の対の配列。
    def collision_all?(c, pos)
      return @collisions.select{|cc| c.collision?(pos, cc[0], cc[1])}
    end

    #===当たり判定を行う(配列要素がcとピクセル単位で隣り合っている)
    # 隣り合ったコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 隣り合ったコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: コリジョンと本体の対の配列。
    def meet_all?(c, pos)
      return @collisions.select{|cc| c.meet?(pos, cc[0], cc[1])}
    end

    #===当たり判定を行う(配列要素かcがもう一方を覆っている))
    # 覆われたコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 覆われたコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: コリジョンと本体の対の配列。
    def cover_all?(c, pos)
      return @collisions.select{|cc| c.cover?(pos, cc[0], cc[1])}
    end

    #===当たり判定を行う(配列要素が領域がcを覆っている))
    # 覆われたコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 覆われたコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: コリジョンと本体の対の配列。
    def covers_all?(c, pos)
      return @collisions.select{|cc| c.covers?(pos, cc[0], cc[1])}
    end

    #===当たり判定を行う(配列要素がcに覆われている))
    # 覆われたコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 覆われたコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #_pos_:: cの位置(Point/Rect/Square構造体、もしくは2要素の配列)
    #返却値:: コリジョンと本体の対の配列。
    def covered_all?(c, pos)
      return @collisions.select{|cc| c.covered?(pos, cc[0], cc[1])}
    end

    #===インデックス形式でのコリジョン・本体の取得
    # 判定に引っかかったコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 当たり判定に引っかかったコリジョンが無い場合はnilを返す
    #_idx_:: 配列のインデックス番号
    #返却値:: インデックスに対応したコリジョンと本体との対
    def [](idx)
      return [@collisions[idx], @bodies[idx]]
    end

    #===オブジェクトを解放する
    #返却値:: なし
    def dispose
      @collisions.clear
      @collisions = nil
    end
  end


  #==コリジョン管理クラス
  # 複数のコリジョンと元オブジェクトを配列の様に一括管理できる
  # 当たり判定を一括処理することで高速化を図る
  class CollisionsEx < Delegator

    attr_accessor :collision

    #===コリジョンのインスタンスを作成する
    #利用できる要素はCollisionEx,CircleCollisionEx(か、その派生)のみ
    #_collisions_:: コリジョンの配列。デフォルトは []
    #返却値:: 作成されたインスタンス
    def initialize(collisions=[])
      @collisions = Array.new(collisions)
      @collision = nil
    end

    def __getobj__ #:nodoc:
      @collisions
    end

    def __setobj__(obj) #:nodoc:
    end

    def initialize_copy(obj) #:nodoc:
      @collisions = @collisions.dup
    end

    def deep_dup_collision #:nodocs:
      @collisions = @collisions.deep_dup
      return self
    end

    #===要素も複製した複製インスタンスを返す
    #返却値:: 複製したインスタンスを返す
    def deep_dup
      ret = self.dup
      ret.deep_dup_collision
    end

    #===現在所持している配列から最大範囲のコリジョンを作成する
    #ただし、配列が空の時はnilを返す
    #返却値:: 生成したコリジョン(CollisionExクラスのインスタンス)
    def from_children
      return nil if @collisions.empty?
      array = []
      @collisions.each{|cc|
        if cc.class.method_defined?(:from_children)
          col = cc.from_children
          next unless col
          array << col.rect.to_square.to_a
        else
          rect = cc.rect.dup
          rect[0] += cc.pos[0]
          rect[1] += cc.pos[1]
          array << rect.to_square.to_a
        end
      }
      el = array.shift
      if array.length >= 1
        array = el.zip(*array)
        el = [array[0].min, array[1].min, array[2].max, array[3].max]
      end
      CollisionEx.new(Rect.new(el[0], el[1], el[2]-el[0]+1, el[3]-el[1]+1), Point.new(0,0))
    end

    #===コリジョンと位置情報を追加する
    #_collision_:: コリジョン
    #返却値:: 自分自身を返す
    def add(collision)
      @collisions << collision
      return self
    end

    #===インスタンスに、コリジョンと位置情報の集合を追加する
    #_collisions_:: コリジョンの配列
    #返却値:: 自分自身を返す
    def append(collisions)
      @collisions.concat(collisions)
      return self
    end

    #===当たり判定を行う(配列要素とcが重なっている)
    # 重なったコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 重なったコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #返却値:: コリジョンの配列。
    def collision?(c)
      return nil if @collision and !@collision.collision?(c)
      collision_inner(c, []){|cc,c| cc.collision?(c) }
    end

    def collision_inner(c, array) #:nodoc:
      @collisions.each{|cc|
        ret = yield cc, c
        array << (ret == true ? cc : ret) if ret
      }
      array.length == 0 ? nil : array
    end

    private :collision_inner

    #===当たり判定を行う(配列要素がcとピクセル単位で隣り合っている)
    # 隣り合ったコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 隣り合ったコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #返却値:: コリジョンの配列。
    def meet?(c)
      return nil if @collision and !@collision.collision?(c)
      collision_inner(c, []){|cc,c| cc.meet?(c) }
    end

    #===当たり判定を行う(配列要素かcがもう一方を覆っている))
    # 覆われたコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 覆われたコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #返却値:: コリジョンの配列。
    def cover?(c)
      return nil if @collision and !@collision.collision?(c)
      collision_inner(c, []){|cc,c| cc.cover?(c) }
    end

    #===当たり判定を行う(配列要素が領域がcを覆っている))
    # 覆われたコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 覆われたコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #返却値:: コリジョンの配列。
    def covers?(c)
      return nil if @collision and !@collision.collision?(c)
      collision_inner(c, []){|cc,c| cc.covers?(c) }
    end

    #===当たり判定を行う(配列要素がcに覆われている))
    # 覆われたコリジョンが一つでもあれば、すべてのコリジョンの配列を返す
    # 覆われたコリジョンが無い場合はnilを返す
    #_c_:: 判定対象のコリジョンインスタンス
    #返却値:: コリジョンの配列。
    def covered?(c)
      return nil if @collision and !@collision.collision?(c)
      collision_inner(c, []){|cc,c| cc.covers?(c) }
    end

    #===オブジェクトを解放する
    #返却値:: なし
    def dispose
      @collisions.clear
      @collisions = nil
      @collision = nil
    end
  end
end
