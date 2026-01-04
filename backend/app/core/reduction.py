def reduce_to_single_digit(n: int) -> int:
    while n > 9:
        n = sum(int(digit) for digit in str(n))
    return n
