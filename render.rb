require 'rubygems'
require 'opengl'
require 'rational'

include Gl, Glu, Glut

@@rotate = 0

@@display = Proc.new do
  glClear(GL_COLOR_BUFFER_BIT)
  glColor(1.0, 1.0, 1.0)

  glPushMatrix
  glRotate(@@rotate, 0.0, 1.0, 0.0)
    glColor(0.2, 0.2, 1.0)
    glutSolidSphere(3.0, 30.0, 16)
    glTranslate(-60.0, -60.0, 0.0)
    glutSolidSphere(1.0, 30.0, 16)
  glPopMatrix

  glColor(1.0, 1.0, 1.0)
  glutSwapBuffers
end

@@reshape = Proc.new do |width, height|
  glViewport(0.0, 0.0, width, height)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity
  gluPerspective(60.0, width.to_f/height.to_f, 1.0, 1000.0)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity
  gluLookAt(0.0, 0.0, 200.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
end

@@keyboard_event = Proc.new do |key, x, y|
  case key
    when ?r
      @@rotate += 10.0
    when ?R
      @@rotate -= 10.0 
    when ?e
      exit(0)
  end
  glutPostRedisplay
end

def render(height, width)
  glutInit
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB)
  glutInitWindowSize(height, width)
  glutInitWindowPosition(100, 100)
  glutCreateWindow($0)

  glShadeModel(GL_SMOOTH)
  glMatrixMode(GL_PROJECTION)

  glutDisplayFunc @@display
  glutReshapeFunc @@reshape
  glutKeyboardFunc @@keyboard_event
  glutMainLoop
end


render(800, 600)

