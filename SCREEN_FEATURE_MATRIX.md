# SCREEN ↔ FEATURE MATRIX

**STATUS: FROZEN — Maps screens to features**  
**Purpose: Eliminate ambiguity about what each screen does and doesn't do**

---

## How to Read This Matrix

Each screen lists:
- ✅ **IMPLEMENTS** — Features this screen is responsible for
- ❌ **DOES NOT** — Features this screen explicitly does NOT have
- 📥 **RECEIVES** — Data this screen receives via props
- 📤 **EMITS** — Actions this screen can trigger

---

## AUTH SCREENS (3)

### A1: LoginScreen
```
✅ IMPLEMENTS:
   - Email/password input
   - Social login buttons (Apple, Google)
   - Forgot password link
   - Sign up link
   - Error display

❌ DOES NOT:
   - Create accounts
   - Verify email
   - Handle MFA
   - Remember me (v2)

📥 RECEIVES:
   - isLoading: boolean
   - error: string | null

📤 EMITS:
   - onLogin(email, password)
   - onSocialLogin(provider)
   - onForgotPassword()
   - onSignUp()
```

### A2: SignupScreen
```
✅ IMPLEMENTS:
   - Name, email, password inputs
   - Password requirements display
   - Terms checkbox
   - Social signup buttons

❌ DOES NOT:
   - Email verification (happens after)
   - Phone verification
   - Profile photo upload

📥 RECEIVES:
   - isLoading: boolean
   - error: string | null

📤 EMITS:
   - onSignUp(name, email, password)
   - onSocialSignUp(provider)
   - onLogin()
```

### A3: ForgotPasswordScreen
```
✅ IMPLEMENTS:
   - Email input
   - Send reset link button
   - Success state display

❌ DOES NOT:
   - New password input (that's in email link)
   - Phone reset

📥 RECEIVES:
   - isLoading: boolean
   - isSuccess: boolean
   - error: string | null

📤 EMITS:
   - onSendReset(email)
   - onBackToLogin()
```

---

## HUSTLER SCREENS (9)

### H1: HustlerHomeScreen
```
✅ IMPLEMENTS:
   - XP display (current, level)
   - Trust tier badge
   - Available tasks count
   - Active task card (if any)
   - Recent earnings summary
   - "Find Work" button
   - Activity streak ("X tasks this week")
   - Consecutive weeks active streak

❌ DOES NOT:
   - Task list (that's TaskFeedScreen)
   - Task details
   - Settings
   - Full earnings history
   - Gamification pressure (just simple counts)

📥 RECEIVES:
   - user: { xp, level, trustTier }
   - activeTask: Task | null
   - availableTasksCount: number
   - recentEarnings: number
   - weeklyTaskCount: number
   - currentStreak: number
   - isLoading: boolean

📤 EMITS:
   - onFindWork()
   - onViewActiveTask()
   - onViewEarnings()
```

### H2: TaskFeedScreen
```
✅ IMPLEMENTS:
   - Task list (scrollable)
   - Filter controls
   - Sort options
   - Pull-to-refresh
   - Empty state

❌ DOES NOT:
   - Eligibility computation (server does this)
   - Task acceptance (that's TaskDetailScreen)
   - Map view

📥 RECEIVES:
   - tasks: Task[]
   - filters: FilterState
   - isLoading: boolean

📤 EMITS:
   - onFilterChange(filters)
   - onTaskSelect(taskId)
   - onRefresh()
```

### H3: TaskHistoryScreen
```
✅ IMPLEMENTS:
   - Completed tasks list
   - Cancelled tasks list
   - Earnings per task
   - Date completed

❌ DOES NOT:
   - Active tasks
   - Task details (link only)

📥 RECEIVES:
   - tasks: HistoricalTask[]
   - isLoading: boolean

📤 EMITS:
   - onTaskSelect(taskId)
```

### H4: TaskDetailScreen
```
✅ IMPLEMENTS:
   - Task title & description
   - Pay amount
   - Required trust tier
   - Required capabilities
   - Location map preview
   - Poster info (rating, count)
   - Accept button
   - Eligibility status

❌ DOES NOT:
   - Eligibility computation (server provides)
   - In-progress view
   - Messaging

📥 RECEIVES:
   - task: Task
   - eligibilityStatus: 'eligible' | 'ineligible' | 'checking'
   - eligibilityReason: string | null
   - isLoading: boolean

📤 EMITS:
   - onAccept()
   - onBack()
```

