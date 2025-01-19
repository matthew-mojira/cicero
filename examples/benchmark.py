# this is a python benchmark where we do a lot of simple integer operations

def foo(x, y):
    if x < y:
        return x + 213
    else:
        return y * 9

def bar(z):
    if z < 41:
        return 1
    if z % 4 == 0:
        return 61
    if z > 1e7:
        return 999
    else:
        return 23

def benchmark():
    a = 71
    b = 14
    c = 303

    while a + b < c:
        d = c
        c = c * 17 // 3 
        a = foo(a, b)
        for i in range(min(c, d)):
            b += bar(i) % 7

        print(a, b, c)


if __name__ == "__main__":
    benchmark()
