require 'rubygems'
require 'narray'
require 'md5'

require 'gravy'

# Gravy
# (c) Pradeep Elankumaran, 2009
# pronounced "Grah-vy"

# A System has many Particles, and is attached to an integrator
class Gravy::System < Array
  attr_accessor :particles
  def initialize(opts={})
    @integrator = opts.delete(:integrator).new(opts)
  end

  def run!(*particles)
    @particles = particles
    @initial_energy = kinetic_energy + potential_energy
    puts "INITIAL ENERGY: #{@initial_energy}"
    @integrator.start(@particles)
    @final_energy = kinetic_energy + potential_energy
    puts "FINAL ENERGY: #{@final_energy}"
    puts "ENERGY RETAINED: #{((@initial_energy/@final_energy)*100).to_i}%"
  end

  def kinetic_energy
    @particles.inject(0){|energy, p| energy += p.kinetic_energy} 
  end

  def potential_energy
    # divide by two so you don't count paired systems twice
    @particles.inject(0){|energy, p| energy += p.potential_energy(self)}/2.0 
  end

  def method_missing(name, *args)
    @integrator.send(name, *args)
  end
end


# Integrator classes contain the mathematics necessary to perform the force calculations 
module Gravy::Integrators
  class Base 
    attr_accessor :current_step, :num_steps, :timestep, :particles
    def initialize(opts={})
      @num_steps = opts[:num_steps]
      @timestep = opts[:timestep]
      @save_steps = opts[:save_steps] || false
      @current_step = 0
      puts "Integrating using the '#{self.class}' integrator..."
      puts "Will be computing #{@num_steps} steps forward ..."
    end

    # for @num_steps steps, iterate over each particle and shift positions and velocities
    def start(particles)
      @particles = particles
      puts "This system contains #{@particles.size} particles"
      puts "INITIAL STATE: "; print_state; puts "-------------"
      (1..@num_steps).each do |step|
        puts "STEP #{step} | DT #{@timestep}"
        integrate! 
        increase_step!
        print_state
        puts "-------------------"
      end
    end

    def print_state(particles=@particles) 
      particles.each{|p| puts p}
    end

    def increase_step!
      @current_step += 1
    end

    def acceleration(this_particle)
      acc = NVector[0,0,0]
      @particles.except(this_particle).each{|op|
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
                           :num_steps => ARGV[0] || 10,
                           :timestep => ARGV[1] || 1.0)
system.run!(
  Gravy::Particle([-10, -10, 0]),
  Gravy::Particle([-10, 10, 0]),
  Gravy::Particle([10, -10, 0]),
  Gravy::Particle([10, 10, 0])
)

