def evaluate_compatibility(number_1: int, number_2: int) -> str:
    difference = abs(number_1 - number_2)
    if difference == 0:
        return "Very Strong"
    elif difference <= 2:
        return "Compatible"
    else:
        return "Challenging"