### H5: TaskInProgressScreen
```
✅ IMPLEMENTS:
   - Task summary card
   - Map with directions
   - Navigation button
   - Time tracking
   - Cancel button
   - Chat button
   - Complete button
   - State indicator (EN_ROUTE, WORKING)

❌ DOES NOT:
   - Full navigation (links to EnRouteMapScreen)
   - Proof submission (that's TaskCompletionScreen)

📥 RECEIVES:
   - task: Task
   - taskState: 'EN_ROUTE' | 'WORKING'
   - elapsedTime: number
   - isLoading: boolean

📤 EMITS:
   - onOpenNavigation()
   - onChat()
   - onCancel()
   - onArrive() (EN_ROUTE → WORKING)
   - onComplete()
```

### H6: TaskCompletionScreen (Hustler)
```
✅ IMPLEMENTS:
   - Photo upload (required)
   - Note input (optional)
   - Submit button
   - Submission preview
   - Status display (submitted, approved, rejected)

❌ DOES NOT:
   - Video upload
   - Multiple resubmissions (one try, then dispute)

📥 RECEIVES:
   - task: Task
   - submissionStatus: 'pending' | 'submitted' | 'approved' | 'rejected'
   - rejectionReason: string | null
   - isLoading: boolean

📤 EMITS:
   - onUploadPhoto(uri)
   - onSubmit(photo, note)
```

### H7: HustlerEnRouteMapScreen
```
✅ IMPLEMENTS:
   - Full-screen map
   - Current location marker
   - Destination marker
   - Route line
   - ETA display
   - Exit button

❌ DOES NOT:
   - Task details
   - Chat
   - Turn-by-turn voice

📥 RECEIVES:
   - destination: { lat, lng, address }
   - currentLocation: { lat, lng }
   - eta: number

📤 EMITS:
   - onExit()
   - onOpenExternalNav()
```

### H8: XPBreakdownScreen
```
✅ IMPLEMENTS:
   - Total XP display
   - Level progress bar
   - XP history list
   - XP sources breakdown
   - Trust tier explanation

❌ DOES NOT:
   - XP modification
   - Trust tier change (read only)

📥 RECEIVES:
   - totalXP: number
   - level: number
   - xpToNextLevel: number
   - history: XPEntry[]
   - breakdown: { source: string, amount: number }[]

📤 EMITS:
   - onBack()
```

### H9: InstantInterruptCard
```
✅ IMPLEMENTS:
   - Task summary
   - Pay amount
   - Distance
   - Accept button with countdown
   - Decline button
   - Auto-dismiss

❌ DOES NOT:
   - Full task details
   - Negotiation
   - Multiple tasks at once

📥 RECEIVES:
   - task: Task
   - distance: number
   - countdownSeconds: number

📤 EMITS:
   - onAccept()
   - onDecline()
```

---

## POSTER SCREENS (4)

### P1: TaskCreationScreen
```
✅ IMPLEMENTS:
   - Title input (with AI suggestion)
   - Description input
   - Category selector (with AI suggestion)
   - Location picker
   - Pay amount input (with AI suggested range)
   - Trust tier selector (with AI suggestion)
   - Capability requirements
   - Photo upload (optional)
   - Price breakdown
   - Post button
   - Recurring task toggle (weekly/bi-weekly/monthly)
   
   AI TASK ASSISTANT:
   - AI suggests title based on description
   - AI suggests category based on content
   - AI suggests duration estimate
   - AI suggests trust tier / risk level
   - AI suggests price range ("Suggested: $XX - $YY")
   - AI ASKS FOLLOW-UP QUESTIONS:
     → "What specific outcome marks this task as complete?"
     → "Are there any tools or materials the hustler needs?"
     → "What's the exact location/address?"
     → "Any time constraints or deadlines?"
   - AI flags ambiguous requirements
   - AI validates completeness before posting
   - All suggestions clearly labeled "AI Suggested"
   - User has final control on all fields

❌ DOES NOT:
   - Bidding
   - Multiple hustlers
   - AI auto-submit (user must confirm)
   - AI auto-pricing (only suggests range)
   - Voice/video in task description

📥 RECEIVES:
   - userBalance: number
   - minimumPay: number
   - categories: Category[]
   - isSubmitting: boolean
   - aiSuggestions?: {
       title?: string
       category?: string
       duration?: number
       trustTier?: number
       priceRange?: { min: number, max: number }
     }
   - aiFollowUpQuestions?: string[]

📤 EMITS:
   - onSubmit(taskDraft)
   - onCancel()
   - onRequestAISuggestions(description)
   - onAnswerFollowUp(questionId, answer)
```

### P2: HustlerOnWayScreen
```
✅ IMPLEMENTS:
   - Map with hustler location (live)
   - Hustler info card
   - ETA display
   - Chat button
   - Cancel button
   - Task summary

❌ DOES NOT:
   - Multiple hustlers
   - Hustler selection
   - Route modification

📥 RECEIVES:
   - task: Task
   - hustler: { id, name, rating, photo, location }
   - eta: number
   - isLoading: boolean

📤 EMITS:
   - onChat()
   - onCancel()
```

