LUA_DIR := $(CURDIR)/lua@5.4/src
ALL_LIBS:= tests/self_opt/files/libs src/libs

.PHONY: all_libs $(ALL_LIBS)

all_libs: $(ALL_LIBS)

$(ALL_LIBS):
	$(MAKE) --directory=$@ LUAINC=$(LUA_DIR) LUA_INC=$(LUA_DIR) LUADIR=$(LUA_DIR)
	cp ./lua@5.4/src/lua lua
	cp ./lua@5.4/src/luac luac

