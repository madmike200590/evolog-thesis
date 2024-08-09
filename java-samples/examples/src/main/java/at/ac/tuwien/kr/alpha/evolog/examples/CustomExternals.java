package at.ac.tuwien.kr.alpha.evolog.examples;

import at.ac.tuwien.kr.alpha.api.externals.Predicate;
import at.ac.tuwien.kr.alpha.api.programs.terms.ConstantTerm;
import at.ac.tuwien.kr.alpha.commons.programs.terms.Terms;

import java.util.List;
import java.util.Set;

public class CustomExternals {

	private static final double GOLDEN_RATIO = 1.618033988749894;
	private static final double SQRT_5 = Math.sqrt(5.0);

	/**
	 * Calculates the n-th Fibonacci number using a variant of Binet's Formula
	 * taken from {@link <a href="https://en.wikipedia.org/wiki/Fibonacci_sequence#Binet's_formula">here</a>}
	 */
	@Predicate(name="fibonacci_number")
	public static Set<List<ConstantTerm<Integer>>> fibonacciNumber(int n) {
		return Set.of(List.of(Terms.newConstant(binetRounding(n))));
	}

	public static int binetRounding(int n) {
		return (int) Math.round(Math.pow(GOLDEN_RATIO, n) / SQRT_5);
	}

}
