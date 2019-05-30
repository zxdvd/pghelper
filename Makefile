
EXTENSION = myhelper
EXT_VERSION = 0.1

DATA = $(EXTENSION)--$(EXT_VERSION).sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

all: $(EXTENSION)--$(EXT_VERSION).sql

$(EXTENSION)--$(EXT_VERSION).sql: $(sort $(wildcard sql/*.sql))
	cat $^ > $@
