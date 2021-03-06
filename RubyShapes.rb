#!/usr/bin/env ruby

#RubyShapes
#
#Copyright 2009 Matthew D. Jordan
#www.scenic-shop.com
#shared under the GNU GPLv3


#Load standard modules
require 'bigdecimal'
require 'bigdecimal/math'
require 'bigdecimal/util'
include BigMath

#Load RubyShapes specific modules
require "lib/DiagnosticsModule.rb"
require "lib/OutputModule.rb"
require "lib/ShapeUtilitiesModule.rb"

include Diagnostics
include Output
include ShapeUtilities

#Constants
Pi = BigDecimal.PI(20)

#Diagnostics Flag
DIAGNOSTICS = "off"

#########################
###   Shape Classes   ###
#########################

#=Class Round_tube(od, thickness)
#  parameters:
#    @x = outside diameter
#    @t = thickness of tubing
class Round_tube
  attr_accessor :x, :y, :a, :ix, :iy, :sx, :sy, :rx, :ry, :w
  include ShapeUtilities; include Diagnostics; include Output

  def initialize(x, t)  
    diag_class

    @x = @y = x.to_s.to_d
    @t = t.to_i

    gauge_converter
     
    #calculate Round tube Area
    @a = (Pi*@t) * (@x-@t)

    #calculate Second Moment of Area (I)
    @ix = @iy = Pi * (@x**4 - ((@x - (2*@t))**4 ))/64

    #Calculate Round Tube Section Modulus
    @sx = @sy = (2*@ix)/@x

    #Calculate Round Tube Radius of Gyration 
    @rx = @ry = sqrt(@ix/@a, 9)

    calc_weight
    build_hash
    diag_all

  end #def init
end #class Round_tube


#=Class Square_tube(od, thickness, radius)
#  parameters:
#    @x  = outside diameter
#    @t  = thickness of tubing
#    @ra = radius at corner
class Square_tube
  attr_accessor :x, :y, :a, :ix, :iy, :sx, :sy, :rx, :ry, :w, :ra
  include ShapeUtilities; include Diagnostics; include Output
    
  def initialize(x, t)
    diag_class

    @x = @y = x.to_s.to_d
    @t = t.to_i

    corner_radius
    gauge_converter

    #calculate Square Area
    @a = (@t * ((4 * @x) - (8 * @ra) + ( Pi * (2*@ra - @t) ) ))

    #calculate Second Moment of Area (I)
    @ix = @iy = ((@t**3 * (@x - 2 * @ra))/6 + 2 * @t * (@x - 2 * @ra) * ((@x - @t)/2)**2 + (@t * (@x - 2 * @ra)**3)/6 + (Pi/4 - 8/(4.5 * Pi)) * (@ra**4 - (@ra - @t)**4) - ( 8 * @t * @ra**2 * (@ra - @t)**2)/(4.5 * Pi * (2 * @ra - @t)) + Pi * @t * (2 * @ra - @t) * (@x/2 - @ra + (4 * (ra**3 - (@ra - @t)**3))/(3 * Pi * (@ra**2 - (@ra - @t)**2)))**2).to_d

    #Section Modulus
    @sx = @sy = ((2 * @ix)/@x)

    #Radius of Gyration
    @rx = @ry = (@ix/@a).sqrt(2)

    calc_weight
    build_hash
    diag_all

  end #def init
end #Square_tube


#=Class Rec_tubing(d_x, d_y, ra, thick)
#
#  parameters:
#  d = box tube width, height
#  ra = radius of corner
#  t = wall thickness
class Rec_tube
  attr_accessor :x, :y, :t, :ra, :a, :ix, :iy, :sx, :sy, :rx, :ry, :w  
  include ShapeUtilities; include Diagnostics; include Output
  
  def initialize(x, y, t)
    diag_class   

    @x = x.to_s.to_d
    @y = y.to_s.to_d
    @t = t.to_i

    corner_radius
    gauge_converter
    
    #----------calculate area----------
    @a = (@t*((BigDecimal.new("2")*(@x+@y))-( BigDecimal.new("8")*@ra)+(Pi*(( BigDecimal.new("2")*@ra)-@t))))

    #method - calculate Second Moment of Area


    @iy = ((@t**3 * (@y - 2 * @ra)) / 6 + 2 * @t * (@y - 2 * @ra) * ((@x - @t) / 2)**2 + (@t * (@x - 2 * @ra)**3 ) / 6 + (Pi / 4 - 8/(4.5 * Pi)) * (@ra**4 - (@ra - @t)**4) - (8 * @t * @ra**2 * (@ra - @t)**2) / (4.5 * Pi * (2 * @ra - @t)) + Pi * @t * (2 * @ra - @t) * (@x/2 - @ra + (4 * (@ra ** 3 - (@ra - @t) ** 3)) / (3 * Pi * (@ra ** 2 - (@ra - @t)**2)))**2).to_d
    @ix = ((@t**3 * (@x - 2 * @ra)) / 6 + 2 * @t * (@x - 2 * @ra) * ((@y - @t) / 2)**2 + (@t * (@y - 2 * @ra)**3 ) / 6 + (Pi / 4 - 8/(4.5 * Pi)) * (@ra**4 - (@ra - @t)**4) - (8 * @t * @ra**2 * (@ra - @t)**2) / (4.5 * Pi * (2 * @ra - @t)) + Pi * @t * (2 * @ra - @t) * (@y/2 - @ra + (4 * (@ra ** 3 - (@ra - @t) ** 3)) / (3 * Pi * (@ra ** 2 - (@ra - @t)**2)))**2).to_d

    #calculate Section Modulus method
    @sx = ((2*ix)/y).to_d
    @sy = (2*iy/x).to_d


    @rx = sqrt(@ix/@a, 9)
    @ry = sqrt(@iy/@a, 9)

    calc_weight
    build_hash
    diag_all

  end #def init
