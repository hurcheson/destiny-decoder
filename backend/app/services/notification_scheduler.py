"""
Notification Scheduler Service using APScheduler.
Handles scheduled daily/weekly push notifications for events like:
- Blessed days alerts
- Personal year transitions
- Lunar phase changes
- Daily insights
"""
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from datetime import datetime, time
import logging
from typing import Optional, List

logger = logging.getLogger(__name__)


def _check_quiet_hours(preferences: dict) -> bool:
    """
    Check if current time is within quiet hours.
    
    Args:
        preferences: User notification preferences dict
        
    Returns:
        True if currently in quiet hours, False otherwise
    """
    if not preferences.get("quiet_hours_enabled"):
        return False
    
    try:
        from datetime import datetime
        
        start_str = preferences.get("quiet_hours_start")
        end_str = preferences.get("quiet_hours_end")
        
        if not start_str or not end_str:
            return False
        
        # Parse times (HH:MM format)
        start_h, start_m = map(int, start_str.split(":"))
        end_h, end_m = map(int, end_str.split(":"))
        
        now = datetime.now()
        current_time = now.time()
        
        start_time = time(start_h, start_m)
        end_time = time(end_h, end_m)
        
        # Handle case where quiet hours span midnight
        if start_time <= end_time:
            return start_time <= current_time < end_time
        else:
            return current_time >= start_time or current_time < end_time
    except Exception as e:
        logger.error(f"Error checking quiet hours: {str(e)}")
        return False



