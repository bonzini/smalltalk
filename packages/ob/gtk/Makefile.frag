OmniBrowser-GTK_FILES = \
packages/ob/gtk/OB-GTK.st 
$(OmniBrowser-GTK_FILES):
$(srcdir)/packages/ob/gtk/stamp-classes: $(OmniBrowser-GTK_FILES)
	touch $(srcdir)/packages/ob/gtk/stamp-classes