end #class Rec_tube

#=Class Bar(x)
#As in square bar.
#FIXME: Check Math, guestimated most of it
#
#  parameters:
#  x = bar dimension - x & y    
class Bar
  attr_accessor :x, :y, :a, :ix, :iy, :sx, :sy, :rx, :ry, :w
  include ShapeUtilities; include Diagnostics; include Output
  
  def initialize(x)
    diag_class    

    @x = @y = x.to_s.to_d

    #calculate area
    @a = @x * @x
    
    #calculate Second Moment of Inertia
    @ix = @iy = (@x**4) / 12

    #calculate Section Modulus
    @sx = @sy = (@x**3) / 6
    
    #calculate Radius of Gyration
    @rx = sqrt(@ix / @a, 2)
    @ry = sqrt(@iy / @a, 2)
    
    calc_weight
    build_hash
    diag_all

  end #def
end #class Bar


#=Class Plate(x, y)
#
#FIXME: Check Math, guestimated most of it
#
#  parameters:
#  x = dimension
#  y = dimension
class Plate
  attr_accessor :x, :y, :a, :ix, :iy, :sx, :sy, :rx, :ry, :w
  include ShapeUtilities; include Diagnostics; include Output
  
  def initialize(x, y)  
    diag_class

    @x = x.to_s.to_d
    @y = y.to_s.to_d

    #calculate area
    @a = @x * @y
    
    #calculate Second Moment of Inertia
    @ix = (@x * @y**3) / 12
    @iy = (@y * @x**3) / 12
    
    #calculate Section Modulus - BROKEN
    @sx = (@x**3) / 6
    @sy = (@y**3) / 6

    #calculate Radius of Gyration - BROKEN
    @rx = sqrt(@ix / @a, 2)
    @ry = sqrt(@iy / @a, 2)

    calc_weight
    build_hash
    diag_all

  end #def init
end #class Plate


#=Class Rod(x)
#  parameters:
#  x = diameter
class Rod
  attr_accessor :x, :y, :a, :ix, :iy, :sx, :sy, :rx, :ry, :w
  include ShapeUtilities; include Diagnostics; include Output
  
  def initialize(x)
    diag_class
    
    @x = x.to_d
    @y = x.to_d
    #calculate area
    @a = Pi * (@x / 2)**2 
    
    #calculate Second Moment of Inertia
    @ix = @iy = (Pi/64)*(@x**4)

    #calculate Section Modulus
    @sx = @sy = Pi * @x ** 3 /32

    #calculate Radius of Gyration
    @rx = @ry = sqrt(@ix / @a, 2)
    
    calc_weight 
    build_hash
    diag_all

  end #def init
end #class Rod

##########################
###    Testing area    ###
##########################

#  Square_tube.new(1, 18).props
#  Square_tube.new(1, 18).props
#  Square_tube.new(1, 18).bigprops("t")
#  Square_tube.new(1, 18).bigprops
#  Square_tube.new(1, 18).hash
#  Square_tube.new(1, 18).bighash
#  Square_tube.new(1, 18).columns
#
#  Square_tube.new(1, 18).props
#  Round_tube.new(4, 18).props
#  Rec_tube.new(1.5, 1.5, 20).columns
#  Rec_tube.new(1.5, 1.5, 18).columns
#
#
#  Bar.new(5.0).props
#  Plate.new(4.0, 5).props
  Rod.new(2.0).props