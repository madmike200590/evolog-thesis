import at.ac.tuwien.kr.alpha.evolog.examples.CustomExternals;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class CustomExternalsTest {

	@Test
	void binetRounding() {
		//assertEquals(0, CustomExternals.binetRounding(0));
		assertEquals(1, CustomExternals.binetRounding(1));
		assertEquals(1, CustomExternals.binetRounding(2));
		assertEquals(2, CustomExternals.binetRounding(3));
		assertEquals(3, CustomExternals.binetRounding(4));
		assertEquals(5, CustomExternals.binetRounding(5));
		assertEquals(8, CustomExternals.binetRounding(6));
		assertEquals(13, CustomExternals.binetRounding(7));
		assertEquals(21, CustomExternals.binetRounding(8));
		assertEquals(34, CustomExternals.binetRounding(9));
		assertEquals(55, CustomExternals.binetRounding(10));
		assertEquals(6765, CustomExternals.binetRounding(20));
		assertEquals(75025, CustomExternals.binetRounding(25));
		assertEquals(832040, CustomExternals.binetRounding(30));
		assertEquals(14930352, CustomExternals.binetRounding(36));
	}
}
