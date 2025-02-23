package com.github.madmike200590.graphcol;

import at.ac.tuwien.kr.alpha.api.Alpha;
import at.ac.tuwien.kr.alpha.api.AnswerSet;
import at.ac.tuwien.kr.alpha.api.impl.AlphaFactory;
import at.ac.tuwien.kr.alpha.api.programs.NormalProgram;
import at.ac.tuwien.kr.alpha.api.programs.Predicate;
import at.ac.tuwien.kr.alpha.commons.Predicates;
import at.ac.tuwien.kr.alpha.commons.programs.Programs;
import at.ac.tuwien.kr.alpha.commons.programs.atoms.Atoms;
import at.ac.tuwien.kr.alpha.commons.programs.terms.Terms;
import org.apache.commons.collections4.ListUtils;
import org.apache.commons.lang3.tuple.ImmutablePair;

import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

public class GraphColoringInstanceGenerator {

	private static final long TIMEOUT_MILLIS = 5 * 60 * 1000; // 5 mins
	private static final int MAX_GENERATION_RETRIES = 1000;
	private static final int INSTANCES_PER_CONFIG = 5;
	private static final Predicate VERTEX = Predicates.getPredicate("vertex", 1);
	private static final Predicate EDGE = Predicates.getPredicate("edge", 2);

	private Alpha alpha = AlphaFactory.newAlpha();
	private final NormalProgram connectednessProgram;
	private final NormalProgram threeColorabilityProgram;

	private GraphColoringInstanceGenerator() throws IOException {
		connectednessProgram = alpha.normalizeProgram(alpha.readProgramStream(GraphColoringInstanceGenerator.class.getResourceAsStream("/connectedness.asp")));
		threeColorabilityProgram = alpha.normalizeProgram(alpha.readProgramStream(GraphColoringInstanceGenerator.class.getResourceAsStream("/3colorability.asp")));
	}

	public static void main(String[] args) throws IOException, ExecutionException, InterruptedException {
		new GraphColoringInstanceGenerator().generateGraphColoringInstances();
	}

	private void generateGraphColoringInstances() throws ExecutionException, InterruptedException {
		String outPath = "out/instances/";
		int[] vertexCounts = {5, 8, 13, 21, 34, 55};
		float[] densityFactors = {0.1f, 0.2f, 0.3f, 0.4f, 0.5f};
		for (int num : vertexCounts) {
			System.out.println("Generating instances for " + num + " vertices");
			for (float density : densityFactors) {
				System.out.println("Density: " + density);
				for (int i = 0; i < INSTANCES_PER_CONFIG; i++) {
					int retryCount = 0;
					boolean[][] graph;
					NormalProgram graphASP;
					boolean isConnected;
					boolean isThreeColorable;
					do {
						graph = generateRandomGraph(num, density);
						graphASP = adjacencyMatrixToASP(graph);
						isConnected = isConnected(graphASP);
						isThreeColorable = isThreeColorable(graphASP);
					} while (!(isConnected && isThreeColorable) && retryCount++ < MAX_GENERATION_RETRIES);
					if (isConnected && isThreeColorable) {
						System.out.println("SUCCESS - Generated graph with " + num + " vertices and density " + density + " that is connected and 3-colorable");
						Graph graphRecord = adjacencyMatrixToGraphRecord(graph);
						writeToXml(graphRecord, Path.of(outPath, "graph_" + num + "_" + density + "-" + i + ".xml"));
						writeToAsp(graphRecord, Path.of(outPath, "graph_" + num + "_" + density + "-" + i + ".asp"));
					} else {
						System.out.println("FAILED - Could not generate graph with " + num + " vertices and density " + density + " that is connected and 3-colorable");
					}
				}
			}
		}
	}

	private boolean[][] generateRandomGraph(int vertexCount, float densityFactor) {
		boolean[][] adjacencyMatrix = new boolean[vertexCount][vertexCount];
		for (int i = 0; i < vertexCount; i++) {
			for(int j = i + 1; j < vertexCount; j++) {
				if(Math.random() < densityFactor) {
					adjacencyMatrix[i][j] = true;
					adjacencyMatrix[j][i] = true;
				}
			}
		}
		return adjacencyMatrix;
	}

