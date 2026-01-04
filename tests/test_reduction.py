from backend.app.core.reduction import reduce_to_single_digit

def test_reduce_single_digit():
    assert reduce_to_single_digit(5) == 5

def test_reduce_double_digits():
    assert reduce_to_single_digit(19) == 1  # 1 + 9 = 10 → 1

def test_reduce_large_number():
    assert reduce_to_single_digit(1998) == 9  # 1+9+9+8 = 27 → 2+7 = 9
