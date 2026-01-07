def reduce_to_single_digit(n: int) -> int:
    while n > 9:
        n = sum(int(digit) for digit in str(n))
    return n

def excel_reduce(n: int) -> int:
    """Excel-faithful reduction: if n == 0 → 0, else → ((n - 1) % 9) + 1"""
    if n == 0:
        return 0
    return ((n - 1) % 9) + 1
