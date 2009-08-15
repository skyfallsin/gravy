require 'rubygems'
require 'narray'
require 'md5'

# Gravy
# (c) Pradeep Elankumaran, 2009
# pronounced "Grah-vy"
module Gravy
  VERSION = 0.1
end

class Array
  def except(elem)
    self - [elem]
  end
end

# Particles are the smallest elements of our computation
class Gravy::Particle
  attr_accessor :position, :velocity, :mass
  def initialize(position, velocity)
    @position = NVector[*position.collect{|x| x.to_f}] 
    @velocity = NVector[*velocity.collect{|x| x.to_f}]
    @mass = 20.0
  end

  def pid
    @pid ||= MD5.hexdigest("#{@mass}#{object_id}")[0..1]
  end

  def x; @position[0] end
  def y; @position[1] end
  def z; @position[2] end
  
  def vx; @velocity[0] end
  def vy; @velocity[1] end
  def vz; @velocity[2] end

  def inspect
    "#{pid}-#{@mass}-[#{x},#{y},#{z}]-[#{vx},#{vy},#{vz}]"
  end
  alias :to_s :inspect
end

def Gravy::Particle(position, velocity=[rand(10),rand(20),0])
  Gravy::Particle.new(position, velocity)
end


# A System has many Particles, and is attached to an integrator
class Gravy::System < Array
  def initialize(opts={})
    @integrator = opts[:integrator].new(opts[:steps], opts[:timestep])
  end

  def run!(*particles)
    @integrator.start(particles)
  end
end


# Integrator classes contain the mathematics necessary to perform the force calculations 
module Gravy::Integrators
  class Base 
    attr_accessor :current_step, :num_steps, :timestep, :particles
    def initialize(num_steps, timestep)
      @num_steps = num_steps
      @timestep = timestep
      @current_step = 0
      puts "Integrating using the '#{self.class}' integrator..."
      puts "Will be computing #{@num_steps} steps forward ..."
    end

    # for @num_steps steps, iterate over each particle and shift positions and velocities
    def start(particles)
      @particles = particles
      puts "This system contains #{@particles.size} particles"
      puts "INITIAL STATE: "; print_state; puts "-------------"
      (1..num_steps).each do |step|
        puts "STEP #{step} | DT #{@timestep}"
        integrate! 
        increase_step!
        print_state
        puts "-------------------"
      end
    end

    def print_state 
      @particles.each{|p| puts p}
    end

    def increase_step!
      @current_step += 1
    end

    def acceleration(this_particle)
#      puts "Computing acceleration for particle #{this_particle}..."
      acc = NVector[0,0,0]
      @particles.except(this_particle).each{|op|
#        puts "... with particle #{op}"
        r = op.position - this_particle.position
        r2 = r * r
        r3 = r2 * Math.sqrt(r2)
        acc += r * (op.mass/r3)
      } 
      return acc
    end
  end
  
  class Leapfrog < Base 
    # calculate acc 
    # use it to step the velocity forward by half a time step
    # step the position forward
    # this allows you to calculate acc_2
    # use that to step the velocity forward by another half step.
    def integrate!
      particles.map{|p| p.velocity += acceleration(p) * 0.5 * timestep} 
      particles.map{|p| p.position += p.velocity * timestep}
      particles.map{|p| p.velocity += acceleration(p) * 0.5 * timestep}
    end
  end
end

system = Gravy::System.new(:integrator => Gravy::Integrators::Leapfrog,
                           :steps => ARGV[0] || 10,
                           :timestep => ARGV[1] || 1.0)
system.run!(
  Gravy::Particle([-10, -10, 0]),
  Gravy::Particle([-10, 10, 0]),
  Gravy::Particle([10, -10, 0]),
  Gravy::Particle([10, 10, 0])
)

