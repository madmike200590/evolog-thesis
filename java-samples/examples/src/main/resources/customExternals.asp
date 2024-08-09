%% Find even fibonacci numbers up to F(40).
fib(N, FN) :- &fibonacci_number[N](FN), N = 0..40.
even_fib(N, FN) :- fib(N, FN), FN \ 2 = 0.