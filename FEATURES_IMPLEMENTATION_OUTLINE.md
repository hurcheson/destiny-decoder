# Destiny Decoder - Features & Implementation Roadmap

## 📊 Current Implementation Status (January 17, 2026)

### ✅ COMPLETED FEATURES

#### Core Numerology Engine
- Life Seal calculation (birth date → number + planet)
- Soul Number, Personality Number, Physical Name Number (name-based)
- Personal Year calculation (current year influence)
- Life Cycles (3 phases: 0-30, 30-55, 55+)
- Turning Points (4 transitions: ages 36, 45, 54, 63)
- Pinnacles calculation (4 achievement periods) - NEWLY FIXED
- Blessed Years & Days (10-year outlook + monthly blessed days)
- Compatibility analysis (2-person numerological comparison)

#### Backend API
- POST `/calculate-destiny` - Core numbers only
- POST `/decode/full` - Full reading with interpretations
- POST `/decode/compatibility` - Compatibility between 2 people
- POST `/export/pdf` - PDF generation (1-6 pages)
- Daily insights endpoints (power numbers, blessed days, personal month)
- Notification endpoints (FCM token management, preferences)

#### Frontend Features
- Destiny reading form (collect name + birth date)
- Result page (display all numbers + interpretations)
- Timeline visualization (Life Cycles + Turning Points)
- Compatibility page (2-person analysis + score)
- PDF export with file picker (Android/iOS/Desktop)
- Reading history (save/load unlimited readings)
- Onboarding flow (5 screens with welcome screens)
- Dark mode support
- Animated number reveals
- Pull-to-refresh gestures
- Settings page (basic structure)
- Daily insights view (power numbers, blessed days)

#### Backend Quality (JUST FIXED)
- Fixed typos in all cycle interpretations
- Proper comma spacing throughout
- Pinnacles calculation implemented
- Dict content handling for interpretations
- Complete data quality improvements

---

## 🎯 PLANNED FEATURES (Phase 6 & 7 - Not Yet Implemented)

### PHASE 6: Growth & Engagement Features (Roadmap: 3-4 weeks)

#### 6.1 Enhanced Daily Insights System
**Status**: PARTIAL (endpoints exist, mobile UI minimal)

**Backend** (Semi-implemented):
- ✅ GET `/daily/insight` - Daily power number calculation
- ✅ GET `/daily/weekly` - 7-day power forecast
- ✅ GET `/daily/blessed-days` - Monthly blessed days
- ✅ GET `/monthly/guidance` - Personal month themes
- ❌ Push notification scheduler (TODO)
- ❌ Database storage for user insights preferences

**Frontend** (In Progress):
- ✅ Daily insights view with current power number
- ❌ Calendar view showing all blessed days (UI only)
- ❌ Weekly forecast visualization
- ❌ Personal month guidance detail page
- ❌ Notification settings integration

**What's Missing**:
- Mobile UI refinement & animations
- Backend persistence (user preferences storage)
- Push notification delivery (Firebase setup incomplete)
- Analytics tracking for engagement

---

#### 6.2 Enhanced Onboarding Education
**Status**: NOT STARTED

**Required Implementation**:
- Add "What is this?" expandable cards in onboarding
- Create example reading preview (show sample calculation)
- Add interactive tutorial overlay on first result view
- Educational tooltips on each section
- "Learn More" links to interpretation details

**Files to Create**:
```
lib/features/onboarding/tutorial_overlay.dart
lib/features/tutorial/tutorial_service.dart
lib/features/decode/presentation/widgets/info_tooltip.dart
assets/content/onboarding_educations.json
```

**Effort**: Medium (UI + state management)

---

#### 6.3 In-App Content Hub (Numerology Education)
**Status**: NOT STARTED

**Required Implementation**:
1. **Content Database**
   - 10-15 articles (1000-1500 words each)
   - Categories: Basics, Life Seals 1-9, Life Cycles, Compatibility
   - Store as JSON in assets or backend API

2. **Backend Changes**:
   ```python
   GET /content/articles - List all articles
   GET /content/articles/{id} - Get single article
   POST /content/articles/{id}/read - Track reads
   ```

3. **Frontend Changes**:
   ```
   lib/features/content/
   ├── content_hub_page.dart - List view
   ├── article_reader_page.dart - Reading experience
   ├── article_model.dart
   └── article_service.dart
   ```

