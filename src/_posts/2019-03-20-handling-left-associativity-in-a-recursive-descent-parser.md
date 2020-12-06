---
layout: post
title: Handling Left Associativity in a Recursive Descent Parser
date: 2019-03-20 00:00:00 -0400
tags:
  - parser
  - recursive-descent
  - associativity
---

# Introduction

I recently decided to try implementing a recursive descent parser for a simple arithmetic expression language in C++. I did this partly as a learning exercise as well as to gain better insight into how I may be able to apply object-oriented design patterns when developing a compiler front-end or data deserializer.

First, I came up with a simple grammar for arithmetic expressions and wrote it down in EBNF. Then, I naively began implementing a recursive descent parser for it. The pattern I followed for implementing the parser is similar to the one described on the Wikipedia page for a [recursive descent parser](https://en.wikipedia.org/wiki/Recursive_descent_parser). In my design, the lookahead token is a member variable of the Parser class and each production rule in the grammar has a corresponding private method, also located in the Parser class. The production rule methods each return the part of the abstract syntax tree which they are meant to recognize. This way, the entire tree is built using potentially recursive calls from one production rule to another, just like how the EBNF grammar is written.

It's actually pretty straightforward. Even operator precedence is handled properly by nesting higher precedence operators further down the production rules. At least, it seemed straightforward until I unit-tested and discovered incorrect parse trees were being generated. The problem was I wasn't building left-associative trees for left-associative operators. Instead, I was making the entire tree right-associative because that is the inherent nature of a recursive descent parser. This problem has been [talked about before](https://eli.thegreenplace.net/2009/03/14/some-problems-of-recursive-descent-parsers), but I wanted to share my experience with implementing a solution in C++.

## Initial Implementation

The first implementation I came up with used recursion exclusively to build the parse tree from left-to-right. The recursion used here was just meant as a form of looping since the production rule is calling itself to build the right side of the binary operator. The `Parser::term()` function was implemented the same way.

```cpp
std::unique_ptr<Ast::Expression> Parser::expression()
{
    auto tree = term();

    if (match(ID::Plus, ID::Minus)) {
        auto op = binaryOperator();
        op->left = std::move(tree);
        op->right = expression();
        tree = std::move(op);
    }

    return tree;
}
```

Note, the `Parser::binaryOperator()` function is just a factory function which creates an instance of the correct type of `BinaryOperator` subclass based on the current token ID.

## The Problem

The problem with the initial approach is it inadvertently built the expression and term subtrees from right-to-left, not left-to-right. What was happening was, each recursive call to `Parser::expression()` would nest the next terminal or expression under the right side of the current binary operator. Thus, higher precedence was always given to the right side of every expression.

Here's an example of how the expression `4 - 2 - 1` would be parsed using the initial implementation. The resulting parse tree is expressed as an [S-expression](https://en.wikipedia.org/wiki/S-expression).

```lisp
(4)             ; Got 4
(- 4 nil)       ; Subtraction, previous tree becomes the left side expression
(- 4 2)         ; Got 2, current tree sets the number as the right side expression
(- 4 (- 2 nil)) ; Subtraction, set it to the right side of the current tree, and the previous right side becomes its left side
(- 4 (- 2 1))   ; Got 1, number goes to the right side again
```

The resulting tree would be evaluated in depth-first order meaning an incorrect result of `4 - (2 - 1) = 4 - 1 = 3` would be produced.

## Refined Implementation

For the next implementation, I realized I needed to make each of the expression and term operators left associative. To accomplish this, I needed to make sure the left side of each expression and term were moved deeper in the tree as each new infix operator was encountered. What I came up with is a loop that moves each previously encountered parse tree down the left side of the current and top-most expression, all while only maintaining a pointer to that top-most expression (the tree).

```cpp
std::unique_ptr<Ast::Expression> Parser::expression()
{
    auto tree = term();

    while (match(ID::Plus, ID::Minus)) { // Changed to a while loop
        auto op = binaryOperator();
        op->left = std::move(tree);
        op->right = term();              // No direct recursion here
        tree = std::move(op);
    }

    return tree;
}
```

The result is a parse tree where expressions that appear first when being parsed also appear properly nested and on the left side of the tree. Below is the example expression `4 - 2 - 1` shown parsed correctly using the refined implementation.

```lisp
(4)             ; Got 4
(- 4 nil)       ; Subtraction, previous tree becomes the left side expression
(- 4 2)         ; Got 2, current tree sets the number as the right side expression
(- (- 4 2) nil) ; Subtraction, previous tree becomes the left side expression again
(- (- 4 2) 1)   ; Got 1, number goes to the right side again
```

Since the resulting tree is evaluated depth-first, a correct result of `(4 - 2) - 1 = 2 - 1 = 1` would be produced.
