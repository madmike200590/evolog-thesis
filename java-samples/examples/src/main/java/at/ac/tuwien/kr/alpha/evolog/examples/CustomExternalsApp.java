package at.ac.tuwien.kr.alpha.evolog.examples;

import at.ac.tuwien.kr.alpha.api.Alpha;
import at.ac.tuwien.kr.alpha.api.common.fixedinterpretations.PredicateInterpretation;
import at.ac.tuwien.kr.alpha.api.impl.AlphaFactory;
import at.ac.tuwien.kr.alpha.api.programs.InputProgram;
import at.ac.tuwien.kr.alpha.commons.externals.Externals;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Map;

public class CustomExternalsApp {

	public static void main(String[] args) throws IOException {
		Alpha alpha = AlphaFactory.newAlpha();
		Map<String, PredicateInterpretation> customExternals =
				Externals.scan(CustomExternals.class);
		String aspCode =
				Files.readString(
						Paths.get("src/main/resources/customExternals.asp"));
						InputProgram program =
								alpha.readProgramString(aspCode,
						customExternals);
		alpha.solve(program).forEach(as -> {
			System.out.println("Answer set:\n" + as);
		});
	}

}
