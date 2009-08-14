require 'rubygems'
require 'narray'

module Gravy; end

# Particles are the smallest elements of our computation
class Gravy::Particle
  def initialize(position)
    @position = position 
  end

  def self.[](x,y,z)
    new(NVector[x,y,z]) 
  end
end


# A System has many Particles, and is attached to an integrator
class Gravy::System < Array
  def initialize(opts={})
    @integrator = opts[:integrator].new
    @set = []
  end

  def run!(*particles)
    @set.push(*particles)
    puts "Compiling!"
  end
end


# Integrator classes contain the mathematics necessary to perform the force calculations 
module Gravy::Integrators
  class Straight
    def initialize
      puts "Initialized the straight integrator"
    end
  end
end

system = Gravy::System.new(:integrator => Gravy::Integrators::Straight)
system.run!(
  Gravy::Particle[-10, -10, 0],
  Gravy::Particle[-10, 10, 0],
  Gravy::Particle[10, -10, 0],
  Gravy::Particle[10, 10, 0]
)

