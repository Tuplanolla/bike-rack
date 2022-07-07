/// The invocation `rep(n, v, a)` produces `n` repetitions
/// of the elements of the vector `v`,
/// starting from the accumulator value `a`.
function rep(n, v, a = []) =
  0 < n ? rep(n - 1, v, concat(v, a)) : a;

/// The invocation `rev(v, i, a)` reverses the order
/// of the elements of the vector `v`,
/// starting from the index `i` and the accumulator value `a`.
function rev(v, i = 0, a = []) =
  i < len(v) ? rev(v, 1 + i, concat([v[i]], a)) : a;

/// The invocation `sum(v, i, a)` yields the sum
/// of the elements of the vector `v`,
/// starting from the index `i` and the accumulator value `a`.
function sum(v, i = 0, a = 0) =
  i < len(v) ? sum(v, 1 + i, a + v[i]) : a;

/// The invocation `cumsum(v, i, a)` yields a vector
/// of the cumulative partial sums of the elements of the vector `v`,
/// starting from the index `i` and the accumulator value `a`.
function cumsum(v, i = 0, a = 0) =
  i < len(v) ? concat([a], cumsum(v, 1 + i, a + v[i])) : a;

/// The invocation `find(x, v, a)` yields the first index
/// in the vector `v` that is equal to `x` or `undef` otherwise.
function find(x, v, i = 0) =
  i < len(v) ? (v[i] == x ? i : find(x, v, 1 + i)) : undef;
