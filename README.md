# Schelling's Model of Segregation

Lei Mao

University of Chicago

## Introduction

Racial and ethical segregation has been a social problem in the United States. To view such segregation, New York Times has collected data across the country and presented the data on the [map](http://www.nytimes.com/projects/census/2010/explorer.html?ref=censusbureau).

In 1971, the American economist [Thomas Schelling](https://en.wikipedia.org/wiki/Thomas_Schelling) proposed an agent-based [model](https://www.jstor.org/stable/1823701) to explain this phenomenon. One approach to implement Schelling's model of segregation is to use [cellular automata](http://nifty.stanford.edu/2014/mccown-schelling-model-segregation/).

In this project, a cellular automata based Schelling's model of segregation was implemented in Haskell.

<p align="center">
    <img src = "./figures/schelling_model_cropped.png" width="70%">
</p>

The red square is the house lived by red race, the blue square is the house lived by blue race, and the white square is the empty house. The algorithm details could be found [here](https://classes.cs.uchicago.edu/current/12100-1/pa/pa2/index.html).

## Dependencies

* GHC 8.4.2
* [Gloss 1.12.0.0](https://hackage.haskell.org/package/gloss)

## Files

```
.
├── Display.hs
├── Grid.hs
├── GridIO.hs
├── grid.txt
├── LICENSE.md
├── Main.hs
├── Makefile
├── README.md
├── Shuffle.hs
└── Simulation.hs
```


## Features

## Usage

### Installation

To install the program, run the following command in the terminal:

```bash
$ make
```

### Start Simlulation from Random State

To start simulation from random state, run the following command in the terminal:

```bash
$ ./Main max_steps grid_size red_percentage blue_percentage empty_percentage
```

* ``max_steps`` (integer) is the maximum number of steps the user wants to simulate. 
* ``grid_size`` (integer) is the number of rows/columns for the square grid (5 ≤ ``grid_size`` ≤ 15).
* ``red_percentage`` and ``blue_percentage`` (integer) are the percentage of race ratio of red and blue. The sum of these two numbers has to be 100 (0 ≤ ``red_percentage`` ≤ 100, 0 ≤ ``blue_percentage`` ≤ 100).
* ``empty_percentage`` (integer) is the percentage of empty houses on the grids (0 ≤ ``empty_percentage`` ≤ 100).


### Start Simlulation from Saved State

To start simulation from state saved in file, run the following command in the terminal:

```bash
$ ./Main max_steps grid.txt red_percentage blue_percentage empty_percentage
```
In this case, ``red_percentage``, ``blue_percentage``, and ``empty_percentage`` would be automatically inferred from ``grid.txt`` and the value user provided would not count.



## Notes

### Gloss Installation

To install Gloss, run the following commands in the terminal:

```bash
$ cabal update 
$ cabal install gloss 
```

### More Generalities

The program was implemented with consideration of rectangular rectangles and arbitrarily sized grids. This restrictions could be removed in the ``Main.hs`` file.




This is a simple editor for [PPM](https://en.wikipedia.org/wiki/Netpbm_format) formatted images written in Haskell. It supports negate R/G/B, gray scale, edge detection, and sharpen. The processing of image might be somewhat slower compared to similar editors written in other language (due to implementation in Haskell).

Sample PPM formatted file:

```
P3
4 4
255
0  0  0   100 0  0       0  0  0    255   0 255
0  0  0    0 255 175     0  0  0     0    0  0
0  0  0    0  0  0       0 15 175    0    0  0
255 0 255  0  0  0       0  0  0    255  255 255
```
## Features

### Negate R/G/B

R' = MaxValue - R

G' = MaxValue - G

B' = MaxValue - B

In general, MaxValue = 255

### Gray Scale

R' = (R + G + B) / 3

G' = (R + G + B) / 3

B' = (R + G + B) / 3

### Edge Detection and Sharpen 

Use [2D convolutions](http://www.songho.ca/dsp/convolution/convolution2d_example.html) and [kernels](https://en.wikipedia.org/wiki/Kernel_(image_processing)).


## Dependencies

* GHC 8.4.2
* [Gloss 1.12.0.0](https://hackage.haskell.org/package/gloss)


## Usage

### Installation

To install the program, run the following command in the shell:

```bash
$ make
```

### Start Program

To start the program, run the following command in the shell and follow the instructions in the program:

```bash
$ ./Main
```
Multiple sequential actions is also allowed.

## Demo