### P3: TaskCompletionScreen (Poster)
```
✅ IMPLEMENTS:
   - Proof photos (expandable)
   - Proof note
   - Hustler info
   - Approve button
   - Dispute button
   - Task summary

❌ DOES NOT:
   - Partial approval
   - Tip adding
   - Rating (that's FeedbackScreen)

📥 RECEIVES:
   - task: Task
   - proof: { photos, note, submittedAt }
   - hustler: { name, rating }
   - isApproving: boolean

📤 EMITS:
   - onApprove()
   - onDispute()
```

### P4: FeedbackScreen
```
✅ IMPLEMENTS:
   - Star rating (1-5)
   - Text review input (max 500 chars, optional)
   - Specific feedback options
   - Submit button
   - Skip option

❌ DOES NOT:
   - Photo attachment
   - Tip
   - Video review
   - Edit after submission

📥 RECEIVES:
   - task: Task
   - hustler: { name, photo }
   - isSubmitting: boolean

📤 EMITS:
   - onSubmit(rating, review, feedback)
   - onSkip()
```


---

## ONBOARDING SCREENS (12)

### O1: FramingScreen ✅
```
✅ IMPLEMENTS:
   - Welcome message
   - Value proposition cards
   - How it works explanation
   - Continue button

❌ DOES NOT:
   - Data collection
   - Account creation
   - Skip option

📥 RECEIVES:
   - currentStep (number)
   - totalSteps (number)

📤 EMITS:
   - onContinue()

📋 STITCH-PROMPT: O1-framing-screen.md
```

### O2: CalibrationScreen
```
✅ IMPLEMENTS:
   - Question cards
   - Progress indicator
   - Answer options
   - Skip option (with warning)

❌ DOES NOT:
   - Adaptive questions
   - Detailed explanations per question

📥 RECEIVES:
   - questions: Question[]
   - currentIndex: number

📤 EMITS:
   - onAnswer(questionId, answer)
   - onSkip()
```

### O3: RoleConfirmationScreen
```
✅ IMPLEMENTS:
   - Hustler option card
   - Poster option card
   - Both option
   - Role explanations
   - Continue button

❌ DOES NOT:
   - Role-specific onboarding branch

📥 RECEIVES:
   - (none)

📤 EMITS:
   - onSelectRole(role: 'hustler' | 'poster' | 'both')
```

### O4: PreferenceLockScreen
```
✅ IMPLEMENTS:
   - Summary of all selections
   - Edit links per section
   - Confirm button
   - Warning about changes

❌ DOES NOT:
   - Inline editing
   - Undo after confirm

📥 RECEIVES:
   - selections: SelectionSummary

📤 EMITS:
   - onEdit(section)
   - onConfirm()
```

### O5-O12: Capability Screens
```
All capability screens follow the same pattern:

✅ IMPLEMENTS:
   - Single capability input
   - Validation
   - Skip option (where applicable)
   - Continue button

❌ DOES NOT:
   - Multiple capabilities at once
   - Complex verification (that's async backend)

📥 RECEIVES:
   - currentValue: CapabilityValue | null
   - isLoading: boolean

📤 EMITS:
   - onSave(value)
   - onSkip()
   - onContinue()
```

---

## SETTINGS SCREENS (3)

### S1: ProfileScreen
```
✅ IMPLEMENTS:
   - Profile photo (editable)
   - Display name (editable)
   - Email (read-only)
   - Phone (editable)
   - Trust tier (read-only)
   - XP display (read-only)
   - Logout button

❌ DOES NOT:
   - Email change (requires verification flow)
   - Password change (separate flow)
   - Account deletion

📥 RECEIVES:
   - user: User
   - isLoading: boolean

📤 EMITS:
   - onUpdatePhoto(uri)
   - onUpdateProfile(updates)
   - onLogout()
```

### S2: WalletScreen
```
✅ IMPLEMENTS:
   - Current balance
   - Pending earnings
   - Payment methods list
   - Add payment method button
   - Withdrawal button
   - Transaction history

❌ DOES NOT:
   - In-app card entry (external flow)
   - Instant transfers
   - Crypto

📥 RECEIVES:
   - balance: number
   - pendingEarnings: number
   - paymentMethods: PaymentMethod[]
   - transactions: Transaction[]
   - isLoading: boolean

📤 EMITS:
   - onAddPaymentMethod()
   - onWithdraw()
   - onViewTransaction(id)
```

### S3: WorkEligibilityScreen
```
✅ IMPLEMENTS:
   - Current trust tier
   - Risk clearance level
   - Work location
   - Verified trades list
   - Insurance status
   - Background check status
   - Upgrade opportunities
   - System notices

❌ DOES NOT:
   - Eligibility modification (read-only)
   - Verification initiation (links to other screens)
   - Trust tier change

📥 RECEIVES:
   - currentTrustTier: number
   - riskClearance: RiskLevel
   - workLocation: string
   - verifiedTrades: VerifiedTrade[]
   - insuranceStatus: VerificationStatus
   - backgroundCheckStatus: VerificationStatus
   - upgradeOpportunities: Opportunity[]
   - systemNotices: Notice[]

📤 EMITS:
   - onUpgrade(opportunityId)
   - onDismissNotice(noticeId)
```

