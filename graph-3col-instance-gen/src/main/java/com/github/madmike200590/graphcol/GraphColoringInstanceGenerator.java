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

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

public class GraphColoringInstanceGenerator {

	private static final long TIMEOUT_MILLIS = 5 * 60 * 1000; // 5 mins
	private static final int MAX_GENERATION_RETRIES = 1000;
	private static final Predicate VERTEX = Predicates.getPredicate("vertex", 1);
	private static final Predicate EDGE = Predicates.getPredicate("edge", 2);

	private final Alpha alpha = AlphaFactory.newAlpha();
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
		int[] vertexCounts = {5, 8, 13, 21, 34, 55};
		float[] densityFactors = {0.1f, 0.2f, 0.3f, 0.4f, 0.5f, 0.6f, 0.8f};
		for (int num : vertexCounts) {
			System.out.println("Generating instances for " + num + " vertices");
			for (float density : densityFactors) {
				System.out.println("Density: " + density);
				boolean[][] graph;
				NormalProgram graphASP;
				int retryCount = 0;
				boolean isConnected;
				boolean isThreeColorable;
				do {
					graph = generateRandomGraph(num, density);
					graphASP = adjancecyMatrixToASP(graph);
					isConnected = isConnectedWithinTimeout(graphASP);
					isThreeColorable = isThreeColorableWithinTimeout(graphASP);
				} while(!(isConnected && isThreeColorable) && retryCount++ < MAX_GENERATION_RETRIES);
				if(isConnected && isThreeColorable) {
					System.out.println("SUCCESS - Generated graph with " + num + " vertices and density " + density + " that is connected and 3-colorable");
				} else {
					System.out.println("FAILED - Could not generate graph with " + num + " vertices and density " + density + " that is connected and 3-colorable");
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

	private boolean isConnectedWithinTimeout(NormalProgram graph) throws ExecutionException, InterruptedException {
		NormalProgram input = Programs.newNormalProgram(ListUtils.union(connectednessProgram.getRules(), graph.getRules()),
				ListUtils.union(connectednessProgram.getFacts(), graph.getFacts()), connectednessProgram.getInlineDirectives(),
				ListUtils.union(connectednessProgram.getModules(), graph.getModules()));
		return hasAnswerSetWithTimeout(input);
	}

	private boolean isThreeColorableWithinTimeout(NormalProgram graph) throws ExecutionException, InterruptedException {
		NormalProgram input = Programs.newNormalProgram(ListUtils.union(threeColorabilityProgram.getRules(), graph.getRules()),
				ListUtils.union(threeColorabilityProgram.getFacts(), graph.getFacts()), threeColorabilityProgram.getInlineDirectives(),
				ListUtils.union(threeColorabilityProgram.getModules(), graph.getModules()));
		return hasAnswerSetWithTimeout(input);
	}

	private boolean hasAnswerSetWithTimeout(NormalProgram program) throws ExecutionException, InterruptedException {
		CompletableFuture<Boolean> f = CompletableFuture.supplyAsync(() -> {
			Set<AnswerSet> solutions = alpha.solve(program).limit(1).collect(Collectors.toSet());
			return !solutions.isEmpty();
		}).completeOnTimeout(false, GraphColoringInstanceGenerator.TIMEOUT_MILLIS, TimeUnit.MILLISECONDS);
		return f.get();
	}

	private NormalProgram adjancecyMatrixToASP(boolean[][] adjacencyMatrix) {
		Programs.InputProgramBuilder asp = Programs.builder();
		for(int i = 0; i < adjacencyMatrix.length; i++) {
			asp.addFact(Atoms.newBasicAtom(VERTEX, Terms.newConstant(i)));
			for(int j = i + 1; j < adjacencyMatrix.length; j++) {
				if (adjacencyMatrix[i][j]) {
					asp.addFact(Atoms.newBasicAtom(EDGE, Terms.newConstant(i), Terms.newConstant(j)));
					asp.addFact(Atoms.newBasicAtom(EDGE, Terms.newConstant(j), Terms.newConstant(i)));
				}
			}
		}
		return Programs.toNormalProgram(asp.build());
	}

}
