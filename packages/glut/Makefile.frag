GLUT_FILES = \

$(GLUT_FILES):
$(srcdir)/packages/glut/stamp-classes: $(GLUT_FILES)
	touch $(srcdir)/packages/glut/stamp-classes
