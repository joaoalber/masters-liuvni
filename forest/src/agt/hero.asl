//STUDENT NAME:
//STUDENT ID:

// =====================================================================
// Hero Agent - Forest Environment (CSCK504)
// =====================================================================
// The hero agent's objective is to systematically scan the 8x8 grid
// and collect exactly one gem, one coin, and one vase. Once all three
// items have been collected, the hero navigates to the goblin's position
// and drops the items there for the goblin to stash. If not all three
// items are found (e.g. the environment only contains two item types),
// the hero continues scanning indefinitely and never visits the goblin.
// =====================================================================


// --- BELIEF RULE ---
// at(P) evaluates to true when the hero occupies the same grid cell
// as agent P. It uses the pos/3 percepts provided by the environment.
// Example usage: !at(goblin) instructs the hero to reach the goblin's cell.
at(P) :- pos(P,X,Y) & pos(hero,X,Y).


// --- INITIAL GOAL ---
// The hero's first and only top-level goal is to scan the environment.
!scan.


// =====================================================================
// SCANNING PLANS (!scan)
//
// The hero uses next(slot) to traverse the grid in a left-to-right,
// top-to-bottom sequence. Before advancing each step, the hero checks
// whether the current cell holds a collectable item. Plans are checked
// in order; the first applicable one fires.
//
// The scan loops indefinitely via recursion. This is intentional: if
// not all three items exist in the environment, the hero must never
// deliver to the goblin, so it simply keeps scanning.
// =====================================================================

// [Plan 1] Termination condition: hero is carrying all three items.
//          Leave the scanning loop and begin delivery to the goblin.
+!scan
    : hero(gem) & hero(coin) & hero(vase)
    <- .print("All items collected. Proceeding to goblin.");
       !at(goblin).

// [Plan 2] A gem is at the current cell and the hero does not yet
//          have one (hero(gem) would be true if already carrying one).
//          Pick it up, then continue scanning from this same cell.
+!scan
    : gem(hero) & not hero(gem)
    <- .print("Gem found - picking it up.");
       pick(gem);
       !scan.

// [Plan 3] A coin is at the current cell and the hero does not yet
//          have one. Pick it up, then continue scanning.
+!scan
    : coin(hero) & not hero(coin)
    <- .print("Coin found - picking it up.");
       pick(coin);
       !scan.

// [Plan 4] A vase is at the current cell and the hero does not yet
//          have one. Pick it up, then continue scanning.
+!scan
    : vase(hero) & not hero(vase)
    <- .print("Vase found - picking it up.");
       pick(vase);
       !scan.

// [Plan 5] Default: nothing to collect at the current cell (or already
//          carrying this item type). Advance to the next slot and repeat.
+!scan
    : true
    <- next(slot);
       !scan.


// =====================================================================
// NAVIGATION PLAN (!at(goblin))
//
// Moves the hero step-by-step towards the goblin using move_towards.
// move_towards(X,Y) advances the hero one step (including diagonally)
// in the direction of (X,Y). The at/1 rule detects arrival.
// =====================================================================

// [Plan 6] Hero has reached the goblin's cell - proceed to drop items.
+!at(goblin)
    : at(goblin)
    <- .print("Arrived at goblin location. Dropping items now.");
       !drop_all.

// [Plan 7] Hero is not yet at the goblin's cell - take one step closer
//          and recursively re-attempt the goal.
+!at(goblin)
    : pos(goblin,X,Y)
    <- move_towards(X,Y);
       !at(goblin).


// =====================================================================
// ITEM DELIVERY (!drop_all)
//
// The hero drops all three collected items at the goblin's location.
// Each drop action causes updatePercepts() to fire in the environment,
// adding gem(goblin)/coin(goblin)/vase(goblin) percepts, which trigger
// the goblin's own stash plans defined in goblin.asl.
// =====================================================================

// [Plan 8] Drop gem, coin, and vase sequentially at the goblin's cell.
+!drop_all
    : true
    <- drop(gem);
       drop(coin);
       drop(vase);
       .print("All items delivered to the goblin. Mission complete!").