	private boolean isConnected(NormalProgram graph) throws ExecutionException, InterruptedException {
		NormalProgram input = Programs.newNormalProgram(ListUtils.union(connectednessProgram.getRules(), graph.getRules()),
				ListUtils.union(connectednessProgram.getFacts(), graph.getFacts()), connectednessProgram.getInlineDirectives(),
				ListUtils.union(connectednessProgram.getModules(), graph.getModules()));
		return hasAnswerSet(input);
	}

	private boolean isThreeColorable(NormalProgram graph) throws ExecutionException, InterruptedException {
		NormalProgram input = Programs.newNormalProgram(ListUtils.union(threeColorabilityProgram.getRules(), graph.getRules()),
				ListUtils.union(threeColorabilityProgram.getFacts(), graph.getFacts()), threeColorabilityProgram.getInlineDirectives(),
				ListUtils.union(threeColorabilityProgram.getModules(), graph.getModules()));
		return hasAnswerSet(input);
	}

	private boolean hasAnswerSet(NormalProgram program) throws ExecutionException, InterruptedException {
		alpha = AlphaFactory.newAlpha(); // re-initialize alpha to avoid weird things...
		Set<AnswerSet> solutions = alpha.solve(program).limit(1).collect(Collectors.toSet());
		return !solutions.isEmpty();
	}

	private NormalProgram adjacencyMatrixToASP(boolean[][] adjacencyMatrix) {
		Programs.InputProgramBuilder asp = Programs.builder();
		for(int i = 0; i < adjacencyMatrix.length; i++) {
			asp.addFact(Atoms.newBasicAtom(VERTEX, Terms.newConstant(Integer.toString(i))));
			for(int j = i + 1; j < adjacencyMatrix.length; j++) {
				if (adjacencyMatrix[i][j]) {
					asp.addFact(Atoms.newBasicAtom(EDGE, Terms.newConstant(Integer.toString(i)), Terms.newConstant(Integer.toString(j))));
					asp.addFact(Atoms.newBasicAtom(EDGE, Terms.newConstant(Integer.toString(j)), Terms.newConstant(Integer.toString(i))));
				}
			}
		}
		return Programs.toNormalProgram(asp.build());
	}

	private Graph adjacencyMatrixToGraphRecord(boolean[][] adjacencyMatrix) {
		Set<String> vertices = new LinkedHashSet<>();
		Set<ImmutablePair<String, String>> edges = new LinkedHashSet<>();
		for(int i = 0; i < adjacencyMatrix.length; i++) {
			vertices.add(Integer.toString(i));
			for(int j = i + 1; j < adjacencyMatrix.length; j++) {
				if (adjacencyMatrix[i][j]) {
					edges.add(new ImmutablePair<>(Integer.toString(i), Integer.toString(j)));
				}
			}
		}
		return new Graph(vertices, edges);
	}

	private void writeToXml(Graph graph, Path path) {
		// Write xml file
		try (PrintStream ps = new PrintStream(Files.newOutputStream(path))) {
			ps.println("<graph directed=\"false\">");
			ps.println("  <vertices>");
			for(String vertex : graph.vertices) {
				ps.println("    <vertex>" + vertex + "</vertex>");
			}
			ps.println("  </vertices>");
			ps.println("  <edges>");
			for(ImmutablePair<String, String> edge : graph.edges) {
				ps.println("    <edge><source>" + edge.getLeft() + "</source><target>" + edge.getRight() + "</target></edge>");
			}
			ps.println("  </edges>");
			ps.println("</graph>");
		} catch (IOException ex) {
			System.err.println("Error writing output file: " + ex.getMessage());
		}
	}

	private void writeToAsp(Graph graph, Path path) {
		// Write asp facts
		try (PrintStream ps = new PrintStream(Files.newOutputStream(path))) {
			for(String vertex : graph.vertices) {
				ps.println("vertex(" + vertex + ").");
			}
			for(ImmutablePair<String, String> edge : graph.edges) {
				ps.println("edge(" + edge.getLeft() + ", " + edge.getRight() + ").");
			}
		} catch (IOException ex) {
			System.err.println("Error writing output file: " + ex.getMessage());
		}
	}

	private record Graph(Set<String> vertices, Set<ImmutablePair<String, String>> edges) {
	}

}
