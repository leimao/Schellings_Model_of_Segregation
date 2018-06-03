# Makefile

all: Main

Main: Main.hs Display.hs Grid.hs Shuffle.hs Simulation.hs
	ghc -o Main Main.hs
	rm *.hi *.o

clean:
	rm Main *.hi *.o