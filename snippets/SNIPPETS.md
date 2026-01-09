# Competitive Programming Snippets for Neovim

**Total: 74 snippets**

Source: [ncduy0303/Competitive-Programming](https://github.com/ncduy0303/Competitive-Programming)


## Contest Template

| Trigger | Description |
|---------|-------------|
| `brute` | brute |
| `gen` | gen |
| `main` | main |

## Data Structures

| Trigger | Description |
|---------|-------------|
| `dsu` | Disjoint Set Union |
| `hld` | Heavy-light decomposition (HLD) is a data structure to answer queries and update values on tree |
| `pbds` | Policy based data structures C++ STL |
| `sparse` | Answer range query for static array |
| `sqrt` | Mo's Algorithm for answering offline queries |
| `suffix` | Suffix Array: storing all suffixes of a string, useful for many string-related problems |
| `treap` | Treap data structure supporting split and merge function |
| `tree_query` | Query on tree using eulerian ordering and fenwick tree |
| `trie` | Prefix tree: storing strings based on their common prefix |

## Dynamic Programming

| Trigger | Description |
|---------|-------------|
| `1d_max_sum_kanade` | Given an array of integers, find the maximum sum subarray |
| `2d_max_sum` | Given a 2D array of integers, find the maximum sum 2D subarray |
| `coin_change` | Given n different values of coins |
| `cutting_sticks` | Given a length x and n cutting points, find the minimum cost perform all n cuts |
| `d_c_trick` | Use Divide & Conquer (D&C) to optimize a DP solution |
| `deque_trick` | Optimise from O(NK^2) to O(NK) by answering min/max queries among k consecutive elements in O(1) in  |
| `digit_dp` | Find the sum of the digits of the numbers between a and b (0 <= a <= b <= 1e9) |
| `elevator_rides` | Find the minimum of elevator rides to move n people knowing everyone's weight and the elevator's lim |
| `knapsack_0-1` | Given a list of items with their weights and values |
| `lcs_lcs` | Given 2 strings x and y of length n and m, find the the longest common subsequence (LCS) |
| `lis_lis` | Find the longest increasing subsequence (LIS) in the array of length n |
| `matrix_chain` | Similar to "Cutting Sticks", a variation of Matrix Chain Multiplication DP Problem |
| `segtree_dp1` | Use Convex Hull Trick (CHT) to optimize a DP solution |
| `sos_dp` | Sum-over-subset dp to optimise from O(4^n) or O(3^n) to O(n*2^n) |
| `tsp_tsp` | Given n cities/nodes, find a minimum weight Hamiltonian Cycle/Tour |
| `wjs` | Given a list of jobs with start time, end time, and profit, find the maximum profit |

## Fenwick Tree

| Trigger | Description |
|---------|-------------|
| `fenwick` | Problem link: https://cses.fi/problemset/task/1739 |
| `fenwick_orde` | Create something similar to PBDS using Fenwick Tree |
| `fenwick_poin` | Problem link: https://cses.fi/problemset/task/1648 |
| `fenwick_rang` | Problem link: https://cses.fi/problemset/task/1651 |
| `fenwick_rang_ft1` | Use 2 fenwick trees to support both range updates and range queries (RURQ) |

## Geometry

| Trigger | Description |
|---------|-------------|
| `basic` | Basic geometry template for 2D Point (modified from kactl) |

## Graph Traversal

| Trigger | Description |
|---------|-------------|
| `bfs` | Graph Traversal: BFS |
| `bipartite` | Problem link: https://cses.fi/problemset/task/1668 |
| `dfs` | Graph Traversal: DFS |
| `flood_fill` | Problem link: https://cses.fi/problemset/task/1192 |

## Lowest Common Ancestor

| Trigger | Description |
|---------|-------------|
| `binlift_bina` | Time complexity: O(nlogn) build, O(logn) per query |
| `lca_rmq` | Convert the Lowest Common Ancestor (LCA) problem into the Range Minimum Query (RMQ) Problem |

## Mathematics

| Trigger | Description |
|---------|-------------|
| `binomial_coefficients` | Quick calculation of nCk |
| `fibonacci` | Find the n-th Fibonacci number using matrix multiplication and binary exponentiation |
| `gcd` | Find the greatest common divisor (GCD) of two integers |
| `quick_exponention` | Quick calculation of (a^b) mod m |
| `sieve` | Generate the all primes <= n |

## Max Flow

| Trigger | Description |
|---------|-------------|
| `maxflow` | Maximum Flow (Dinic Algorithm) |
| `maxflow_mf1` | Maximum Flow (Dinic Algorithm) |

## Minimum Spanning Tree

| Trigger | Description |
|---------|-------------|
| `kruskal` | Need to use edge list for Kruskal |
| `prim` | Prim Agorithm is similar to Dijkstra |

## Others

| Trigger | Description |
|---------|-------------|
| `2sat` | 2-SAT Problem |
| `c3p_divide` | Problem link: https://www.codechef.com/LRNDSA04/problems/ACM14KP1 |
| `median_heap` | Given a stream of n input integers, maintain the median of the current array |
| `mha_monoto` | Find the largest rectangular area in a histogram |
| `mitm` | Given an array of n numbers (n <= 40), count the number of subsets with sum x (x <= 10^9) |
| `n_queens` | Count the number of ways to place the queens so that no two queens are attacking each other |
| `odc` | Use DSU (with rollback) to solve offline dynamic connectivity problems |

## Segment Tree

| Trigger | Description |
|---------|-------------|
| `segtree` | Segment tree beats for chmax, chmin and add range updates |
| `segtree_lazy` | Segment tree with lazy propagation for range sum query, range add update, range set update |
| `segtree_pers` | Persistent segment tree for range sum query, point set update |
| `segtree_recu` | Segment tree for range minimum query, point set update |

## Shortest Paths

| Trigger | Description |
|---------|-------------|
| `0_1_bfs` | 0-1 BFS for SSSP |
| `bellman` | Time complexity: O(nm) |
| `dijkstra` | Time complexity: O(n + mlogn) |
| `floyd_warshall` | Find all pair shortest paths |

## String Processing

| Trigger | Description |
|---------|-------------|
| `kmp_pref` | Given a string s (with length n) and a pattern p (with length m), find all occurrence of p in s |
| `rabinkarp_rabi` | String Hashing |
| `zalgo_z_fu` | Given a string s (with length n) and a pattern p (with length m), find all the occurrence of p in s |

## Strongly Connected Components (SSCs)

| Trigger | Description |
|---------|-------------|
| `scc` | Given an undirected graph, find all bridges and articulation points |
| `scc_sc1` | Kosaraju's algorithm to find strongly connected components (SCCs) by running DFS twice |
| `scc_sc2` | Tarjan's algorithm to find strongly connected components (SCCs) |

## Sweep Line

| Trigger | Description |
|---------|-------------|
| `closest_pairs` | Given n points (x, y) on a plane, find the minimum distance between a pair of points |
| `rectangle_union` | Given n rectangles on a plane (they are all parallel to the axis), find the union area of all the re |

## Topological Sort

| Trigger | Description |
|---------|-------------|
| `toposort_dfs` | Traversal path of a typical DFS is a reverse topological order |
| `toposort_in_d` | Greedily take all nodes with in_deg == 0 and push them into the topological ordering, then decrease  |

## Quick Reference (Alphabetical)

| Trigger | Category | Description |
|---------|----------|-------------|
| `0_1_bfs` | Shortest Paths | 0-1 BFS for SSSP |
| `1d_max_sum_kanade` | Dynamic Programming | Given an array of integers, find the maximum sum subarray |
| `2d_max_sum` | Dynamic Programming | Given a 2D array of integers, find the maximum sum 2D subarray |
| `2sat` | Others | 2-SAT Problem |
| `basic` | Geometry | Basic geometry template for 2D Point (modified from kactl) |
| `bellman` | Shortest Paths | Time complexity: O(nm) |
| `bfs` | Graph Traversal | Graph Traversal: BFS |
| `binlift_bina` | Lowest Common Ancestor | Time complexity: O(nlogn) build, O(logn) per query |
| `binomial_coefficients` | Mathematics | Quick calculation of nCk |
| `bipartite` | Graph Traversal | Problem link: https://cses.fi/problemset/task/1668 |
| `brute` | Contest Template | brute |
| `c3p_divide` | Others | Problem link: https://www.codechef.com/LRNDSA04/problems/ACM14KP1 |
| `closest_pairs` | Sweep Line | Given n points (x, y) on a plane, find the minimum distance between a pair of points |
| `coin_change` | Dynamic Programming | Given n different values of coins |
| `cutting_sticks` | Dynamic Programming | Given a length x and n cutting points, find the minimum cost perform all n cuts |
| `d_c_trick` | Dynamic Programming | Use Divide & Conquer (D&C) to optimize a DP solution |
| `deque_trick` | Dynamic Programming | Optimise from O(NK^2) to O(NK) by answering min/max queries among k consecutive elements in O(1) in  |
| `dfs` | Graph Traversal | Graph Traversal: DFS |
| `digit_dp` | Dynamic Programming | Find the sum of the digits of the numbers between a and b (0 <= a <= b <= 1e9) |
| `dijkstra` | Shortest Paths | Time complexity: O(n + mlogn) |
| `dsu` | Data Structures | Disjoint Set Union |
| `elevator_rides` | Dynamic Programming | Find the minimum of elevator rides to move n people knowing everyone's weight and the elevator's lim |
| `fenwick` | Fenwick Tree | Problem link: https://cses.fi/problemset/task/1739 |
| `fenwick_orde` | Fenwick Tree | Create something similar to PBDS using Fenwick Tree |
| `fenwick_poin` | Fenwick Tree | Problem link: https://cses.fi/problemset/task/1648 |
| `fenwick_rang` | Fenwick Tree | Problem link: https://cses.fi/problemset/task/1651 |
| `fenwick_rang_ft1` | Fenwick Tree | Use 2 fenwick trees to support both range updates and range queries (RURQ) |
| `fibonacci` | Mathematics | Find the n-th Fibonacci number using matrix multiplication and binary exponentiation |
| `flood_fill` | Graph Traversal | Problem link: https://cses.fi/problemset/task/1192 |
| `floyd_warshall` | Shortest Paths | Find all pair shortest paths |
| `gcd` | Mathematics | Find the greatest common divisor (GCD) of two integers |
| `gen` | Contest Template | gen |
| `hld` | Data Structures | Heavy-light decomposition (HLD) is a data structure to answer queries and update values on tree |
| `kmp_pref` | String Processing | Given a string s (with length n) and a pattern p (with length m), find all occurrence of p in s |
| `knapsack_0-1` | Dynamic Programming | Given a list of items with their weights and values |
| `kruskal` | Minimum Spanning Tree | Need to use edge list for Kruskal |
| `lca_rmq` | Lowest Common Ancestor | Convert the Lowest Common Ancestor (LCA) problem into the Range Minimum Query (RMQ) Problem |
| `lcs_lcs` | Dynamic Programming | Given 2 strings x and y of length n and m, find the the longest common subsequence (LCS) |
| `lis_lis` | Dynamic Programming | Find the longest increasing subsequence (LIS) in the array of length n |
| `main` | Contest Template | main |
| `matrix_chain` | Dynamic Programming | Similar to "Cutting Sticks", a variation of Matrix Chain Multiplication DP Problem |
| `maxflow` | Max Flow | Maximum Flow (Dinic Algorithm) |
| `maxflow_mf1` | Max Flow | Maximum Flow (Dinic Algorithm) |
| `median_heap` | Others | Given a stream of n input integers, maintain the median of the current array |
| `mha_monoto` | Others | Find the largest rectangular area in a histogram |
| `mitm` | Others | Given an array of n numbers (n <= 40), count the number of subsets with sum x (x <= 10^9) |
| `n_queens` | Others | Count the number of ways to place the queens so that no two queens are attacking each other |
| `odc` | Others | Use DSU (with rollback) to solve offline dynamic connectivity problems |
| `pbds` | Data Structures | Policy based data structures C++ STL |
| `prim` | Minimum Spanning Tree | Prim Agorithm is similar to Dijkstra |
| `quick_exponention` | Mathematics | Quick calculation of (a^b) mod m |
| `rabinkarp_rabi` | String Processing | String Hashing |
| `rectangle_union` | Sweep Line | Given n rectangles on a plane (they are all parallel to the axis), find the union area of all the re |
| `scc` | Strongly Connected Components (SSCs) | Given an undirected graph, find all bridges and articulation points |
| `scc_sc1` | Strongly Connected Components (SSCs) | Kosaraju's algorithm to find strongly connected components (SCCs) by running DFS twice |
| `scc_sc2` | Strongly Connected Components (SSCs) | Tarjan's algorithm to find strongly connected components (SCCs) |
| `segtree` | Segment Tree | Segment tree beats for chmax, chmin and add range updates |
| `segtree_dp1` | Dynamic Programming | Use Convex Hull Trick (CHT) to optimize a DP solution |
| `segtree_lazy` | Segment Tree | Segment tree with lazy propagation for range sum query, range add update, range set update |
| `segtree_pers` | Segment Tree | Persistent segment tree for range sum query, point set update |
| `segtree_recu` | Segment Tree | Segment tree for range minimum query, point set update |
| `sieve` | Mathematics | Generate the all primes <= n |
| `sos_dp` | Dynamic Programming | Sum-over-subset dp to optimise from O(4^n) or O(3^n) to O(n*2^n) |
| `sparse` | Data Structures | Answer range query for static array |
| `sqrt` | Data Structures | Mo's Algorithm for answering offline queries |
| `suffix` | Data Structures | Suffix Array: storing all suffixes of a string, useful for many string-related problems |
| `toposort_dfs` | Topological Sort | Traversal path of a typical DFS is a reverse topological order |
| `toposort_in_d` | Topological Sort | Greedily take all nodes with in_deg == 0 and push them into the topological ordering, then decrease  |
| `treap` | Data Structures | Treap data structure supporting split and merge function |
| `tree_query` | Data Structures | Query on tree using eulerian ordering and fenwick tree |
| `trie` | Data Structures | Prefix tree: storing strings based on their common prefix |
| `tsp_tsp` | Dynamic Programming | Given n cities/nodes, find a minimum weight Hamiltonian Cycle/Tour |
| `wjs` | Dynamic Programming | Given a list of jobs with start time, end time, and profit, find the maximum profit |
| `zalgo_z_fu` | String Processing | Given a string s (with length n) and a pattern p (with length m), find all the occurrence of p in s |
