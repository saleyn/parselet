all: compile

compile:
	mix $@

run:
	iex -S mix

clean:
	mix $@

publish:
	mix hex $(if $(replace),publish --replace,cut)
