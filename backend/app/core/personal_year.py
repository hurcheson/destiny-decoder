from .reduction import reduce_to_single_digit

def calculate_personal_year(day: int, month: int, current_year: int) -> int:
    day_r = reduce_to_single_digit(day)
    month_r = reduce_to_single_digit(month)
    current_year_r = reduce_to_single_digit(current_year)
    
    personal_year_raw = day_r + month_r + current_year_r
    personal_year = reduce_to_single_digit(personal_year_raw)
    
    return personal_year