class NotificationScheduler:
    """
    Manages scheduled push notifications using APScheduler.
    Runs daily/weekly jobs for engagement and astrological events.
    """
    
    def __init__(self):
        """Initialize APScheduler."""
        self.scheduler = AsyncIOScheduler()
        self.is_running = False

    async def start(self):
        """Start the scheduler and register all jobs."""
        if self.is_running:
            logger.warning("Scheduler already running")
            return

        try:
            self.scheduler.start()
            self.is_running = True
            logger.info("✓ Notification scheduler started")
            
            # Register scheduled jobs
            await self._register_daily_jobs()
            
        except Exception as e:
            logger.error(f"Failed to start scheduler: {str(e)}")
            raise

    async def stop(self):
        """Stop the scheduler."""
        if not self.is_running:
            return

        try:
            self.scheduler.shutdown(wait=True)
            self.is_running = False
            logger.info("✓ Notification scheduler stopped")
        except Exception as e:
            logger.error(f"Failed to stop scheduler: {str(e)}")

    async def _register_daily_jobs(self):
        """Register all recurring notification jobs."""
        
        # Daily insights at 6:00 AM
        self.scheduler.add_job(
            self._send_daily_insights,
            CronTrigger(hour=6, minute=0),
            id="daily_insights",
            name="Daily Insights Notification",
            replace_existing=True,
            coalesce=True,
        )
        logger.info("✓ Registered: Daily Insights job (6:00 AM)")

        # Blessed days alert at 8:00 AM
        self.scheduler.add_job(
            self._send_blessed_day_alert,
            CronTrigger(hour=8, minute=0),
            id="blessed_day_alert",
            name="Blessed Day Alert",
            replace_existing=True,
            coalesce=True,
        )
        logger.info("✓ Registered: Blessed Day Alert job (8:00 AM)")

        # Weekly lunar phase update on Sundays at 7:00 PM
        self.scheduler.add_job(
            self._send_lunar_phase_update,
            CronTrigger(day_of_week=6, hour=19, minute=0),
            id="lunar_update",
            name="Lunar Phase Update",
            replace_existing=True,
            coalesce=True,
        )
        logger.info("✓ Registered: Lunar Phase Update job (Sunday 7:00 PM)")

        # Motivational quote every 2 days at 5:00 PM
        self.scheduler.add_job(
            self._send_motivational_quote,
            CronTrigger(day="*/2", hour=17, minute=0),
            id="motivational_quote",
            name="Motivational Quote",
            replace_existing=True,
            coalesce=True,
        )
        logger.info("✓ Registered: Motivational Quote job (every 2 days at 5:00 PM)")

    async def _send_daily_insights(self):
        """Send daily insights to subscribed users."""
        try:
            from app.services.firebase_admin_service import get_firebase_service
            from app.services.daily_insights_service import DailyInsightsService
            from app.api.routes.notifications import _notification_preferences
            
            firebase = get_firebase_service()
            insights_service = DailyInsightsService()
            
            # Check if any users have daily insights enabled
            users_to_notify = [
                device_id for device_id, prefs in _notification_preferences.items()
                if prefs.get("daily_insights", True) and not _check_quiet_hours(prefs)
            ]
            
            if not users_to_notify:
                logger.info("No users subscribed to daily insights or all in quiet hours")
                return
            
            # Get today's insights
            daily_insights = await insights_service.get_daily_insights(
                date=datetime.now().date()
            )
            
            if daily_insights:
                from app.services.firebase_admin_service import FCMNotification
                
                notification = FCMNotification(
                    title="✨ Your Daily Insight",
                    body=daily_insights.get("summary", "Check your daily numerology reading"),
                    data={
                        "type": "daily_insight",
                        "date": datetime.now().isoformat(),
                    }
                )
                
                result = firebase.send_to_topic(
                    topic="daily_insights",
                    notification=notification
                )
                
                logger.info(f"Daily insights sent to {len(users_to_notify)} users: {result}")
        except Exception as e:
            logger.error(f"Error sending daily insights: {str(e)}")

    async def _send_blessed_day_alert(self):
        """Send blessed day alert to subscribed users."""
        try:
            from app.services.firebase_admin_service import get_firebase_service, FCMNotification
            from app.api.routes.notifications import _notification_preferences
            
            firebase = get_firebase_service()
            
            # Check if any users have blessed day alerts enabled
            users_to_notify = [
                device_id for device_id, prefs in _notification_preferences.items()
                if prefs.get("blessed_day_alerts", True) and not _check_quiet_hours(prefs)
            ]
            
            if not users_to_notify:
                logger.info("No users subscribed to blessed day alerts or all in quiet hours")
                return
            
            notification = FCMNotification(
                title="🌟 Blessed Day Alert",
                body="Today is a blessed day for new beginnings and positive changes",
                data={
                    "type": "blessed_day",
                    "date": datetime.now().isoformat(),
                }
            )
            
            result = firebase.send_to_topic(
                topic="blessed_days",
                notification=notification
            )
            
            logger.info(f"Blessed day alert sent to {len(users_to_notify)} users: {result}")
        except Exception as e:
            logger.error(f"Error sending blessed day alert: {str(e)}")

    async def _send_lunar_phase_update(self):
        """Send lunar phase update to subscribed users."""
        try:
            from app.services.firebase_admin_service import get_firebase_service, FCMNotification
            from app.services.daily_insights_service import DailyInsightsService
            from app.api.routes.notifications import _notification_preferences
            
            firebase = get_firebase_service()
            
            # Check if any users have lunar phase alerts enabled
            users_to_notify = [
                device_id for device_id, prefs in _notification_preferences.items()
                if prefs.get("lunar_phase_alerts", False) and not _check_quiet_hours(prefs)
            ]
            
            if not users_to_notify:
                logger.info("No users subscribed to lunar phase alerts or all in quiet hours")
                return
            
            # Get current lunar phase
            insights_service = DailyInsightsService()
            lunar_info = insights_service.get_lunar_phase_info(datetime.now().date())
            
            notification = FCMNotification(
                title="🌙 Lunar Phase Update",
                body=f"This week: {lunar_info.get('phase', 'Check the lunar calendar')}",
                data={
                    "type": "lunar_phase",
                    "phase": lunar_info.get("phase", "unknown"),
                    "date": datetime.now().isoformat(),
                }
            )
            
            result = firebase.send_to_topic(
                topic="lunar_phases",
                notification=notification
            )
            
            logger.info(f"Lunar phase update sent to {len(users_to_notify)} users: {result}")
        except Exception as e:
            logger.error(f"Error sending lunar phase update: {str(e)}")

    async def _send_motivational_quote(self):
        """Send a motivational quote to subscribed users."""
        try:
            from app.services.firebase_admin_service import get_firebase_service, FCMNotification
            from app.api.routes.notifications import _notification_preferences
            
            firebase = get_firebase_service()
            
            # Check if any users have motivational quotes enabled
            users_to_notify = [
                device_id for device_id, prefs in _notification_preferences.items()
                if prefs.get("motivational_quotes", True) and not _check_quiet_hours(prefs)
            ]
            
            if not users_to_notify:
                logger.info("No users subscribed to motivational quotes or all in quiet hours")
                return
            
            quotes = [
                "Your life is a divine journey of discovery and growth.",
                "Numbers reveal the hidden patterns of your destiny.",
                "Every day brings new opportunities for transformation.",
                "Trust the cosmic forces guiding your path.",
                "Your numerology is the key to understanding your purpose.",
                "Embrace the wisdom your numbers hold for you.",
                "Today is a gift—live it with intention and gratitude.",
                "Your journey is unique, your purpose is clear.",
                "Let your numbers guide you to your highest self.",
                "Every challenge is an opportunity for growth.",
            ]
            
            import random
            quote = random.choice(quotes)
            
            notification = FCMNotification(
                title="💫 Daily Inspiration",
                body=quote,
                data={
                    "type": "inspiration",
                    "date": datetime.now().isoformat(),
                }
            )
            
            result = firebase.send_to_topic(
                topic="inspirational",
                notification=notification
            )
            
            logger.info(f"Motivational quote sent to {len(users_to_notify)} users: {result}")
        except Exception as e:
            logger.error(f"Error sending motivational quote: {str(e)}")

    def get_job_status(self) -> dict:
        """Get status of all scheduled jobs."""
        jobs = []
        for job in self.scheduler.get_jobs():
            jobs.append({
                "id": job.id,
                "name": job.name,
                "next_run_time": job.next_run_time.isoformat() if job.next_run_time else None,
                "trigger": str(job.trigger),
            })
        
        return {
            "scheduler_running": self.is_running,
            "total_jobs": len(jobs),
            "jobs": jobs,
        }


# Singleton instance
_scheduler_instance: Optional[NotificationScheduler] = None


def get_notification_scheduler() -> NotificationScheduler:
    """Get or create notification scheduler instance."""
    global _scheduler_instance
    if _scheduler_instance is None:
        _scheduler_instance = NotificationScheduler()
    return _scheduler_instance
