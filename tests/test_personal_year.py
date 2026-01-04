from backend.app.core.personal_year import calculate_personal_year

def test_personal_year():
    # DOB: 9/4
    # Current year: 2024
    # day_r = 9
    # month_r = 4
    # year_r = 2+0+2+4 = 8
    # 9 + 4 + 8 = 21 → 3
    assert calculate_personal_year(9, 4, 2024) == 3
