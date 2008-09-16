OmniBrowser-Core_FILES = \
packages/ob/core/OB-GST.st packages/ob/core/OmniBrowser.st packages/ob/core/OB-Fake.st packages/ob/core/OB-Tests-Core.st packages/ob/core/OB-Tests-Fake.st packages/ob/core/OmniBrowser.st 
$(OmniBrowser-Core_FILES):
$(srcdir)/packages/ob/core/stamp-classes: $(OmniBrowser-Core_FILES)
	touch $(srcdir)/packages/ob/core/stamp-classes
