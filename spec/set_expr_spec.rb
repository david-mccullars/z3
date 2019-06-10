# This test is really bad, all of these have multiple solutions.
module Z3
  describe SetExpr do
    let(:sort) { SetSort.new(IntSort.new) }
    let(:a) { sort.var("a") }
    let(:b) { sort.var("b") }
    let(:c) { sort.var("c") }
    let(:x) { Z3::Bool("x") }

    # TODO: Formatting is dreadful
    it "== and !=" do
      expect([a == b, b != c]).to have_solution(
        a => "store(const(false), 0, true)",
        b => "store(const(false), 0, true)",
        c => "const(false)",
      )
    end

    if Z3.version >= "4.5"
      # Only works in z3 4.5, 4.4 (like on Ubuntu) returns bad stuff
      it "union" do
        expect([
          a.include?(1),
          a.include?(2),
          !a.include?(3),
          !b.include?(1),
          b.include?(2),
          b.include?(3),
          c == a.union(b),
        ]).to have_solution(
          a => "store(const(true), 3, false)",
          b => "store(const(true), 1, false)",
          c => "(lambda ((x!1 Int)) (or (not (= x!1 3)) (not (= x!1 1))))",
        )
      end

      it "difference" do
        expect([
          a.include?(1),
          a.include?(2),
          !a.include?(3),
          !b.include?(1),
          b.include?(2),
          b.include?(3),
          c == a.difference(b),
        ]).to have_solution(
          a => "store(const(true), 3, false)",
          b => "store(const(true), 1, false)",
          c => "(lambda ((x!1 Int)) (and (not (= x!1 3)) (= x!1 1)))",
        )
      end

      it "intersection" do
        expect([
          a.include?(1),
          a.include?(2),
          !a.include?(3),
          !b.include?(1),
          b.include?(2),
          b.include?(3),
          c == a.intersection(b),
        ]).to have_solution(
          a => "store(const(true), 3, false)",
          b => "store(const(true), 1, false)",
          c => "(lambda ((x!1 Int)) (or (not (= x!1 3)) (not (= x!1 1))))",
        )
      end
    end
  end
end
