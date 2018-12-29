# TODO: This spec doesn't reflect current functionality all that well

module Z3
  describe Expr do
    let(:a) { Z3.Int("a") }
    let(:b) { Z3.Int("b") }
    let(:c) { Z3.Bool("c") }
    let(:d) { Z3.Bool("d") }
    let(:e) { Z3.Real("e") }
    let(:f) { Z3.Real("f") }

    it "#sort returns Sort object" do
      expect(a.sort).to eq(IntSort.new)
      expect(c.sort).to eq(BoolSort.new)
      expect(e.sort).to eq(RealSort.new)
    end

    it "#to_s" do
      expect(a.sexpr).to eq("a")
    end

    it "#inspect" do
      expect(a.inspect).to eq("Int<a>")
      expect((e+f).inspect).to eq("Real<e + f>")
    end

    describe "#~" do
      it "allows negating boolean variables" do
        expect((~c).sexpr).to eq("(not c)")
      end

      it "raises exception if type cast is not possible" do
        expect{~a}.to raise_error(NoMethodError)
        expect{~e}.to raise_error(NoMethodError)
      end
    end

    describe "#&" do
      it "allows and of boolean variables" do
        expect((c & d).sexpr).to eq("(and c d)")
      end

      it "raises exception if type cast is not possible" do
        expect{a&b}.to raise_error(NoMethodError)
        expect{e&f}.to raise_error(NoMethodError)
        expect{a&c}.to raise_error(NoMethodError)
        expect{e&c}.to raise_error(NoMethodError)
        expect{c&a}.to raise_error(ArgumentError)
        expect{c&e}.to raise_error(ArgumentError)
      end
    end

    describe "#|" do
      it "allows or of boolean variables" do
        expect((c | d).sexpr).to eq("(or c d)")
      end

      it "raises exception if type cast is not possible" do
        expect{a|b}.to raise_error(NoMethodError)
        expect{e|f}.to raise_error(NoMethodError)
        expect{a|c}.to raise_error(NoMethodError)
        expect{e|c}.to raise_error(NoMethodError)
        expect{c|a}.to raise_error(ArgumentError)
        expect{c|e}.to raise_error(ArgumentError)
      end
    end

    %W[+ - * <= < >= >].each do |op|
      describe "#{op} arithmetic operator" do
        it "allows + of int or real variables" do
          expect(a.send(op, b).sexpr).to eq "(#{op} a b)"
          expect(e.send(op, f).sexpr).to eq "(#{op} e f)"
        end

        it "casts to correct type if possible" do
          expect(a.send(op, e).sexpr).to eq "(#{op} (to_real a) e)"
          expect(e.send(op, a).sexpr).to eq "(#{op} e (to_real a))"
          expect(a.send(op, 42).sexpr).to eq "(#{op} a 42)"
          expect(42.send(op, a).sexpr).to eq "(#{op} 42 a)"
          expect(a.send(op, 42.5).sexpr).to eq "(#{op} (to_real a) (/ 85.0 2.0))"
          expect(42.5.send(op, a).sexpr).to eq "(#{op} (/ 85.0 2.0) (to_real a))"
          expect(a.send(op, Rational(19, 7)).sexpr).to eq "(#{op} (to_real a) (/ 19.0 7.0))"
          expect(Rational(19, 7).send(op, a).sexpr).to eq "(#{op} (/ 19.0 7.0) (to_real a))"
          expect(e.send(op, 42).sexpr).to eq "(#{op} e 42.0)"
          expect(42.send(op, e).sexpr).to eq "(#{op} 42.0 e)"
          expect(e.send(op, 42.5).sexpr).to eq "(#{op} e (/ 85.0 2.0))"
          expect(42.5.send(op, e).sexpr).to eq "(#{op} (/ 85.0 2.0) e)"
          expect(e.send(op, Rational(19, 7)).sexpr).to eq "(#{op} e (/ 19.0 7.0))"
          expect(Rational(19, 7).send(op, e).sexpr).to eq "(#{op} (/ 19.0 7.0) e)"
        end

        it "raises exception if type cast is not possible" do
          # Int/Real has #>= #+ etc. but they don't like these arguments
          expect{a.send op, c}.to raise_error(ArgumentError)
          expect{e.send op, c}.to raise_error(ArgumentError)
          expect{a.send op, true}.to raise_error(ArgumentError)
          expect{a.send op, false}.to raise_error(ArgumentError)
          expect{e.send op, true}.to raise_error(ArgumentError)
          expect{e.send op, false}.to raise_error(ArgumentError)

          # Bool doesn't have #>= #+ etc.
          expect{c.send op, a}.to raise_error(NoMethodError)
          expect{c.send op, d}.to raise_error(NoMethodError)
          expect{c.send op, e}.to raise_error(NoMethodError)
          expect{c.send op, true}.to raise_error(NoMethodError)
          expect{c.send op, false}.to raise_error(NoMethodError)
        end
      end
    end

    describe "#==" do
      it "allows == of variables of same sort" do
        expect((a == b).sexpr).to eq "(= a b)"
        expect((c == d).sexpr).to eq "(= c d)"
        expect((e == f).sexpr).to eq "(= e f)"
      end

      it "casts to correct type if possible" do
        expect((a == 42).sexpr).to eq "(= a 42)"
        expect((42 == a).sexpr).to eq "(= 42 a)"
        expect((a == e).sexpr).to eq "(= (to_real a) e)"
        expect((e == a).sexpr).to eq "(= e (to_real a))"
        expect((c == true).sexpr).to eq "(= c true)"
        expect((c == false).sexpr).to eq "(= c false)"
        expect((a == 42.5).sexpr).to eq "(= (to_real a) (/ 85.0 2.0))"
        expect((42.5 == a).sexpr).to eq "(= (/ 85.0 2.0) (to_real a))"
        expect((e == 42.5).sexpr).to eq "(= e (/ 85.0 2.0))"
        expect((42.5 == e).sexpr).to eq "(= (/ 85.0 2.0) e)"
        expect((Rational(19, 7) == e).sexpr).to eq "(= (/ 19.0 7.0) e)"
        expect((e == Rational(19, 7)).sexpr).to eq "(= e (/ 19.0 7.0))"
        expect((true == c).sexpr).to eq "(= c true)"
        expect((false == c).sexpr).to eq "(= c false)"
      end

      it "raises exception if type cast is not possible" do
        expect{a == c}.to raise_error(ArgumentError)
        expect{e == c}.to raise_error(ArgumentError)
        expect{a == true}.to raise_error(ArgumentError)
        expect{e == true}.to raise_error(ArgumentError)
        expect{true == a}.to raise_error(ArgumentError)
        expect{true == e}.to raise_error(ArgumentError)
        expect{c == 42}.to raise_error(ArgumentError)
        expect{c == 42.5}.to raise_error(ArgumentError)
        expect{42 == c}.to raise_error(ArgumentError)
        expect{42.5 == c}.to raise_error(ArgumentError)
      end
    end

    describe "#!=" do
      it "allows != of variables of same sort" do
        expect((a != b).sexpr).to eq "(distinct a b)"
        expect((c != d).sexpr).to eq "(distinct c d)"
        expect((e != f).sexpr).to eq "(distinct e f)"
      end

      it "casts to correct type if possible" do
        expect((a != 42).sexpr).to eq "(distinct a 42)"
        expect((42 != a).sexpr).to eq "(distinct 42 a)"
        expect((a != e).sexpr).to eq "(distinct (to_real a) e)"
        expect((e != a).sexpr).to eq "(distinct e (to_real a))"
        expect((c != true).sexpr).to eq "(distinct c true)"
        expect((c != false).sexpr).to eq "(distinct c false)"
        expect((a != 42.5).sexpr).to eq "(distinct (to_real a) (/ 85.0 2.0))"
        expect((42.5 != a).sexpr).to eq "(distinct (/ 85.0 2.0) (to_real a))"
        expect((e != 42.5).sexpr).to eq "(distinct e (/ 85.0 2.0))"
        expect((42.5 != e).sexpr).to eq "(distinct (/ 85.0 2.0) e)"
        expect((true != c).sexpr).to eq "(distinct c true)"
        expect((false != c).sexpr).to eq "(distinct c false)"
      end

      it "raises exception if type cast is not possible" do
        expect{a != c}.to raise_error(ArgumentError)
        expect{e != c}.to raise_error(ArgumentError)
        expect{a != true}.to raise_error(ArgumentError)
        expect{e != true}.to raise_error(ArgumentError)
        expect{true != a}.to raise_error(ArgumentError)
        expect{true != e}.to raise_error(ArgumentError)
        expect{c != 42}.to raise_error(ArgumentError)
        expect{c != 42.5}.to raise_error(ArgumentError)
        expect{c != Rational(19, 7)}.to raise_error(ArgumentError)
        expect{42 != c}.to raise_error(ArgumentError)
        expect{Rational(19, 7) != c}.to raise_error(ArgumentError)
      end
    end
  end

  describe "#hash / #eql?" do
    let(:x1) { Z3.Int("x") }
    let(:x2) { Z3.Int("x") }
    let(:y1) { Z3.Int("y") }
    let(:y2) { Z3.Int("y") }
    let(:e1) { x1 + y1 }
    let(:e2) { x2 + y2 }
    let(:f1) { y1 + x1 }
    let(:f2) { y2 + x2 }
    let(:samples) { [x1, x2, y1, y2, e1, e2, f1, f2] }

    it "object is eql? to itself" do
      expect(x1.eql?(x1)).to be true
      expect(y1.eql?(y1)).to be true
      expect(e1.eql?(e1)).to be true

      expect(x1.eql?(y1)).to be false
      expect(x1.eql?(e1)).to be false
    end

    it "object is eql? to structurally identical object" do
      expect(x1.eql?(x2)).to be true
      expect(y1.eql?(y2)).to be true
      expect(e1.eql?(e2)).to be true
      expect(f1.eql?(f2)).to be true
    end

    it "object is not eql? to semantically identical object" do
      expect(e1.eql?(f1)).to be false
    end

    it "#hash aligns with #eql?" do
      samples.each do |a|
        samples.each do |b|
          if a.eql?(b)
            expect(a.hash).to eq(b.hash)
          else
            expect(a.hash).to_not eq(b.hash)
          end
        end
      end
    end

    it "works when used as Hash keys" do
      ht = {}
      ht[x1] = 1
      ht[y1] = 2
      ht[e1] = 3
      ht[e2] = 4

      expect(ht.size).to eq(3)
      expect(ht[x1]).to eq(1)
      expect(ht[x2]).to eq(1)
      expect(ht[y1]).to eq(2)
      expect(ht[y2]).to eq(2)
      expect(ht[e1]).to eq(4)
      expect(ht[e2]).to eq(4)
      expect(ht[f1]).to eq(nil)
      expect(ht[f2]).to eq(nil)
    end
  end
end