---

## SHARED SCREENS (4)

### SH1: TaskConversationScreen
```
✅ IMPLEMENTS:
   - Message list (scrollable)
   - Message input
   - Send button
   - Photo attachment
   - Read receipts
   - Typing indicator
   - Task context header

❌ DOES NOT:
   - Voice messages
   - Video messages
   - File attachments (non-photo)
   - Message editing
   - Message deletion

📥 RECEIVES:
   - task: Task
   - messages: Message[]
   - otherUser: { name, photo }
   - isLoading: boolean

📤 EMITS:
   - onSendMessage(text)
   - onSendImage(uri)
   - onBack()
```

### SH2: TrustTierLadderScreen
```
✅ IMPLEMENTS:
   - All 6 tiers displayed
   - Current tier highlighted
   - XP required per tier
   - Benefits per tier
   - Progress to next tier

❌ DOES NOT:
   - Tier modification
   - Detailed history

📥 RECEIVES:
   - currentTier: number
   - currentXP: number
   - tiers: TierInfo[]

📤 EMITS:
   - onBack()
```

### SH3: TrustChangeExplanationScreen
```
✅ IMPLEMENTS:
   - Previous tier
   - New tier
   - Change reason
   - Contributing factors
   - Recommendations (if decreased)
   - Celebration (if increased)

❌ DOES NOT:
   - Appeal process
   - Detailed factor breakdown

📥 RECEIVES:
   - previousTier: number
   - newTier: number
   - changeReason: string
   - factors: Factor[]
   - recommendations: string[]

📤 EMITS:
   - onDismiss()
```

### SH4: DisputeEntryScreen
```
✅ IMPLEMENTS:
   - Dispute reason selector
   - Description input
   - Evidence upload (photos)
   - Task context summary
   - Submit button
   - What happens next

❌ DOES NOT:
   - Video evidence
   - Witness addition
   - Partial disputes

📥 RECEIVES:
   - task: Task
   - isSubmitting: boolean

📤 EMITS:
   - onSubmit(disputeDraft)
   - onCancel()
```

---

## EDGE SCREENS (3)

### E1: NoTasksAvailableScreen
```
✅ IMPLEMENTS:
   - Empty state illustration
   - "No tasks available" message
   - Possible reasons list
   - Suggestions list
   - Refresh button
   - Link to WorkEligibility

❌ DOES NOT:
   - Task creation prompt (for hustlers)
   - Location change

📥 RECEIVES:
   - possibleReasons: string[]
   - suggestions: Suggestion[]

📤 EMITS:
   - onRefresh()
   - onExpandRadius()
   - onAddCapabilities()
   - onViewEligibility()
```

### E2: EligibilityMismatchScreen
```
✅ IMPLEMENTS:
   - Task summary
   - Requirements list
   - User status per requirement (met/not met)
   - How to become eligible
   - Upgrade action links

❌ DOES NOT:
   - Inline verification
   - Request exception

📥 RECEIVES:
   - task: Task
   - requirements: Requirement[]
   - userStatus: RequirementStatus[]
   - upgradeActions: UpgradeAction[]

📤 EMITS:
   - onUpgrade(actionId)
   - onBack()
```

### E3: TrustTierLockedScreen
```
✅ IMPLEMENTS:
   - Task summary
   - Required tier
   - Current tier
   - XP needed
   - Estimated tasks to complete
   - Progress visualization
   - Link to TrustTierLadder

❌ DOES NOT:
   - Tier bypass request
   - Instant upgrade

📥 RECEIVES:
   - task: Task
   - requiredTier: number
   - currentTier: number
   - currentXP: number
   - xpNeeded: number
   - estimatedTasks: number

📤 EMITS:
   - onViewTrustLadder()
   - onBack()
```

---

## MATRIX SUMMARY

| Screen | Features Implemented | Features Excluded |
|--------|---------------------|-------------------|
| Auth (3) | Login, signup, reset | MFA, social only |
| Hustler (9) | Full task lifecycle | Bidding, team tasks |
| Poster (4) | Creation, tracking, approval | Recurring, smart pricing |
| Onboarding (12) | Full capability setup | Adaptive paths |
| Settings (3) | Profile, wallet, eligibility | Account deletion |
| Shared (4) | Messaging, trust, disputes | Voice, video |
| Edge (3) | Empty states, explanations | Bypass options |

---

**This matrix is frozen. If a screen implements something not listed here, it's a bug.**
