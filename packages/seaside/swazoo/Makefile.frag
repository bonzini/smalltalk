Seaside_FILES = \
packages/seaside/swazoo/ChangeLog packages/seaside/swazoo/Seaside-Adapters-Swazoo.st 
$(Seaside_FILES):
$(srcdir)/packages/seaside/swazoo/stamp-classes: $(Seaside_FILES)
	touch $(srcdir)/packages/seaside/swazoo/stamp-classes
