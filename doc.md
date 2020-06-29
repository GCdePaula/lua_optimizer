# About

The lua_optimizer is a program that performs optimizations on Lua code. We use a technique called abstract interpretation to accomplish two optimizations: constant propagation and unreachable code elimination. The motivation for this work is that these types of optimizations cannot be done by a single-pass compiler. It is based on the Conditional Constant Propagation algorithm of Wegman and Zadeck.

## Overview

Abstract interpretation is a way to symbolically execute a program. In our analysis, perform abstract interpretation to search for variables that are constant. Let's look at a few examples.

```
x = 1
y = x
```

We can determine that after the first line `x` is constant with the value `1`, because we are assigning the constant `1` to `x`. On the second line, we can also determine that `y` is constant, because we are assigning the constant `x` to `y`. Let's add conditions to our program.

```
x = 1
if x > 0 then
  y = 2
else
  y = 0
end
```

Knowing that `x` is a constant with the value `1`, we know which branch our program will take. With this knowledge, we determine that after this snippet, `y` is also constant, with the value `3`. Finally, let's look at loops.


```
x = 0
repeat
  x = x + 1
until condition
```

Here, `x` is not constant. First, let's assume that `condition` is unknown, so there's no way to know how many times the statement `x = x + 1` will be executed. On the first iteration that statement assigns `1` to `x`, on the second iteration it assigns `2` to `x`, and so forth. So it is clear that `x` is not constant through the loop's execution.

This analysis is more complex than the previous ones. The issue is that there are two ways of getting inside the loop. That is, in the control flow graph of this program, the `repeat until` node has two incident edges. One coming from outside (that is, from the preceding assignment node), and another from the bottom of the loop (the back edge). And in the real execution the back edge will be traversed multiple times.

We need to revise a few concepts to better understand what's going on in this example. First, let's revise what is a lattice.


## Lattice

A lattice is a partially ordered set in which every two elements have a unique supremum (also called a least upper bound or join) and a unique infimum (also called a greatest lower bound or meet). We use a simple flat lattice in our analysis. There are three different levels of elements: the highest element is Top, the lowest is Bottom, and all elements in the middle are Constants (e.g. all numbers, all strings, booleans, nil). Note that there are an infinite number of elements in the middle level. However, the lattice still has a bounded depth as every element is at least two "steps" away from bottom.

The abstract interpretation algorithm associates a lattice element to every variable. Every element has a different meaning:

* Top means the variable is constant, yet to be determined.
* At the middle, Constants element each represent a different constant. That is, variable with this element is a known constant.
* Bottom means the element is not constant (or that it cannot be guaranteed to be constant).

The most relevant operation between elements for our analysis is the meet operation. It follows three associative, commutative rules: meet between anything and Top is anything, meet between anything and Bottom is Bottom, and meet between two Constants is either Bottom (if they are different) or their common value (if they are equal).


## The Optimistic Assumption

Our analysis is done under the optimistic assumption. The abstract interpretation optimistically assumes every variable is constant, and falls back into a more pessimistic truth if it cannot prove the initial assumption was correct. Let's go back to our last example.

```
x = 0
repeat
  x = x + 1
until condition
```

After symbolically executing the first line, we know that `x` is constant with value `0`. However, at the loop's top we cannot guarantee that `x` continues to be constant, because the loop assigns to it. We don't know if we got there from the previous statement, or if through the loop's back edge.

In comes the optimistic assumption. We assume `x` is constant, and try to prove its correctness. Inside, the first line assigns to `x` the value of `x` (which, under our assumption, is `0`) plus `1`. So after that line, `x` is a constant with value `1`. When we reach the loop's bottom, as `condition` is not known, we need to consider the possibility of repeating the loop's body. Back at the loop's top we reach a conflict. The value of `x` can be `0` (if it came from outside the loop) or `1` (if it came from the back edge). The meet operator between Constant `0` and Constant `1` is Bottom. As such, we come to the conclusion our assumption was incorrect: `x` is not constant.

Let's look into a more interesting example.

```
x = 1
repeat
  x = 2 - x
until condition
```

