# Particles are the smallest elements of our computation

module Gravy
  class Particle
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
end

def Gravy::Particle(position, velocity=[rand(10),rand(20),0])
  Gravy::Particle.new(position, velocity)
end

