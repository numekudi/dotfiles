x = int(input())


def f(x: int):
    return x**2 + 2 * x + 3


print(f(f(f(x) + x) + f(f(x))))
