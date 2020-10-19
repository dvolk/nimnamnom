APPNAME = nimnamnom
NIMC=nim c
NIMJS=nim js
SOURCES = $(shell ls src/*.nim)
BUILDARGS = 
RELEASE_ARGS = -d:release
DEBUG_ARGS = -d:debug

release: $(SOURCES)
	${NIMC} $(RELEASE_ARGS) $(BUILDARGS) -o:${APPNAME} src/nimnamnom.nim

debug: $(SOURCES)
	${NIMC} $(DEBUG_ARGS) $(BUILDARGS) -o:${APPNAME}_debug src/nimnamnom.nim

run: release
	./${APPNAME}

rund: debug
	./${APPNAME}_debug

web: $(SOURCES)
	${NIMJS} $(RELEASE_ARGS) $(BUILDARGS) -o:$(APPNAME).js src/nimnamnom.nim

webd: $(SOURCES)
	${NIMJS} $(DEBUG_ARGS) $(BUILDARGS) -o:$(APPNAME).js src/nimnamnom.nim

.PHONY: release debug run rund web webd