After symbolically executing the first line, `x` is the Constant `1`. When we enter the loop's body, we assume `x` remains constant and try to prove its correctness. After executing the assignment statement, under our assumption, `x` is the Constant `1`, because `2 - 1` is `1`. Again, as we don't know the value of `condition`, we have to consider the loop will execute multiple times. Back at the top, `x` has two possible elements associated with it: the one coming from outside, and another from the back edge. We perform the meet operator between the two. That is, Constant `1` meet Constant `1`. Differently from the previous example, the meet results in the Constant `1`, as the meet between two Constants is their common value if they are the same. So we proved the correctness of our assumption: `x` was indeed constant.

When combining constant propagation and unreachable code elimination there's the problem of phase-ordering. This occurs because the two optimizations interact, making use of the optimistic assumption within themselves, but not between themselves. The method uses these two analyses making both assumptions at the same time, and combining them optimistically. Facts that simultaneously require both optimistic assumptions are found. It is stronger than repeating separate analysis any number of times.


Let's look at a more formal description of our algorithm.


## Fixed Point and Complex Lattices

In abstract terms, our analysis is looking for the greatest fixed point. We begin by assuming every variable is an unknown constant (Top), and try to prove that is true. While trying to prove the correctness of our assumption, we may need to fall back into a more pessimistic truth, lowering lattice elements until we reach a stable configuration. That configuration is the fixed point.

Note that lowering every variable to Bottom is a stable configuration. However, it is not a very useful fixed point. We want to find the greatest fixed point, the configuration in which the largest number of variables is constant, because it gives us more information. That information is then used for constant propagation and unreachable code elimination. More on that later.

We could also use a more complex lattice, where types are also added (e.g. the meet of two different numbers is not Bottom, but an element that represents the number type), and "Truthy" and "Falsy" elements (e.g. the meet between Numbers, Strings and True is "Truthy", the meet between Nil and False is "Falsy"). Though these changes would increase the depth of our lattice, it would still remain bounded, and might provide more information for our optimizations.


## Abstract Interpretation

The algorithm operates on the program's control flow graph. The nodes represent statements, and directed edges represent the control flow. On top of that, each node contains a pair of cells: an "in cell" and an "out cell". A cell is a structure that contains the program's state at that point of execution. It is essentially a map of all variables in scope, associating each variable to a lattice element.

The abstract interpretation works by scheduling edges and executing the node those edges point to. We use a simple iterative worklist, containing CFG edges that need be processed. We start with an empty worklist, marking all edges as "not executable", and setting all variables in all cells to Top. This is our optimistic assumption.

The first step of the abstract interpretation is marking the start edge as executable, and adding it to the previously empty worklist. While the worklist is not empty, we remove an edge from the list and execute the node it is pointing to. After executing a node, we schedule new edges to be processed, marking them as executable in the process.

