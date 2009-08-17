require 'rubygems'
require 'opengl'
require 'rational'
require 'rake'
require 'fastercsv'
require 'gravy'

include Gl, Glu, Glut

class Run
  def initialize(data)
    @data = data.map do |particle_data|
      Gravy::Particle.new(particle_data[0..2], [0, 0, 0], particle_data[3])
    end
  end

  def each(&block)
    @data.each{|p| yield(p)}
  end
end

class RunSet 
  def initialize(directory=File.dirname(__FILE__))
    directory = File.expand_path(File.join(directory, "runs/**.run"))
    puts "Fetching data from #{directory}..."
    @files = FileList[directory] 
  end

  def self.frames
    new.frames
  end

  def frames 
    @files.inject([]) do |frames, file|
      data = FasterCSV.read(file, :converters => :numeric,
                                  :skip_blanks => true)
      frames << Run.new(data)
    end
  end
end

$rotate = 0
def show_spheres
  $frames.each do |frame|
    frame.each do |particle|
      glColor(0.2, 0.2, 1.0)
      glTranslate(particle.x, particle.y, particle.z)
      glutSolidSphere(particle.mass, 20.0, 16)
    end
  end
end

$display = Proc.new do
  glClear(GL_COLOR_BUFFER_BIT)
  glColor(1.0, 1.0, 1.0)

  glPushMatrix
  glRotate($rotate, 0.0, 1.0, 0.0)
  show_spheres
  glPopMatrix

  glColor(1.0, 1.0, 1.0)
  glutSwapBuffers
end

$reshape = Proc.new do |width, height|
  glViewport(0.0, 0.0, width, height)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity
  gluPerspective(60.0, width.to_f/height.to_f, 1.0, 1000.0)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity
  gluLookAt(0.0, 0.0, 200.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
end

$keyboard_event = Proc.new do |key, x, y|
  case key
    when ?r
      $rotate += 10.0
    when ?R
      $rotate -= 10.0 
    when ?e
      exit(0)
  end
  glutPostRedisplay
end

def load_data
  puts "Loading run data into frames..."
  $frames ||= RunSet.frames
  puts "... done!"
end

def render(height, width)
  load_data

  glutInit
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB)
  glutInitWindowSize(height, width)
  glutInitWindowPosition(100, 100)
  glutCreateWindow($0)

  glShadeModel(GL_SMOOTH)
  glMatrixMode(GL_PROJECTION)

  glutDisplayFunc $display
  glutReshapeFunc $reshape
  glutKeyboardFunc $keyboard_event
  glutMainLoop
end

render(800, 600)