4. **Content Topics**:
   - What is Numerology?
   - Understanding Life Seals (1-9 guides)
   - Life Cycles & Life Phases
   - Turning Points & Transitions
   - Compatibility Deep Dive
   - Personal Year Themes
   - Daily Power Numbers
   - Pinnacles & Achievement Periods

**Effort**: High (content creation + UI + backend)

---

#### 6.4 Analytics & Instrumentation
**Status**: PARTIALLY STARTED

**Backend** (Needed):
- ❌ Analytics table in database (track events)
- ❌ API endpoints for logging events
- ❌ Aggregation queries for dashboards

**Frontend** (Needed):
- ❌ Firebase Analytics SDK integration
- ❌ Event tracking service

**Key Events to Track**:
- app_open
- calculation_completed (with Life Seal number)
- pdf_exported
- reading_saved
- compatibility_checked
- article_read (which article)
- onboarding_completed
- onboarding_skipped (at which step)
- notification_opened

**User Properties to Track**:
- has_calculated (boolean)
- life_seal_number (1-9)
- total_readings (count)
- days_since_install
- notification_opt_in (boolean)

**Effort**: Medium (Firebase setup + tracking calls throughout codebase)

---

#### 6.5 Improved Interpretation Content
**Status**: PARTIALLY DONE

**Completed**:
- ✅ Fixed typos & spacing in cycle interpretations
- ✅ Added pinnacle interpretations with detail

**Still Needed**:
- ❌ Rewrite interpretations to be more conversational
- ❌ Add specific action items (not just descriptions)
- ❌ Gender-specific variations (career/relationship examples)
- ❌ Goal-based filtering (career vs. relationships vs. spirituality)
- ❌ Interpretation style options (Mystical / Practical / Scientific)

**Backend Changes**:
```python
# Add to DestinyRequest schema
{
  "gender": "male|female|other",
  "focus_area": "career|relationships|spirituality|health|general",
  "interpretation_style": "mystical|practical|scientific"
}

# Extend interpretation functions to use these parameters
```

**Effort**: High (content + backend logic)

---

#### 6.6 Social Sharing & Viral Features
**Status**: NOT STARTED

**Required Implementation**:

1. **"Guess My Number" Game**
   - Generate shareable card: "I'm a Life Seal 7! Guess yours?"
   - Deep link opens app with pre-filled form
   - File: `lib/features/social/guess_number.dart`

2. **Couples' Destiny Report**
   - Beautiful side-by-side comparison card
   - Compatibility emoji score
   - Shareable to Instagram/Facebook Stories
   - File: `lib/features/compatibility/couples_report.dart`

3. **Invite Friends Feature**
   - Generate referral link (unique code)
   - "Compare numerology with friends!"
   - Track which referrals convert
   - File: `lib/features/referral/invite_friends.dart`

4. **Beautiful Share Cards**
   - Template for each Life Seal (with planet imagery)
   - Quote + insight of the day
   - Customizable backgrounds
   - File: `lib/features/social/share_card_generator.dart`

**Backend Changes**:
```python
POST /referral/generate-link - Create unique referral code
GET /referral/track/{code} - Track referral conversions
GET /share/template/{life_seal} - Get share template
```

**Success Metrics Target**:
- 15% share rate
- 5% referral conversion
- Viral coefficient > 0.3

**Effort**: High (UI + backend tracking + sharing APIs)

---

#### 6.7 Push Notifications
**Status**: PARTIAL (infrastructure exists, not fully implemented)

**Backend** (Skeleton exists):
- ✅ Token registration endpoints
- ✅ Preference storage (models defined)
- ❌ Notification scheduler (job scheduler needed)
- ❌ Firebase Cloud Messaging integration
- ❌ Database persistence for tokens

**Frontend** (Skeleton exists):
- ❌ Firebase Cloud Messaging SDK setup
- ❌ Token registration on app launch
- ❌ Notification permission request
- ❌ Notification preferences UI (created)
- ❌ Notification handlers (background/foreground)

**Notification Types to Implement**:
1. Daily Insight (8 AM): "Your Power Number today is 5 - Find harmony and balance"
2. Blessed Day Alert (7 AM): "Today is your blessed day! 🌙 A perfect time for new projects"
3. Weekly Reflection (Sunday 6 PM): "Reflect on your week - What themes emerged?"
4. Monthly Update (1st of month): "Your Personal Month is 3 - Express yourself creatively"
5. Reading Anniversary (30 days): "One month since your reading! Review your insights"

