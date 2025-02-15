package com.github.madmike200590.dimacstranslate;

import org.apache.commons.lang3.tuple.ImmutablePair;

import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Stream;

public class DimacsTranslator {

	public static void main(String[] args) throws IOException {
		if(args.length != 3) {
			System.err.println("Usage: DimacsToXmlTranslator <mode> <input-file> <output-file>");
			return;
		}
		Mode mode = Mode.valueOf(args[0].toUpperCase());
		Path in = Path.of(args[1]);
		Path out = Path.of(args[2]);
		if(!Files.exists(in)) {
			System.err.println("Input file does not exist: " + in);
			return;
		}
		if(Files.exists(out)) {
			System.err.println("Output file already exists: " + out);
			return;
		}
		Set<String> vertices = new HashSet<>();
		Set<ImmutablePair<String, String>> edges = new HashSet<>();
		// Parse dimacs file
		try (Stream<String> lines = Files.lines(in).filter(line -> line.startsWith("e"))) {
			lines.forEach(line -> {
				String[] parts = line.split(" ");
				if(parts.length != 3) {
					System.err.println("Invalid line: " + line);
					return;
				}
				vertices.add(parts[1]);
				vertices.add(parts[2]);
				edges.add(new ImmutablePair<>(parts[1], parts[2]));
			});
		} catch (IOException ex) {
			System.err.println("Error reading input file: " + ex.getMessage());
		}
	}

	private static void translateToXml(Set<String> vertices, Set<ImmutablePair<String, String>> edges, Path out) {
		// Write xml file
		try (PrintStream ps = new PrintStream(Files.newOutputStream(out))) {
			ps.println("<graph directed=\"false\">");
			ps.println("  <vertices>");
			for(String vertex : vertices) {
				ps.println("    <vertex>" + vertex + "</vertex>");
			}
			ps.println("  </vertices>");
			ps.println("  <edges>");
			for(ImmutablePair<String, String> edge : edges) {
				ps.println("    <edge><source>" + edge.getLeft() + "</source><target>" + edge.getRight() + "</target></edge>");
			}
			ps.println("  </edges>");
			ps.println("</graph>");
		} catch (IOException ex) {
			System.err.println("Error writing output file: " + ex.getMessage());
		}
	}

	private static void translateToAsp(Set<String> vertices, Set<ImmutablePair<String, String>> edges, Path out) {
		// Write asp facts
		try (PrintStream ps = new PrintStream(Files.newOutputStream(out))) {
			for(String vertex : vertices) {
				ps.println("vertex(" + vertex + ").");
			}
			for(ImmutablePair<String, String> edge : edges) {
				ps.println("edge(" + edge.getLeft() + ", " + edge.getRight() + ").");
			}
		} catch (IOException ex) {
			System.err.println("Error writing output file: " + ex.getMessage());
		}
	}

	private static void translateToAsp(Path in, Path out) {

	}

	enum Mode {
		XML,
		ASP;
	}


}
