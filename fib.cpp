fib(n, numCalls)
{
    numCalls++;

    if (n == 0)
        return 0;
    if (n == 1)
        return 1;

    return fib(n - 1, numCalls) + fib(n - 2, numCalls);
}