**What's Needed**:
- Job scheduler (APScheduler for Python)
- Firebase Cloud Messaging setup (iOS + Android)
- Notification service implementation
- User timezone support

**Effort**: High (Firebase + job scheduling + timezone handling)

---

### PHASE 7: Monetization (Roadmap: 3-4 weeks)

#### 7.1 Freemium Model Architecture
**Status**: NOT STARTED

**Free Tier** (Always Free):
- Core numerology calculation (Life Seal, Soul, Personality, Personal Year)
- 3 saved readings (local only)
- Basic interpretations (shortened - first 50 chars only)
- PDF export (basic 1-page template, 1/month limit)
- Compatibility check (score only, no details)

**Premium Tier** ($2.99/month or $24.99/year):
- Unlimited saved readings
- Full interpretations (complete text)
- Advanced analytics (personal month tracking, life cycle forecasts)
- Unlimited PDF exports (4-page professional)
- Priority support (email within 24 hours)
- Detailed compatibility analysis
- Ad-free experience
- Early access to new features
- AI-powered daily insights

**Pro Tier** ($49.99/year - Optional):
- Everything in Premium
- Custom PDF branding (add your name/logo to reports)
- 1-on-1 coaching session (30 min video call with numerologist)
- Group readings (compare up to 10 people)
- API access (for developers building integrations)

**What's Needed**:
- Database schema for subscription status
- Paywall logic throughout app
- Feature gates (check subscription before showing content)
- Graceful degradation (show upgrade prompts)

---

#### 7.2 In-App Purchase Implementation
**Status**: NOT STARTED

**Flutter Implementation**:
```
lib/core/iap/
├── purchase_service.dart - In-app purchase logic
├── subscription_manager.dart - Manage subscriptions
└── paywall_repository.dart - Fetch subscription offers

lib/features/paywall/
├── paywall_page.dart - Beautiful upgrade screen
└── premium_badge.dart - "Premium Feature" indicators
```

**iOS Setup**:
- App Store Connect configuration
- Create subscriptions (monthly, annual)
- Set pricing for each region
- Create review screenshots
- Privacy policy for subscriptions

**Android Setup**:
- Google Play Console configuration
- Create subscriptions (same)
- Test purchases
- Billing library integration

**Backend Changes**:
```python
POST /subscription/validate - Verify receipt with Apple/Google
GET /subscription/status/{user_id} - Check user subscription
```

**Paywall Screens Needed**:
1. **Soft Paywall**: "Unlock full interpretation - See all details"
2. **Hard Paywall**: "Save more than 3 readings - Upgrade to Premium"
3. **Onboarding Paywall**: After first calculation, show value
4. **Post-Action Paywall**: After exporting PDF, suggest unlimited exports

**Effort**: High (iOS/Android specific + backend validation)

---

#### 7.3 User Accounts & Backend Persistence
**Status**: NOT STARTED (Currently local-only)

**Current State**:
- All readings stored locally on device
- No user accounts
- No cloud sync
- No backup

**What's Needed**:

1. **Authentication System**:
   ```python
   POST /auth/register - Create account
   POST /auth/login - Login with email/password
   POST /auth/logout - Logout
   POST /auth/refresh - Refresh token
   GET /auth/me - Get current user
   ```

2. **User Data Sync**:
   ```python
   POST /readings - Save reading to cloud
   GET /readings - Fetch all user readings
   DELETE /readings/{id} - Delete reading
   
   POST /preferences - Save user preferences
   GET /preferences - Fetch preferences
   ```

3. **Database Schema**:
   - `users` table (id, email, password_hash, created_at)
   - `readings` table (id, user_id, full_data, created_at)
   - `preferences` table (user_id, notification_settings, etc.)
   - `subscriptions` table (user_id, tier, expires_at)

4. **Frontend Changes**:
   ```
   lib/features/auth/
   ├── login_page.dart
   ├── signup_page.dart
   ├── auth_service.dart
   └── auth_provider.dart
   
   lib/features/settings/
   ├── account_page.dart
   └── sync_settings.dart
   ```

**Considerations**:
- JWT tokens for authentication
- Refresh token rotation
- Secure storage of credentials
- Email verification
- Password reset flow
- GDPR/privacy compliance

