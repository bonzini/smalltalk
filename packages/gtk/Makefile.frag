GTK_FILES = \
packages/gtk/Enums.st packages/gtk/example_arrow.st packages/gtk/example_aspectframe.st packages/gtk/example_buttonbox.st packages/gtk/example_entry.st packages/gtk/example_eventbox.st packages/gtk/example_hello.st packages/gtk/example_tictactoe.st packages/gtk/example_tree.st packages/gtk/Funcs.st packages/gtk/GtkDecl.st packages/gtk/GtkImpl.st packages/gtk/MoreFuncs.st packages/gtk/MoreStructs.st packages/gtk/Structs.st 
$(GTK_FILES):
$(srcdir)/packages/gtk/stamp-classes: $(GTK_FILES)
	touch $(srcdir)/packages/gtk/stamp-classes
