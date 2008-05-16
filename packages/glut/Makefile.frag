GLUT_FILES = \
packages/glut/OpenGlut.st packages/glut/OpenGlutEnum.st 
$(GLUT_FILES):
$(srcdir)/packages/glut/stamp-classes: $(GLUT_FILES)
	touch $(srcdir)/packages/glut/stamp-classes
