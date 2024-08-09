package at.ac.tuwien.kr.alpha.evolog.examples;

import at.ac.tuwien.kr.alpha.api.Alpha;
import at.ac.tuwien.kr.alpha.api.common.fixedinterpretations.PredicateInterpretation;
import at.ac.tuwien.kr.alpha.api.impl.AlphaFactory;
import at.ac.tuwien.kr.alpha.api.programs.InputProgram;
import at.ac.tuwien.kr.alpha.api.programs.NormalProgram;
import at.ac.tuwien.kr.alpha.commons.externals.Externals;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Map;

public class ColorNumberingApp {

	public static void main(String[] args) throws IOException {
		Alpha alpha = AlphaFactory.newAlpha();
		String aspCode =
				Files.readString(
						Paths.get("src/main/resources/color_numbering.asp"));
		NormalProgram normalized = alpha.normalizeProgram(
				alpha.readProgramString(aspCode));
		System.out.println(normalized);
	}

}
