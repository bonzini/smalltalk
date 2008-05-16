OpenGL_FILES = \

$(OpenGL_FILES):
$(srcdir)/packages/opengl/stamp-classes: $(OpenGL_FILES)
	touch $(srcdir)/packages/opengl/stamp-classes
