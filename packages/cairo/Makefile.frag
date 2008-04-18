Cairo_FILES = \
packages/cairo/CairoFuncs.st packages/cairo/CairoContext.st packages/cairo/CairoMatrix.st packages/cairo/CairoTransform.st 
$(Cairo_FILES):
$(srcdir)/packages/cairo/stamp-classes: $(Cairo_FILES)
	touch $(srcdir)/packages/cairo/stamp-classes