**Effort**: Very High (auth + sync + database + security)

---

#### 7.4 Coach/Expert Access
**Status**: SKELETAL (Phase 7 roadmap mentions it)

**What's Needed**:

1. **Coach Directory**
   ```python
   GET /coaches - List available coaches
   GET /coaches/{id} - Coach profile
   POST /bookings - Schedule session
   ```

2. **Booking System**
   - Calendar integration (availability)
   - Video call integration (Zoom/Google Meet)
   - Payment processing (Stripe)

3. **Coach Features**:
   - Coach dashboard
   - Session notes storage
   - Follow-up recommendations
   - Client history

4. **Frontend**:
   ```
   lib/features/coaching/
   ├── coach_directory_page.dart
   ├── coach_profile_page.dart
   ├── booking_page.dart
   └── session_history_page.dart
   ```

**Effort**: Very High (marketplace + video calls + payment)

---

## 📋 FEATURE IMPLEMENTATION PRIORITY

### 🔴 CRITICAL PATH (Must Have for MVP+)
1. **Enhanced Daily Insights UI** (Week 1-2)
   - Mobile refinement
   - Notification integration
   - Calendar visualization

2. **Push Notifications** (Week 2-3)
   - Firebase setup
   - Job scheduler
   - Notification preferences working end-to-end

3. **In-App Purchases** (Week 3-4)
   - iOS/Android setup
   - Paywall implementation
   - Feature gates

### 🟠 HIGH VALUE (Should Have)
4. **Content Hub** (Week 4-5)
   - Educational articles
   - Backend API
   - Frontend UI

5. **Social Sharing** (Week 5-6)
   - Share cards
   - Referral tracking
   - Viral mechanics

6. **Analytics** (Week 6)
   - Firebase integration
   - Event tracking
   - Dashboard

### 🟡 NICE TO HAVE (Could Have)
7. **Enhanced Interpretations** (Week 7)
   - Gender/goal-based variants
   - Interpretation styles

8. **User Accounts** (Week 8-9)
   - Auth system
   - Cloud sync
   - Backup/restore

9. **Coach Platform** (Week 10+)
   - Directory
   - Booking system
   - Video calls

---

## 🔧 TECHNICAL DEBT & CLEANUP

### Backend
- [ ] Add database models (PostgreSQL recommended)
- [ ] Implement proper user authentication (JWT)
- [ ] Add logging & error tracking
- [ ] Add request rate limiting
- [ ] Add CORS configuration for production
- [ ] Add health check endpoint
- [ ] Add database migrations
- [ ] Add background job scheduler
- [ ] Add email service integration

### Frontend
- [ ] Add Firebase setup instructions
- [ ] Complete settings page functionality
- [ ] Add error handling throughout
- [ ] Add loading states for all async operations
- [ ] Add offline mode support
- [ ] Add crash reporting
- [ ] Optimize bundle size
- [ ] Add accessibility features

### Infrastructure
- [ ] Add monitoring & alerting
- [ ] Add CI/CD pipeline
- [ ] Add database backups
- [ ] Add CDN for assets
- [ ] Add SSL certificates
- [ ] Add rate limiting at nginx level
- [ ] Document environment variables
- [ ] Create runbooks for deployment

---

## 📊 SUCCESS METRICS BY PHASE

### Phase 6 (Growth)
- DAU increases from 0 to 100+ per day
- Retention: 30-day cohort > 20%
- Session length: 3+ min average
- Content consumption: 40% read ≥1 article
- Notification opt-in: 60%+

### Phase 7 (Monetization)
- Conversion rate: 5-8% (free → premium)
- Monthly Recurring Revenue (MRR): $5,000+
- Lifetime value: $50+
- Subscription churn: < 5% monthly

---

## 📝 NOTES

**Firebase Not Configured**: Current mobile app has Firebase try/catch that catches initialization errors. This needs to be properly set up for:
- Cloud Messaging (push notifications)
- Analytics
- Crashlytics (error reporting)

**Notification Endpoints Exist**: Backend has skeleton for notifications but no persistence or actual Firebase integration.

**Daily Insights Endpoints Exist**: Backend has endpoints for daily power numbers, blessed days, personal month - but mobile UI is minimal.

**History Feature Structure Exists**: Mobile has data/domain/presentation folders for history but likely incomplete.

**All Components Modular**: Good separation means adding features won't break existing code.

