require 'rubygems'
require 'opengl'
require 'rational'

module Gravy
  module Render
    class OpenGL
      include Gl, Glu, Glut

      @@display = Proc.new do
        glClear(GL_COLOR_BUFFER_BIT)
        glColor(1.0, 1.0, 1.0)

        glPushMatrix
        glColor(0.2, 0.2, 1.0)
        glutSolidSphere(1.0, 30.0, 16)
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

      def initialize(height, width)
        glutInit
        glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB)
        glutInitWindowSize(height, width)
        glutInitWindowPosition(100, 100)
        glutCreateWindow($0)

        glShadeModel(GL_SMOOTH)
        glMatrixMode(GL_PROJECTION)

        glutDisplayFunc @@display
        glutReshapeFunc @@reshape
        glutMainLoop
      end

    end
  end
end

Gravy::Render::OpenGL.new(600, 500)

