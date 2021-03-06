#!/usr/bin/env ruby

#RubyShapes
#
#Copyright 2009 Matthew D. Jordan
#www.scenic-shop.com
#shared under the GNU GPLv3

#############################
###   ShapeUtils Module   ###
#############################

#this module handles i/o of the calculated shape values
module ShapeUtilities

$gauge_factors = { 30=>0.012, 29=>0.013, 28=>0.014, 27=>0.016, 26=>0.018, 25=>0.020, 24=>0.022, 23=>0.025, 22=>0.028, 21=>0.032, 20=>0.035, 18=>0.049, 16=>0.065, 14=>0.083, 13=>0.095, 12=>0.109, 11=>0.120, 10=>0.134, 9=>0.148, 8=>0.165, 7=>0.180, 6=>0.203, 5=>0.220, 4=>0.238, 3=>0.259, 2=>0.284, 1=>0.300, 0=>0.34, 00=>0.38, 000=>0.425, 0000=>0.454 }
$radius_factors = { 0.035=>"0.04675", 0.049=>"0.0625", 18=>"0.0625", 16=>"0.0859375" }

#adds a to_d method to the Float class
  class Float
    def to_d
      BigDecimal(self.to_s)
    end #def to_d
  end #class Float

#Will determine rectangular tubing corner radius based on perimeter & thickness - currently broken
  def corner_radius
    diag_section("Calculating Corner Radius")
    
    if $radius_factors.key?(@t)
      @ra = BigDecimal.new("#{$radius_factors[@t]}")
      diag_line("radius was calculated")
    else
      @ra = BigDecimal.new("0.03125")
      diag_line("radius could not be calculated: using default value")
    end #if

#    equiv_diam = (((@x * 2) + (@y * 2)) / Pi)
#    diag_line("equivalent diameter:   #{equiv_diam.round(4)}, #{equiv_diam.class}")
    diag_line("@radius:                #{@ra.to_f.to_s}, #{@ra.class}")


  end #def corner_radius

#This method examines the @t (thickness) variable to see if it is a decimal number or a gauge number.
#@t > 1 are converted to the decimal number equivalents via a case statement.
#@t < 1 are kept as is
  def gauge_converter
    diag_section("Gauge Conversion")    
    
    if $gauge_factors.key?(@t)
      @t = BigDecimal.new("#{$gauge_factors[@t]}")
      diag_line("gauge was converted from AWG to decimal")
    else
      @t = BigDecimal.new(@t)
      diag_line("decimal gauge provided")
    end #if

    diag_line("@thickness:             #{@t.to_f.to_s}, #{@t.class}")
    diag_line("")
  end #def gauge_converter


#This method calculates the weight of the shape - assumes shape is med. carbon steel
  def calc_weight
         @w = 3.3996.to_d * @a
  end #weight

  def build_hash
    @hash = {"x" => @x.round(4).to_f, "y" => @y.round(4).to_f, "a" => @a.round(4).to_f, "ix" => @ix.round(4).to_f, "iy" => @iy.round(4).to_f, "sx" => @sx.round(4).to_f, "sy" => @sy.round(4).to_f, "rx" => @rx.round(4).to_f, "ry" => @ry.round(4).to_f, "w" => @w.round(4).to_f }
    @bighash = {"x" => @x, "y" => @y, "a" => @a, "ix" => @ix, "iy" => @iy, "sx" => @sx, "sy" => @sy, "rx" => @rx, "ry" => @ry, "w" => @w }
  end #build_hash
    
end #ShapeUtils