all: fmt lint

fmt:
	stylua lua/ --config-path=.stylua.toml

lint:
	luacheck lua/ --config=.luacheckrc
