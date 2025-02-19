package com.github.madmike200590.graphcol;

public class GraphColoringInstanceGenerator {

	private static final long TIMEOUT_MILLIS = 5 * 60 * 1000; // 5 mins

	// TODO parsed ASP programs for connectedness and 3-colorability

	public static void main(String[] args) {
		int[] vertexCounts = {5, 8, 13, 21, 34, 55};
		float[] densityFactors = {0.1f, 0.3f, 0.5f, 0.7f, 0.9f};
		for (int num : vertexCounts) {
			for (float density : densityFactors) {
				boolean[][] graph;
				do {
					graph = generateRandomGraph(num, density);
				} while(!(isConnected(graph) && isThreeColorableWithinTimeout(graph, TIMEOUT_MILLIS)));

			}
		}
	}

	private static boolean[][] generateRandomGraph(int vertexCount, float densityFactor) {
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

	private static boolean isConnected(boolean[][] adjacencyMatrix) {
		// TODO
//		boolean[] visited = new boolean[adjacencyMatrix.length];
//		visit(0, adjacencyMatrix, visited);
//		for (boolean b : visited) {
//			if (!b) {
//				return false;
//			}
//		}
		return true;
	}

	private static boolean isThreeColorableWithinTimeout(boolean[][] adjacencyMatrix, long timeoutMillis) {
		// TODO
		return true;
	}

}
