# Some test related definitions

# Python project?
ifdef IS_PYTHON_PROJECT

# Assume tests are localted in "tests" folder by default
# (can be overriden)
TEST_FOLDER ?= tests/

# All Python test files
TEST_FILES := $(shell find $(TEST_FOLDER) -name *.py)

# Flake8 report
FLAKE_ROOT := $(OUTPUT_ROOT)/flake-report
FLAKE_REPORT := $(FLAKE_ROOT)/index.html

# Tests report
TEST_ROOT := $(OUTPUT_ROOT)/tests
TEST_REPORT := $(OUTPUT_ROOT)/tests.xml

# Time file for incremental tests behavior
TEST_TIME := $(CACHE_DIR)/tests.time

endif # IS_PYTHON_PROJECT