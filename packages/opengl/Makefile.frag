OpenGL_FILES = \
packages/opengl/OpenGL.st packages/opengl/OpenGLEnum.st packages/opengl/OpenGLUEnum.st 
$(OpenGL_FILES):
$(srcdir)/packages/opengl/stamp-classes: $(OpenGL_FILES)
	touch $(srcdir)/packages/opengl/stamp-classes
