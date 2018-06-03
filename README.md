# Schelling's Model of Segregation

Lei Mao

University of Chicago

## Introduction

Racial and ethical segregation has been a social problem in the United States. To view such segregation, New York Times has collected data across the country and presented the data on the [map](http://www.nytimes.com/projects/census/2010/explorer.html?ref=censusbureau).

In 1971, the American economist [Thomas Schelling](https://en.wikipedia.org/wiki/Thomas_Schelling) proposed an agent-based [model](https://www.jstor.org/stable/1823701) to explain this phenomenon. One approach to implement Schelling's model of segregation is to use [cellular automata](http://nifty.stanford.edu/2014/mccown-schelling-model-segregation/).

In this project, a cellular automata based Schelling's model of segregation was implemented using Haskell.

<p align="center">
    <img src = "./figures/schelling_model_cropped.png" width="80%">
</p>

The red square is the house lived by red race, the blue square is the house lived by blue race, and the white square is the empty house. The algorithm details could be found [here](https://classes.cs.uchicago.edu/current/12100-1/pa/pa2/index.html).

## Dependencies

* GHC 8.4.2
* [Gloss 1.12.0.0](https://hackage.haskell.org/package/gloss)

## Features








## Notes

To install Gloss, type the following commands in the terminal:

```bash
$ cabal update 
$ cabal install gloss 
```


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