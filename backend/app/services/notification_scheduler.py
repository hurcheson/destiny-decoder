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
            
            firebase = get_firebase_service()
            insights_service = DailyInsightsService()
            
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
                
                logger.info(f"Daily insights sent: {result}")
        except Exception as e:
            logger.error(f"Error sending daily insights: {str(e)}")

    async def _send_blessed_day_alert(self):
        """Send blessed day alert."""
        try:
            from app.services.firebase_admin_service import get_firebase_service, FCMNotification
            
            firebase = get_firebase_service()
            
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
            
            logger.info(f"Blessed day alert sent: {result}")
        except Exception as e:
            logger.error(f"Error sending blessed day alert: {str(e)}")

    async def _send_lunar_phase_update(self):
        """Send lunar phase update."""
        try:
            from app.services.firebase_admin_service import get_firebase_service, FCMNotification
            
            firebase = get_firebase_service()
            
            # Get current lunar phase
            from app.services.daily_insights_service import DailyInsightsService
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
            
            logger.info(f"Lunar phase update sent: {result}")
        except Exception as e:
            logger.error(f"Error sending lunar phase update: {str(e)}")

    async def _send_motivational_quote(self):
        """Send a motivational quote."""
        try:
            from app.services.firebase_admin_service import get_firebase_service, FCMNotification
            
            firebase = get_firebase_service()
            
            quotes = [
                "Your life is a divine journey of discovery and growth.",
                "Numbers reveal the hidden patterns of your destiny.",
                "Every day brings new opportunities for transformation.",
                "Trust the cosmic forces guiding your path.",
                "Your numerology is the key to understanding your purpose.",
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
            
            logger.info(f"Motivational quote sent: {result}")
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