Executing a node involves a few steps:

  1. Calculate the new "in cell" from all executable incident edges. The algorithm gets all preceding nodes whose edges are traversable, and performs the meet operation between their "out cells". In other words, for all executable in edges, we get the "out cell" of the node they're from, and for each variable of those cells we perform the meet operation between their lattice elements.

  2. If the node hasn't been executed before, mark the node as executed and skip to step 3.

      Otherwise, compare the new "in cell" with the previous one. This is the stop condition of our algorithm. If they're equal, we stop this node's execution, because whatever the node is about to execute will yield the same results as the previous iteration. In other words, for the same pair in-state/execution, the out-state will be the same. Therefore there isn't any state changes to propagate, they've already been propagated before.

  3. Execute the node using the new "in cell" as its state, update the "out cell" with the changes from the execution, and schedule out edges. Scheduled edges are marked as executable. This step depends on the node type:

      * Assignment nodes update a variable's lattice element and schedule its single out edge.

      * Local assignments nodes add a variable to the scope, assign it a value (possibly nil if there're no expressions), and schedule its single out edge.

      * If, while, and repeat until nodes evaluate their condition, and conditionally schedule its out edges. If the condition is a constant, only one branch needs to be scheduled. If it is Bottom, both must be scheduled, as its condition's value is unknown.

      * Generic and numeric for nodes add variables to the block's scope, setting their lattice element to Bottom. We then schedules both edges.

      * Function call statement nodes are not evaluated. Their single out edge is scheduled normally.

      * Return statements are not evaluated. They do not schedule edges.

When there are no more edges in the work list, the abstract interpretation is done and the fixed point has been found.


## Edges vs Nodes

In our method we schedule edges, rather than nodes. A different approach could, instead, associate the executable flag to nodes. However, this is not optimal, as we can find more constants scheduling edges. The reason is that two nodes may be executable and there may be an edge between them, but that edge may not be traversable. This would result in an unnecessary meet operation that could potentially set bottom to a constant variable. Let's look at an example from Wegman and Zadeck:

```
i = 1
while true do
  i = i + 1
  if i == 10 then
    break
  end
end
print(i)
```

Here, the edge from the `while` node is not traversable, as its condition is always true. The only way to reach the `print` statement is through the break inside the loop, because the only executable edge exiting the loop is the one coming from inside the `if` statement. At the `print` statement, the meet between all its traversable in edges will yield that `i` is a constant with value `10`. However, If we associate the executable flag to the nodes, when doing the meet between all previous executable nodes, we would conclude that `i` is Bottom.


## Constant Propagation and Unreachable Code Elimination

Now that the fixed point has been found we can perform constant propagation, constant folding and unreachable code elimination. At every node, we have the lattice element associated with each variable at that scope. With that information, we can substitute all occurrences of constant variables with their respective values.

The algorithm is essentially a depth first search in the program's CFG. However, only edges marked as executable are traversed. At every node, all expressions are inspected, and constant variables are substituted by their value and constants are folded as needed. Code that is unreachable is not processed.

Constant conditions are also eliminated. Whenever we find an `if` statement with a constant condition, we eliminate the conditional branching. Let's look at a few examples.

```
if constant then
  -- then body
else
  -- else body
end
```

If `constant` evaluates to true, then the entire statement is transformed into a block of code without conditional branching:

```
do
  -- then body
end
```

The reason for the `do` statement is to preserve the block's scope.

We also transform `while` and `repeat until` statements. On `while` statements, if the condition evaluates to false, we eliminate the loop entirely, otherwise (if there are no executable `break` and `goto` statements) we eliminate everything that comes after it. On `repeat until` statements, if the condition evaluates to true, we transform it in a single `do` statement, otherwise (if there are no executable `break` and `goto` statements) we eliminate everything that comes after it.



## Preparing the Abstract Syntax Tree

Our program starts by parsing Lua code using the LPeg library, generating an abstract syntax tree. But for our analysis, we require a control flow graph of the program, along with information about the scope and upvalues. So we execute a preparation step before doing the abstract interpretation, doing the following:

  * Build the CFG on top of the AST, without destroying the latter. That is, the statement nodes of the AST become the nodes of the CFG, and we add just edges between said nodes, without losing the original AST structure.

  * Create the "in cells" and "out cells" for every node, initializing all their variables to Top. Note that the cells only contain the variables in scope at that point of the program, so we also have to build the scope in this step.

  * Find upvalues setting their lattice element at every cell to Bottom. We need to do this in case we call some function that changes the value of those variables.

  * Rename each variable to a unique name, and change all global variables to an `_ENV` table lookup (global `x` becomes `_ENV["x"]`). This step isn't exactly necessary, but for future work with function inlining this will be needed.

  * Associate all closures with an integer, so we can represent a function element as an index.

This is done with a single iteration over the AST, recursively executing it for closures.


## Putting It All Together

Our implementation has five main steps.

  1. Parse input Lua code using the LPeg library, generating an abstract syntax tree.

  2. Prepare the AST, as described previously.

  3. Abstract interpretation of the program as described previously. After this is done, all variables have an associated lattice element.

  4. Using the found constants, perform constant propagation, constant folding and unreachable code elimination. This step modifies the AST itself.

  5. From the modified AST, output Lua code. Unlike the previous steps, this one iterates over the AST structure, rather than the CFG. Only nodes marked as visited from the previous DFS are considered.

Once this is done, we output the optimized Lua code.

