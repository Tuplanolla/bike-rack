/// The invocation `mirror_copy(v)` yields two copies of its children:
/// one that is direct and another that has been mirrored through `v`.
module mirror_copy(v) {
  children();
  mirror(v)
    children();
}
