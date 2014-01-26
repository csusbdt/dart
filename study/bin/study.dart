Function makeAdder(num x) {
  adder(num y) {
    return x + y;
  }
  return adder;
}

void main() {
  Function add2 = makeAdder(2);
  assert(add2(11) == 13);
  
  print("All tests passed.");
}

