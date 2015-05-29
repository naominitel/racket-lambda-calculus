## λ-calculus language for Racket

This is a ```#lang``` module that implements a simple λ-calculus language
inside Racket.

It allows only the following forms:
* ```lambda``` and ```λ```
* A simple let that allows to bind a single variable without recursive
  definitions: ```(let id expr)```
* Functions to convert lists and integers into their usual encoding in λ-calculus
* An if macro based on the λ-calculus usual encoding for ```true``` and ```false```

Literals and quoted data are available but since no standard operator is, the
only possible use of them is through the conversion functions mentioned above.

This module is primarily intended at teaching purposes, to be used to implement
λ-calculus encodings and constructions in Racket. Only the required constructions
are provided (and literals for nicer syntax) and it's up to you to implement
everything else: arithmetics on Peano integers, fixpoint combinators, Church
 encoding for pairs, lists, etc...

### Usage

The easier way to use this module is to install it as a package using the
```raco``` tool:

```shell
cd lambda-calculus
raco pkg install
```

To update the package later:

```shell
# at the repository root!
raco pkg update --link lambda-calculus
```

It can then be used inside any Racket module:

```racket
#lang lambda-calculus

(let id (λ (x) x))
```
