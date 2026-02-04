"""
Receipt validation service for Apple App Store and Google Play Store.
"""
import base64
import json
import requests
from typing import Dict, Optional
from datetime import datetime, timedelta
from app.utils.logger import logger


class ReceiptValidationService:
    """Service for validating purchase receipts from Apple and Google."""
    
    # Apple Sandbox and Production URLs
    APPLE_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    APPLE_PRODUCTION_URL = "https://buy.itunes.apple.com/verifyReceipt"
    
    # Google Play Developer API
    GOOGLE_PLAY_URL = "https://androidpublisher.googleapis.com/androidpublisher/v3"
    
    @staticmethod
    def validate_apple_receipt(receipt_data: str, shared_secret: Optional[str] = None) -> Dict:
        """
        Validate Apple App Store receipt.
        
        Args:
            receipt_data: Base64 encoded receipt
            shared_secret: Optional shared secret for subscription auto-renew
            
        Returns:
            Dict with validation result
        """
        payload = {"receipt-data": receipt_data}
        if shared_secret:
            payload["password"] = shared_secret
        
        # Try production first
        response = requests.post(
            ReceiptValidationService.APPLE_PRODUCTION_URL,
            json=payload,
            timeout=10
        )
        
        result = response.json()
        
        # If status is 21007 (sandbox receipt sent to production), retry with sandbox
        if result.get("status") == 21007:
            logger.info("Receipt is sandbox, retrying with sandbox URL")
            response = requests.post(
                ReceiptValidationService.APPLE_SANDBOX_URL,
                json=payload,
                timeout=10
            )
            result = response.json()
        
        if result.get("status") == 0:
            # Success
            latest_receipt_info = result.get("latest_receipt_info", [])
            if latest_receipt_info:
                latest = latest_receipt_info[-1]
                
                # Parse expiration date
                expires_ms = int(latest.get("expires_date_ms", 0))
                expires_date = datetime.fromtimestamp(expires_ms / 1000) if expires_ms else None
                
                return {
                    "valid": True,
                    "platform": "ios",
                    "transaction_id": latest.get("transaction_id"),
                    "original_transaction_id": latest.get("original_transaction_id"),
                    "product_id": latest.get("product_id"),
                    "purchase_date": datetime.fromtimestamp(int(latest.get("purchase_date_ms", 0)) / 1000),
                    "expires_date": expires_date,
                    "is_trial": latest.get("is_trial_period") == "true",
                    "is_active": expires_date > datetime.utcnow() if expires_date else False,
                    "raw_response": result
                }
        
        # Validation failed
        logger.warning(f"Apple receipt validation failed: status={result.get('status')}")
        return {
            "valid": False,
            "error": f"Apple validation failed with status {result.get('status')}",
            "raw_response": result
        }
    
    @staticmethod
    def validate_google_receipt(
        receipt_data: str,
        product_id: str,
        package_name: str = "com.destinydecoder.app"
    ) -> Dict:
        """
        Validate Google Play Store receipt.
        
        Note: This requires Google Play Developer API credentials.
        For production, you'll need:
        1. Enable Google Play Developer API
        2. Create service account
        3. Generate credentials JSON
        4. Grant service account access to your app
        
        Args:
            receipt_data: Purchase token from Google Play
            product_id: Product ID (SKU)
            package_name: Android package name
            
        Returns:
            Dict with validation result
        """
        # Parse receipt data (should be JSON with purchaseToken)
        try:
            receipt_json = json.loads(receipt_data)
            purchase_token = receipt_json.get("purchaseToken")
            
            if not purchase_token:
                return {"valid": False, "error": "Missing purchaseToken"}
            
            # TODO: Implement Google Play API call
            # This requires:
            # - Service account credentials
            # - OAuth 2.0 token
            # - Google Play Developer API enabled
            
            # For now, return a mock validation for development
            logger.warning("Google Play validation not yet implemented - using mock")
            
            # Mock validation for development
            return {
                "valid": True,
                "platform": "android",
                "transaction_id": receipt_json.get("orderId", "mock_order_id"),
                "original_transaction_id": receipt_json.get("orderId", "mock_order_id"),
                "product_id": product_id,
                "purchase_date": datetime.utcnow(),
                "expires_date": datetime.utcnow() + timedelta(days=30),
                "is_trial": False,
                "is_active": True,
                "raw_response": receipt_json
            }
            
        except json.JSONDecodeError:
            return {"valid": False, "error": "Invalid receipt format"}
    
    @staticmethod
    def validate_receipt(platform: str, receipt_data: str, product_id: str) -> Dict:
        """
        Validate receipt for any platform.
        
        Args:
            platform: 'ios' or 'android'
            receipt_data: Receipt data from platform
            product_id: Product ID being purchased
            
        Returns:
            Dict with validation result
        """
        if platform == "ios":
            return ReceiptValidationService.validate_apple_receipt(receipt_data)
        elif platform == "android":
            return ReceiptValidationService.validate_google_receipt(receipt_data, product_id)
        else:
            return {"valid": False, "error": f"Unsupported platform: {platform}"}
