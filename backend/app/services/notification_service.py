"""
Push notification service for blessed days and personal year milestones.
"""
from datetime import datetime, timedelta
from typing import Optional
from pydantic import BaseModel


class NotificationPayload(BaseModel):
    """Push notification payload."""
    title: str
    body: str
    data: dict = {}


class BlessedDayNotification:
    """Check for blessed days and generate notifications."""

    def __init__(self, day_of_birth: int):
        self.day_of_birth = day_of_birth

    def is_blessed_day_today(self) -> bool:
        """Check if today is a blessed day."""
        today = datetime.now()
        return today.day == self.day_of_birth

    def next_blessed_day(self) -> datetime:
        """Calculate next blessed day."""
        today = datetime.now()
        next_date = today.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        next_date = next_date.replace(day=self.day_of_birth)

        # If blessed day has already passed this month, move to next month
        if next_date <= today:
            if next_date.month == 12:
                next_date = next_date.replace(year=next_date.year + 1, month=1)
            else:
                next_date = next_date.replace(month=next_date.month + 1)

        return next_date

    def get_blessed_day_notification(self) -> Optional[NotificationPayload]:
        """Generate blessed day notification if today is blessed."""
        if self.is_blessed_day_today():
            return NotificationPayload(
                title="✨ Today is Your Blessed Day!",
                body=f"Harness the divine energy of day {self.day_of_birth}. This is an auspicious day for important decisions.",
                data={"type": "blessed_day", "day": self.day_of_birth},
            )
        return None


class PersonalYearNotification:
    """Check for personal year milestones."""

    def __init__(self, day_of_birth: int, month_of_birth: int, year_of_birth: int):
        self.day_of_birth = day_of_birth
        self.month_of_birth = month_of_birth
        self.year_of_birth = year_of_birth

    def _reduce_to_single_digit(self, num: int) -> int:
        """Reduce number to single digit (1–9)."""
        while num >= 10:
            num = sum(int(d) for d in str(num))
        return num

    def calculate_personal_year(self, year: int) -> int:
        """Calculate personal year for a given calendar year."""
        return self._reduce_to_single_digit(
            self.day_of_birth + self.month_of_birth + year
        )

    def personal_year_birthday(self) -> datetime:
        """Get the birthday (personal year birthday) for this year."""
        today = datetime.now()
        birthday = datetime(
            today.year, self.month_of_birth, self.day_of_birth
        )
        if birthday < today:
            birthday = birthday.replace(year=today.year + 1)
        return birthday

    def get_personal_year_notification(self) -> Optional[NotificationPayload]:
        """Check if personal year birthday is today/upcoming and generate notification."""
        today = datetime.now()
        birthday = datetime(today.year, self.month_of_birth, self.day_of_birth)

        # Check if birthday is today
        if today.date() == birthday.date():
            new_personal_year = self.calculate_personal_year(today.year)
            current_personal_year = self.calculate_personal_year(today.year - 1)
            return NotificationPayload(
                title=f"🎂 Personal Year {new_personal_year} Begins!",
                body=f"Happy numerological birthday! You're entering a year of {new_personal_year} energy—renewal, growth, and new beginnings.",
                data={
                    "type": "personal_year_milestone",
                    "old_year": current_personal_year,
                    "new_year": new_personal_year,
                },
            )
        return None


class NotificationScheduler:
    """Manages scheduled notification checks."""

    @staticmethod
    def should_notify_blessed_day(user_id: str) -> bool:
        """Check if blessed day notification should be sent (once per day)."""
        # In production, check a database for the last sent time
        # For now, assume we should check if notification hasn't been sent today
        return True

    @staticmethod
    def should_notify_personal_year(user_id: str) -> bool:
        """Check if personal year notification should be sent (once per year)."""
        # Check database for the last sent time
        return True
