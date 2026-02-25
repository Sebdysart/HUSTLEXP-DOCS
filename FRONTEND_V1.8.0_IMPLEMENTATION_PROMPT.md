# Frontend Implementation Guide: HustleXP v1.8.0 Gamification Features

> **⚠️ TECH STACK NOTE:** This guide was written for a React Native scaffold. The active iOS app (HUSTLEXPFINAL1) is **native Swift/SwiftUI**. Code examples below use React Native / tRPC React Query patterns — map to Swift equivalents (async/await, TRPCClient.swift). The API contracts and tRPC router names remain authoritative.

**Target Audience:** Frontend Team (Swift/SwiftUI — originally React Native)
**Backend Version:** v1.8.0 (hustlexp-ai-backend)
**Documentation:** HUSTLEXP-DOCS v1.8.0
**Release Date:** 2026-02-06

---

## 🎯 Executive Summary

Version 1.8.0 introduces major gamification enhancements that require frontend integration across multiple screens. This guide provides everything you need to implement:

- **XP Tax System** - 10% tax on offline payments with payment flow
- **Earned Verification Unlock** - Free ID verification after $40 profit
- **Biometric Proof Submission** - GPS + photo validation for proofs
- **AI-Suggested Pricing** - Optional Scoper AI task pricing proposals
- **Insurance Pool** - 2% contribution per task, claim filing workflow
- **Fraud Detection Feedback** - User alerts for GPS/travel violations

---

## 📊 New API Endpoints (tRPC)

### 1. XP Tax Router (`xpTax`)

#### `xpTax.getTaxStatus`
**Returns current tax status for logged-in user**

```typescript
const { data } = trpc.xpTax.getTaxStatus.useQuery();

// Response type
type TaxStatus = {
  unpaid_tax_cents: number;      // e.g., 1500 = $15.00
  xp_held_back: number;           // XP points blocked by unpaid tax
  blocked: boolean;               // true if XP awards are blocked
  last_payment_at: Date | null;  // Last tax payment timestamp
}

// Example usage
if (data?.blocked) {
  // Show alert: "You have $15.00 in unpaid taxes. Pay now to unlock XP rewards!"
}
```

#### `xpTax.payTax`
**Pay outstanding tax balance via Stripe**

```typescript
const payTaxMutation = trpc.xpTax.payTax.useMutation();

// Call after Stripe payment_intent succeeds
await payTaxMutation.mutateAsync({
  stripe_payment_intent_id: 'pi_xxx'
});

// Response
{
  success: true,
  xp_released: 500  // XP points unlocked after payment
}
```

#### `xpTax.getTaxHistory`
**Get tax payment history**

```typescript
const { data } = trpc.xpTax.getTaxHistory.useQuery();

// Response type
type TaxLedgerEntry = {
  id: string;
  task_id: string;
  payment_method: 'offline_cash' | 'offline_venmo' | 'offline_cashapp';
  gross_payout_cents: number;
  tax_amount_cents: number;
  tax_paid: boolean;
  paid_at: Date | null;
  stripe_payment_intent_id: string | null;
}[]
```

**UI Requirements:**
- Add "Tax Balance" card to Profile/Wallet screen
- Show unpaid balance prominently (red badge if blocked)
- "Pay Now" button → Stripe payment flow
- Tax history list (similar to transaction history)
- Success toast: "Tax paid! You've unlocked {xp} XP"

---

### 2. Verification Unlock Router (`user`)

#### `user.getVerificationUnlockStatus`
**Check progress toward $40 verification unlock**

```typescript
const { data } = trpc.user.getVerificationUnlockStatus.useQuery();

// Response type
type VerificationUnlockStatus = {
  earned_cents: number;           // e.g., 2500 = $25.00 earned
  threshold_cents: number;        // Always 4000 ($40.00)
  percentage: number;             // e.g., 62.5 (62.5% complete)
  unlocked: boolean;              // true when earned >= threshold
  tasks_completed: number;        // Number of tasks contributing to unlock
  remaining_cents: number;        // e.g., 1500 = $15.00 remaining
}

// Example usage
if (data?.percentage >= 100) {
  // Show "Unlock Free Verification" CTA
}
```

#### `user.checkVerificationEligibility`
**Boolean check if user can submit verification**

```typescript
const { data } = trpc.user.checkVerificationEligibility.useQuery();

// Response: { eligible: boolean }
```

#### `user.getVerificationEarningsLedger`
**Detailed earnings breakdown**

```typescript
const { data } = trpc.user.getVerificationEarningsLedger.useQuery();

// Response type
type EarningsEntry = {
  task_id: string;
  escrow_id: string;
  net_payout_cents: number;  // After 20% platform fee
  earned_at: Date;
}[]
```

**UI Requirements:**
- Add "Verification Unlock" progress card to Profile screen
- Circular progress indicator (0-100%)
- Text: "Earn {remaining} more to unlock free verification"
- When unlocked: Green checkmark + "Free Verification Unlocked!" badge
- Gate verification submission: if (!eligible) show "Complete $X more tasks"
- Show earnings ledger in expandable accordion

---

### 3. Biometric Router (`biometric`)

#### `biometric.submitBiometricProof`
**Submit proof with GPS + photo for validation**

```typescript
const submitProofMutation = trpc.biometric.submitBiometricProof.useMutation();

await submitProofMutation.mutateAsync({
  proof_id: 'proof_xxx',
  photo_url: 'https://r2.../photo.jpg',  // After R2 upload
  gps_coordinates: {
    latitude: 37.7749,
    longitude: -122.4194
  },
  gps_accuracy_meters: 10.5,
  gps_timestamp: new Date().toISOString(),
  lidar_depth_map_url: 'https://r2.../depth.jpg',  // iOS only
  device_model: 'iPhone 15 Pro',
  os_version: 'iOS 18.2'
});

// Response
{
  recommendation: 'approve' | 'manual_review' | 'reject',
  reasoning: string,
  flags: string[],  // e.g., ['low_accuracy', 'impossible_travel']
  scores: {
    liveness: number,        // 0-100 (>70 = pass)
    deepfake: number,        // 0-100 (<80 = pass)
    gps_proximity: number    // 0-100 (distance-based)
  },
  risk_level: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'
}
```

**UI Requirements:**
- Proof submission screen must capture GPS coordinates
  ```typescript
  import * as Location from 'expo-location';

  const location = await Location.getCurrentPositionAsync({
    accuracy: Location.Accuracy.High
  });
  ```
- Request camera + location permissions upfront
- iOS: Detect Face ID availability for LiDAR capture
- Show validation feedback after submission:
  - **approve**: Green checkmark, "Proof submitted successfully"
  - **manual_review**: Yellow warning, "Your proof is under review"
  - **reject**: Red X, show `reasoning` (e.g., "GPS too far from task location")
- Display risk flags as chips (e.g., "Low GPS Accuracy", "Weak Liveness")

---

### 4. Insurance Router (`insurance`)

#### `insurance.getPoolStatus`
**Get insurance pool overview**

```typescript
const { data } = trpc.insurance.getPoolStatus.useQuery();

// Response type
{
  pool_balance_cents: number,      // e.g., 125000 = $1,250.00
  total_contributions_cents: number,
  total_paid_claims_cents: number,
  active_claims_count: number
}
```

#### `insurance.fileClaim`
**File insurance claim**

```typescript
const fileClaimMutation = trpc.insurance.fileClaim.useMutation();

await fileClaimMutation.mutateAsync({
  task_id: 'task_xxx',
  incident_description: 'Client never responded after I completed work',
  requested_amount_cents: 5000  // $50.00
});

// Response
{
  claim_id: string,
  status: 'filed'
}
```

#### `insurance.getMyClaims`
**Get user's claim history**

```typescript
const { data } = trpc.insurance.getMyClaims.useQuery();

// Response type
type Claim = {
  id: string,
  task_id: string,
  incident_description: string,
  requested_amount_cents: number,
  approved_amount_cents: number | null,
  status: 'filed' | 'under_review' | 'approved' | 'denied' | 'paid',
  filed_at: Date,
  reviewed_at: Date | null,
  reviewer_notes: string | null
}[]
```

**UI Requirements:**
- Add "Insurance" section to Profile/Wallet
- Show pool status card (balance, your contributions)
- "File a Claim" button in completed task detail screen
- Claim form:
  - Task selection dropdown
  - Incident description textarea (max 500 chars)
  - Requested amount input ($1-$5000)
  - Submit button
- Claims list (similar to transaction history)
  - Status badges (filed=gray, under_review=yellow, approved=green, denied=red, paid=blue)
  - Expandable for reviewer notes

---

### 5. Task Creation with AI Pricing (Enhanced)

#### `task.create` (Enhanced)
**Scoper AI suggests pricing if price=0**

```typescript
const createTaskMutation = trpc.task.create.useMutation();

// Option 1: User provides price (existing behavior)
await createTaskMutation.mutateAsync({
  title: 'Mow my lawn',
  description: 'Front and back yard, about 1000 sq ft',
  price: 2500,  // $25.00 (user sets price)
  category: 'yard_work',
  // ... other fields
});

// Option 2: Let AI suggest price (NEW)
await createTaskMutation.mutateAsync({
  title: 'Mow my lawn',
  description: 'Front and back yard, about 1000 sq ft',
  price: 0,  // ⚠️ Triggers Scoper AI
  category: 'yard_work',
  // ... other fields
});

// If price=0, backend calls ScoperAIService and returns:
{
  task: {
    id: 'task_xxx',
    price: 2750,        // AI suggested $27.50 (mid-point of range)
    xp_reward: 275,     // price / 10
    ai_suggested_price: true  // Flag indicating AI pricing
  }
}
```

**UI Requirements:**
- Add "Suggest Price" toggle to Create Task screen
- When enabled, set price field to 0 before submission
- Show loading spinner: "AI is analyzing your task..."
- After response, display suggested price with explanation:
  - "AI suggests: **$27.50** for this task"
  - Rationale: "Based on difficulty (medium) and category (yard_work)"
  - User can edit price before final submission
- Price range display: "$20-$35" with slider at AI midpoint

---

## 🎮 Feature-by-Feature Implementation Guide

### Feature 1: XP Tax System 💰

**User Story:**
"As a hustler who gets paid offline (cash/Venmo), I need to pay a 10% tax to unlock my XP rewards."

**Affected Screens:**
1. **Profile/Wallet Screen** (NEW: Tax Balance Card)
2. **Task Completion Flow** (NEW: Tax notification)
3. **XP Breakdown Screen** (NEW: "Held XP" row)

**Implementation Steps:**

1. **Add Tax Status Query to Profile Screen**
```typescript
// screens/Profile.tsx
import { trpc } from '../utils/trpc';

export function ProfileScreen() {
  const taxStatus = trpc.xpTax.getTaxStatus.useQuery();

  return (
    <View>
      {/* Existing profile content */}

      {taxStatus.data?.blocked && (
        <TaxBalanceCard
          unpaidAmount={taxStatus.data.unpaid_tax_cents}
          xpHeld={taxStatus.data.xp_held_back}
          onPayPress={() => navigation.navigate('TaxPayment')}
        />
      )}
    </View>
  );
}
```

2. **Create Tax Balance Card Component**
```typescript
// components/TaxBalanceCard.tsx
export function TaxBalanceCard({ unpaidAmount, xpHeld, onPayPress }) {
  return (
    <Card style={styles.warningCard}>
      <Icon name="alert-circle" color="orange" />
      <Text style={styles.title}>Unpaid Tax Balance</Text>
      <Text style={styles.amount}>${(unpaidAmount / 100).toFixed(2)}</Text>
      <Text style={styles.subtitle}>
        {xpHeld} XP locked until payment
      </Text>
      <Button onPress={onPayPress}>Pay Now</Button>
    </Card>
  );
}
```

3. **Create Tax Payment Screen**
```typescript
// screens/TaxPaymentScreen.tsx
export function TaxPaymentScreen() {
  const taxStatus = trpc.xpTax.getTaxStatus.useQuery();
  const payTax = trpc.xpTax.payTax.useMutation();
  const [clientSecret, setClientSecret] = useState(null);

  const handlePayment = async () => {
    // 1. Create Stripe PaymentIntent on backend (separate endpoint)
    const intent = await createPaymentIntent(taxStatus.data.unpaid_tax_cents);
    setClientSecret(intent.clientSecret);

    // 2. Show Stripe payment sheet
    const { error } = await presentPaymentSheet({ clientSecret });

    if (!error) {
      // 3. Confirm payment with backend
      await payTax.mutateAsync({
        stripe_payment_intent_id: intent.id
      });

      // 4. Show success
      Alert.alert(
        'Tax Paid!',
        `You've unlocked ${payTax.data.xp_released} XP`,
        [{ text: 'OK', onPress: () => navigation.goBack() }]
      );
    }
  };

  return (
    <View>
      <Text>Tax Balance: ${(taxStatus.data?.unpaid_tax_cents / 100).toFixed(2)}</Text>
      <Text>XP Held: {taxStatus.data?.xp_held_back}</Text>
      <Button onPress={handlePayment}>Pay with Card</Button>
    </View>
  );
}
```

4. **Add Tax Notification After Task Completion**
```typescript
// screens/TaskCompletionScreen.tsx
export function TaskCompletionScreen({ route }) {
  const { taskId, paymentMethod } = route.params;
  const taxStatus = trpc.xpTax.getTaxStatus.useQuery();

  useEffect(() => {
    if (paymentMethod !== 'escrow' && taxStatus.data?.blocked) {
      Alert.alert(
        'Tax Payment Required',
        'You received an offline payment. Pay 10% tax to unlock your XP!',
        [
          { text: 'Later', style: 'cancel' },
          { text: 'Pay Now', onPress: () => navigation.navigate('TaxPayment') }
        ]
      );
    }
  }, [taxStatus.data]);

  return (
    // ... existing completion UI
  );
}
```

**Testing Checklist:**
- [ ] Tax balance card shows on profile when tax unpaid
- [ ] Stripe payment flow completes successfully
- [ ] XP unlocked and level-up triggered after payment
- [ ] Tax history shows all payments
- [ ] Alert shows after offline payment task completion

---

### Feature 2: Earned Verification Unlock 🎯

**User Story:**
"As a new hustler, I can unlock free identity verification after earning the platform $40 in net profit."

**Affected Screens:**
1. **Profile Screen** (NEW: Unlock Progress Card)
2. **Verification Submission Screen** (ENHANCED: Eligibility gate)
3. **Task Completion Flow** (NEW: Progress update notification)

**Implementation Steps:**

1. **Add Progress Card to Profile Screen**
```typescript
// screens/Profile.tsx
export function ProfileScreen() {
  const unlockStatus = trpc.user.getVerificationUnlockStatus.useQuery();

  return (
    <View>
      <VerificationUnlockCard
        earnedCents={unlockStatus.data?.earned_cents}
        thresholdCents={unlockStatus.data?.threshold_cents}
        percentage={unlockStatus.data?.percentage}
        unlocked={unlockStatus.data?.unlocked}
        onUnlockPress={() => navigation.navigate('VerificationSubmission')}
      />
    </View>
  );
}
```

2. **Create Unlock Progress Component**
```typescript
// components/VerificationUnlockCard.tsx
export function VerificationUnlockCard({ earnedCents, thresholdCents, percentage, unlocked, onUnlockPress }) {
  const remainingCents = thresholdCents - earnedCents;

  return (
    <Card>
      <Text style={styles.title}>Free Verification</Text>

      {!unlocked ? (
        <>
          <CircularProgress
            value={percentage}
            radius={60}
            progressValueColor="#10B981"
          >
            <Text style={styles.percentage}>{percentage.toFixed(0)}%</Text>
          </CircularProgress>

          <Text style={styles.subtitle}>
            Earn ${(remainingCents / 100).toFixed(2)} more to unlock
          </Text>

          <Text style={styles.hint}>
            Complete {Math.ceil(remainingCents / 200)} more tasks
          </Text>
        </>
      ) : (
        <>
          <Icon name="check-circle" size={60} color="#10B981" />
          <Text style={styles.unlockedTitle}>Free Verification Unlocked!</Text>
          <Button onPress={onUnlockPress}>Submit Verification</Button>
        </>
      )}
    </Card>
  );
}
```

3. **Gate Verification Submission Screen**
```typescript
// screens/VerificationSubmissionScreen.tsx
export function VerificationSubmissionScreen() {
  const eligibility = trpc.user.checkVerificationEligibility.useQuery();

  if (!eligibility.data?.eligible) {
    return (
      <View style={styles.gated}>
        <Icon name="lock" size={80} color="gray" />
        <Text style={styles.title}>Verification Locked</Text>
        <Text style={styles.subtitle}>
          Complete more tasks to unlock free verification
        </Text>
        <Button onPress={() => navigation.navigate('TaskFeed')}>
          Browse Tasks
        </Button>
      </View>
    );
  }

  return (
    <View>
      {/* Existing verification form */}
      <Text style={styles.badge}>✨ Free (You've earned it!)</Text>
    </View>
  );
}
```

4. **Add Progress Notification After Task**
```typescript
// screens/TaskCompletionScreen.tsx
export function TaskCompletionScreen() {
  const unlockStatus = trpc.user.getVerificationUnlockStatus.useQuery();

  useEffect(() => {
    if (unlockStatus.data?.percentage >= 100 && !unlockStatus.data?.unlocked) {
      // First time hitting threshold
      Alert.alert(
        '🎉 Verification Unlocked!',
        'You\'ve earned $40 for the platform. Submit your ID verification for free!',
        [
          { text: 'Later', style: 'cancel' },
          { text: 'Verify Now', onPress: () => navigation.navigate('VerificationSubmission') }
        ]
      );
    } else if (unlockStatus.data?.percentage < 100) {
      // Progress update
      Toast.show({
        type: 'info',
        text1: `Verification: ${unlockStatus.data.percentage.toFixed(0)}% complete`,
        text2: `Earn $${(unlockStatus.data.remaining_cents / 100).toFixed(2)} more`
      });
    }
  }, [unlockStatus.data]);

  return (
    // ... completion UI
  );
}
```

**Testing Checklist:**
- [ ] Progress card shows 0% for new users
- [ ] Progress updates after each completed task
- [ ] Circular progress animates smoothly
- [ ] Alert fires when hitting 100%
- [ ] Verification screen gates submission before unlock
- [ ] Unlock badge shows after threshold reached

---

### Feature 3: Biometric Proof Submission 📸

**User Story:**
"As a hustler, I submit proof photos with GPS validation to prevent fraud and speed up approval."

**Affected Screens:**
1. **Proof Submission Screen** (ENHANCED: GPS capture + validation feedback)
2. **Proof Review Screen** (NEW: Risk indicators)

**Implementation Steps:**

1. **Request Permissions (App.tsx)**
```typescript
// App.tsx
import * as Location from 'expo-location';
import * as Camera from 'expo-camera';

async function requestPermissions() {
  const [cameraStatus, locationStatus] = await Promise.all([
    Camera.requestCameraPermissionsAsync(),
    Location.requestForegroundPermissionsAsync()
  ]);

  if (cameraStatus.status !== 'granted' || locationStatus.status !== 'granted') {
    Alert.alert(
      'Permissions Required',
      'HustleXP needs camera and location access to validate proof submissions.'
    );
  }
}
```

2. **Enhanced Proof Submission Screen**
```typescript
// screens/ProofSubmissionScreen.tsx
import * as Location from 'expo-location';
import * as ImagePicker from 'expo-image-picker';
import * as Device from 'expo-device';

export function ProofSubmissionScreen({ route }) {
  const { taskId } = route.params;
  const [photoUri, setPhotoUri] = useState(null);
  const [gpsData, setGpsData] = useState(null);
  const [uploading, setUploading] = useState(false);

  const submitProof = trpc.biometric.submitBiometricProof.useMutation();

  const captureProof = async () => {
    // 1. Capture GPS first (before photo)
    const location = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.High
    });

    setGpsData({
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      accuracy: location.coords.accuracy,
      timestamp: new Date(location.timestamp).toISOString()
    });

    // 2. Take photo
    const result = await ImagePicker.launchCameraAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      quality: 0.8,
      exif: true  // Capture EXIF data for iOS LiDAR
    });

    if (!result.canceled) {
      setPhotoUri(result.assets[0].uri);
    }
  };

  const handleSubmit = async () => {
    if (!photoUri || !gpsData) return;

    setUploading(true);

    try {
      // 1. Upload photo to R2
      const uploadedUrl = await uploadToR2(photoUri);

      // 2. Check for iOS LiDAR depth data
      let depthMapUrl = null;
      if (Device.osName === 'iOS' && result.assets[0].exif?.DepthData) {
        depthMapUrl = await uploadDepthMapToR2(result.assets[0].exif.DepthData);
      }

      // 3. Submit to backend
      const response = await submitProof.mutateAsync({
        proof_id: `proof_${taskId}`,
        photo_url: uploadedUrl,
        gps_coordinates: {
          latitude: gpsData.latitude,
          longitude: gpsData.longitude
        },
        gps_accuracy_meters: gpsData.accuracy,
        gps_timestamp: gpsData.timestamp,
        lidar_depth_map_url: depthMapUrl,
        device_model: Device.modelName,
        os_version: Device.osVersion
      });

      // 4. Show validation feedback
      handleValidationResponse(response);

    } catch (error) {
      Alert.alert('Submission Failed', error.message);
    } finally {
      setUploading(false);
    }
  };

  const handleValidationResponse = (response) => {
    if (response.recommendation === 'approve') {
      Alert.alert(
        '✅ Proof Submitted',
        'Your proof looks great! It\'s been approved.',
        [{ text: 'OK', onPress: () => navigation.goBack() }]
      );
    } else if (response.recommendation === 'manual_review') {
      Alert.alert(
        '⚠️ Manual Review Required',
        `Your proof is under review: ${response.reasoning}`,
        [{ text: 'OK', onPress: () => navigation.goBack() }]
      );
    } else {
      Alert.alert(
        '❌ Proof Rejected',
        response.reasoning,
        [{ text: 'Retake Photo', onPress: captureProof }]
      );
    }
  };

  return (
    <View>
      {!photoUri ? (
        <View style={styles.captureView}>
          <Icon name="camera" size={100} color="gray" />
          <Text style={styles.hint}>
            Make sure you're at the task location
          </Text>
          <Button onPress={captureProof}>
            Take Proof Photo
          </Button>

          {gpsData && (
            <View style={styles.gpsStatus}>
              <Icon name="map-pin" color="green" />
              <Text>GPS: ±{gpsData.accuracy.toFixed(1)}m</Text>
            </View>
          )}
        </View>
      ) : (
        <View style={styles.previewView}>
          <Image source={{ uri: photoUri }} style={styles.preview} />

          <View style={styles.metadata}>
            <Text>GPS Accuracy: ±{gpsData.accuracy.toFixed(1)}m</Text>
            <Text>Captured: {new Date(gpsData.timestamp).toLocaleTimeString()}</Text>
          </View>

          <Button
            onPress={handleSubmit}
            loading={uploading}
            disabled={uploading}
          >
            {uploading ? 'Validating...' : 'Submit Proof'}
          </Button>

          <Button
            variant="outline"
            onPress={() => setPhotoUri(null)}
          >
            Retake
          </Button>
        </View>
      )}
    </View>
  );
}
```

3. **Add Validation Feedback Components**
```typescript
// components/ValidationFeedback.tsx
export function ValidationFeedback({ recommendation, reasoning, flags, scores, riskLevel }) {
  const getFeedbackStyle = () => {
    switch (recommendation) {
      case 'approve': return styles.approve;
      case 'manual_review': return styles.review;
      case 'reject': return styles.reject;
    }
  };

  return (
    <Card style={getFeedbackStyle()}>
      <View style={styles.header}>
        <Icon name={getIcon(recommendation)} />
        <Text style={styles.title}>{getTitle(recommendation)}</Text>
      </View>

      <Text style={styles.reasoning}>{reasoning}</Text>

      {flags.length > 0 && (
        <View style={styles.flags}>
          {flags.map(flag => (
            <Chip key={flag} variant="warning">{flag}</Chip>
          ))}
        </View>
      )}

      {scores && (
        <View style={styles.scores}>
          <ScoreBar label="Liveness" value={scores.liveness} threshold={70} />
          <ScoreBar label="Deepfake" value={scores.deepfake} threshold={80} inverted />
          <ScoreBar label="GPS Proximity" value={scores.gps_proximity} threshold={80} />
        </View>
      )}

      <RiskBadge level={riskLevel} />
    </Card>
  );
}
```

**Testing Checklist:**
- [ ] GPS captured before photo
- [ ] Location accuracy displayed in UI
- [ ] iOS LiDAR depth data captured when available
- [ ] Photo upload to R2 works
- [ ] Validation response handled correctly
- [ ] Approve/Review/Reject states show proper UI
- [ ] Risk flags displayed as chips
- [ ] Score bars animate correctly

---

### Feature 4: Insurance Claims 🛡️

**User Story:**
"As a hustler, I can file insurance claims for tasks where I got scammed or the client disappeared."

**Affected Screens:**
1. **Profile/Wallet Screen** (NEW: Insurance section)
2. **Task Detail Screen** (NEW: "File Claim" button)
3. **Claims History Screen** (NEW)
4. **Claim Detail Screen** (NEW)

**Implementation Steps:**

1. **Add Insurance Card to Profile**
```typescript
// screens/Profile.tsx
export function ProfileScreen() {
  const poolStatus = trpc.insurance.getPoolStatus.useQuery();
  const myClaims = trpc.insurance.getMyClaims.useQuery();

  return (
    <View>
      <InsurancePoolCard
        poolBalance={poolStatus.data?.pool_balance_cents}
        myContributions={/* Calculate from tasks */}
        activeClaims={poolStatus.data?.active_claims_count}
        onViewClaimsPress={() => navigation.navigate('ClaimsHistory')}
        onFileClaimPress={() => navigation.navigate('FileClaim')}
      />
    </View>
  );
}
```

2. **Create File Claim Screen**
```typescript
// screens/FileClaimScreen.tsx
export function FileClaimScreen({ route }) {
  const { taskId } = route.params;  // Pre-filled from task detail
  const [description, setDescription] = useState('');
  const [requestedAmount, setRequestedAmount] = useState('');

  const fileClaim = trpc.insurance.fileClaim.useMutation();
  const tasks = trpc.task.getMyCompletedTasks.useQuery();

  const handleSubmit = async () => {
    if (!description || !requestedAmount) {
      Alert.alert('Missing Fields', 'Please fill out all fields');
      return;
    }

    const amountCents = parseFloat(requestedAmount) * 100;

    if (amountCents > 500000) {  // $5000 max
      Alert.alert('Amount Too High', 'Maximum claim amount is $5,000');
      return;
    }

    try {
      await fileClaim.mutateAsync({
        task_id: taskId,
        incident_description: description,
        requested_amount_cents: amountCents
      });

      Alert.alert(
        'Claim Filed',
        'Your claim has been submitted for review. You\'ll be notified within 3-5 business days.',
        [{ text: 'OK', onPress: () => navigation.goBack() }]
      );
    } catch (error) {
      Alert.alert('Submission Failed', error.message);
    }
  };

  return (
    <ScrollView>
      <Text style={styles.title}>File Insurance Claim</Text>

      <Select
        label="Task"
        value={taskId}
        onChange={setTaskId}
        options={tasks.data?.map(t => ({
          label: t.title,
          value: t.id
        }))}
      />

      <TextInput
        label="What happened?"
        value={description}
        onChangeText={setDescription}
        multiline
        numberOfLines={5}
        maxLength={500}
        placeholder="Describe the incident..."
      />
      <Text style={styles.hint}>
        {description.length}/500 characters
      </Text>

      <TextInput
        label="Claim Amount"
        value={requestedAmount}
        onChangeText={setRequestedAmount}
        keyboardType="decimal-pad"
        leftElement={<Text>$</Text>}
        placeholder="0.00"
      />
      <Text style={styles.hint}>
        Maximum: $5,000 (80% coverage)
      </Text>

      <View style={styles.footer}>
        <Text style={styles.disclaimer}>
          Claims are reviewed by our team within 3-5 business days.
          Approved claims are paid via Stripe Connect.
        </Text>

        <Button
          onPress={handleSubmit}
          loading={fileClaim.isLoading}
          disabled={fileClaim.isLoading}
        >
          Submit Claim
        </Button>
      </View>
    </ScrollView>
  );
}
```

3. **Create Claims History Screen**
```typescript
// screens/ClaimsHistoryScreen.tsx
export function ClaimsHistoryScreen() {
  const { data: claims } = trpc.insurance.getMyClaims.useQuery();

  const getStatusColor = (status) => {
    switch (status) {
      case 'filed': return 'gray';
      case 'under_review': return 'orange';
      case 'approved': return 'green';
      case 'denied': return 'red';
      case 'paid': return 'blue';
    }
  };

  return (
    <FlatList
      data={claims}
      keyExtractor={item => item.id}
      renderItem={({ item }) => (
        <ClaimCard
          claim={item}
          onPress={() => navigation.navigate('ClaimDetail', { claimId: item.id })}
        />
      )}
      ListEmptyComponent={
        <EmptyState
          icon="shield"
          title="No Claims Filed"
          subtitle="File a claim if you encounter issues with a task"
          action={{
            label: 'File Claim',
            onPress: () => navigation.navigate('FileClaim')
          }}
        />
      }
    />
  );
}

function ClaimCard({ claim, onPress }) {
  return (
    <TouchableOpacity onPress={onPress}>
      <Card>
        <View style={styles.header}>
          <Text style={styles.taskTitle}>{claim.task.title}</Text>
          <Badge color={getStatusColor(claim.status)}>
            {claim.status.replace('_', ' ')}
          </Badge>
        </View>

        <Text style={styles.amount}>
          ${(claim.requested_amount_cents / 100).toFixed(2)}
        </Text>

        <Text style={styles.description} numberOfLines={2}>
          {claim.incident_description}
        </Text>

        <Text style={styles.date}>
          Filed {formatDate(claim.filed_at)}
        </Text>

        {claim.status === 'approved' && (
          <Text style={styles.approved}>
            ✅ Approved: ${(claim.approved_amount_cents / 100).toFixed(2)}
          </Text>
        )}
      </Card>
    </TouchableOpacity>
  );
}
```

4. **Add "File Claim" Button to Task Detail**
```typescript
// screens/TaskDetailScreen.tsx
export function TaskDetailScreen({ route }) {
  const { taskId } = route.params;
  const task = trpc.task.getById.useQuery({ id: taskId });

  const canFileClaim = task.data?.state === 'COMPLETED'
    && task.data?.worker_id === currentUserId
    && !task.data?.has_active_claim;  // Backend flag

  return (
    <View>
      {/* Existing task detail UI */}

      {canFileClaim && (
        <Button
          variant="outline"
          leftIcon="shield"
          onPress={() => navigation.navigate('FileClaim', { taskId })}
        >
          File Insurance Claim
        </Button>
      )}
    </View>
  );
}
```

**Testing Checklist:**
- [ ] Insurance card shows pool balance on profile
- [ ] File claim form validates input (max $5000, description required)
- [ ] Claims history shows all filed claims
- [ ] Status badges use correct colors
- [ ] Claim detail screen shows reviewer notes
- [ ] "File Claim" button only shows for eligible tasks

---

### Feature 5: AI-Suggested Pricing 🤖

**User Story:**
"As a poster, I can get AI-suggested pricing for my task if I'm unsure what to charge."

**Affected Screens:**
1. **Create Task Screen** (ENHANCED: AI pricing toggle)
2. **Task Preview Screen** (NEW: AI badge)

**Implementation Steps:**

1. **Add AI Pricing Toggle to Create Task**
```typescript
// screens/CreateTaskScreen.tsx
export function CreateTaskScreen() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('');
  const [price, setPrice] = useState('');
  const [useAIPricing, setUseAIPricing] = useState(false);
  const [aiSuggestion, setAiSuggestion] = useState(null);

  const createTask = trpc.task.create.useMutation();

  const handleSubmit = async () => {
    const priceCents = useAIPricing ? 0 : parseFloat(price) * 100;

    try {
      const result = await createTask.mutateAsync({
        title,
        description,
        category,
        price: priceCents,  // 0 triggers AI
        // ... other fields
      });

      if (result.task.ai_suggested_price) {
        // Show AI suggestion modal
        setAiSuggestion({
          suggested: result.task.price,
          xp: result.task.xp_reward
        });
      } else {
        // Normal flow
        navigation.goBack();
      }
    } catch (error) {
      Alert.alert('Error', error.message);
    }
  };

  return (
    <ScrollView>
      <TextInput label="Task Title" value={title} onChangeText={setTitle} />
      <TextInput label="Description" value={description} onChangeText={setDescription} multiline />
      <Select label="Category" value={category} onChange={setCategory} />

      {/* AI Pricing Toggle */}
      <View style={styles.pricingSection}>
        <Text style={styles.label}>Pricing</Text>

        <Switch
          label="Let AI suggest a price"
          value={useAIPricing}
          onValueChange={setUseAIPricing}
        />

        {useAIPricing ? (
          <View style={styles.aiHint}>
            <Icon name="sparkles" color="purple" />
            <Text style={styles.hintText}>
              Our AI will analyze your task and suggest a fair price
            </Text>
          </View>
        ) : (
          <TextInput
            label="Price"
            value={price}
            onChangeText={setPrice}
            keyboardType="decimal-pad"
            leftElement={<Text>$</Text>}
            placeholder="0.00"
          />
        )}
      </View>

      <Button onPress={handleSubmit} loading={createTask.isLoading}>
        {useAIPricing ? 'Get AI Suggestion' : 'Create Task'}
      </Button>

      {/* AI Suggestion Modal */}
      <AIPricingSuggestionModal
        visible={!!aiSuggestion}
        suggestion={aiSuggestion}
        onAccept={() => {
          setAiSuggestion(null);
          navigation.goBack();
        }}
        onEdit={() => {
          setUseAIPricing(false);
          setPrice((aiSuggestion.suggested / 100).toFixed(2));
          setAiSuggestion(null);
        }}
      />
    </ScrollView>
  );
}
```

2. **Create AI Suggestion Modal**
```typescript
// components/AIPricingSuggestionModal.tsx
export function AIPricingSuggestionModal({ visible, suggestion, onAccept, onEdit }) {
  if (!suggestion) return null;

  return (
    <Modal visible={visible} animationType="slide">
      <View style={styles.container}>
        <Icon name="sparkles" size={60} color="purple" />

        <Text style={styles.title}>AI Price Suggestion</Text>

        <View style={styles.priceCard}>
          <Text style={styles.price}>
            ${(suggestion.suggested / 100).toFixed(2)}
          </Text>
          <Text style={styles.xp}>
            {suggestion.xp} XP for hustlers
          </Text>
        </View>

        <View style={styles.rationale}>
          <Text style={styles.rationaleTitle}>Why this price?</Text>
          <Text style={styles.rationaleText}>
            • Based on similar tasks in your category
            {'\n'}• Accounts for task difficulty (medium)
            {'\n'}• Competitive rate for your area
          </Text>
        </View>

        <Button onPress={onAccept}>
          Accept Suggestion
        </Button>

        <Button variant="outline" onPress={onEdit}>
          Edit Price
        </Button>
      </View>
    </Modal>
  );
}
```

3. **Add AI Badge to Task Cards**
```typescript
// components/TaskCard.tsx
export function TaskCard({ task }) {
  return (
    <Card>
      <View style={styles.header}>
        <Text style={styles.title}>{task.title}</Text>
        {task.ai_suggested_price && (
          <Badge color="purple" leftIcon="sparkles">
            AI Priced
          </Badge>
        )}
      </View>

      <Text style={styles.price}>${(task.price / 100).toFixed(2)}</Text>
      <Text style={styles.xp}>{task.xp_reward} XP</Text>

      {/* ... rest of task card */}
    </Card>
  );
}
```

**Testing Checklist:**
- [ ] Toggle switches between manual and AI pricing
- [ ] Hint text shows when AI enabled
- [ ] Loading spinner shows during AI analysis
- [ ] Suggestion modal displays AI price + XP
- [ ] User can accept or edit AI suggestion
- [ ] AI badge shows on task cards

---

## 🎨 Design System Updates

### New Components Needed

1. **TaxBalanceCard** - Warning card for unpaid taxes
2. **VerificationUnlockCard** - Circular progress with unlock status
3. **ValidationFeedback** - Biometric/GPS validation results
4. **ScoreBar** - Visual score display (0-100)
5. **RiskBadge** - Color-coded risk level indicator
6. **ClaimCard** - Insurance claim list item
7. **AIPricingSuggestionModal** - AI pricing results

### Design Tokens

```typescript
// tokens/colors.ts
export const colors = {
  // ... existing colors

  // v1.8.0 additions
  ai: {
    purple: '#8B5CF6',
    gradient: ['#8B5CF6', '#6366F1']
  },
  risk: {
    low: '#10B981',
    medium: '#F59E0B',
    high: '#EF4444',
    critical: '#DC2626'
  },
  insurance: {
    pool: '#3B82F6',
    claim: '#8B5CF6'
  }
};
```

---

## 🔧 Technical Implementation Notes

### 1. GPS Permissions Handling

```typescript
// utils/permissions.ts
export async function requestLocationPermission() {
  const { status } = await Location.requestForegroundPermissionsAsync();

  if (status !== 'granted') {
    Alert.alert(
      'Location Required',
      'HustleXP needs your location to validate proof submissions and prevent fraud.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Settings', onPress: () => Linking.openSettings() }
      ]
    );
    return false;
  }

  return true;
}
```

### 2. R2 Upload Helper

```typescript
// utils/uploadToR2.ts
export async function uploadToR2(fileUri: string): Promise<string> {
  const formData = new FormData();
  formData.append('file', {
    uri: fileUri,
    type: 'image/jpeg',
    name: `proof_${Date.now()}.jpg`
  });

  const response = await fetch(`${API_URL}/upload/proof`, {
    method: 'POST',
    body: formData,
    headers: {
      'Authorization': `Bearer ${authToken}`
    }
  });

  const { url } = await response.json();
  return url;
}
```

### 3. Stripe Payment Integration

```typescript
// utils/stripe.ts
import { useStripe } from '@stripe/stripe-react-native';

export function usePayTax() {
  const stripe = useStripe();
  const payTax = trpc.xpTax.payTax.useMutation();

  const handlePayment = async (amountCents: number) => {
    // 1. Create PaymentIntent on backend
    const { clientSecret, paymentIntentId } = await createTaxPaymentIntent(amountCents);

    // 2. Present payment sheet
    const { error } = await stripe.presentPaymentSheet({
      clientSecret,
      merchantDisplayName: 'HustleXP',
      applePay: { merchantCountryCode: 'US' },
      googlePay: { merchantCountryCode: 'US', testEnv: __DEV__ }
    });

    if (error) {
      throw new Error(error.message);
    }

    // 3. Confirm payment with backend
    const result = await payTax.mutateAsync({
      stripe_payment_intent_id: paymentIntentId
    });

    return result;
  };

  return { handlePayment };
}
```

---

## 📱 Screen Flow Diagrams

### Tax Payment Flow
```
Profile Screen
  └─> TaxBalanceCard (if unpaid)
      └─> [Pay Now] → TaxPaymentScreen
          └─> Stripe Payment Sheet
              └─> Success → XP Unlocked Toast
              └─> Error → Retry
```

### Verification Unlock Flow
```
Profile Screen
  └─> VerificationUnlockCard
      ├─> Not Unlocked (0-99%)
      │   └─> Complete more tasks
      └─> Unlocked (100%)
          └─> [Submit Verification] → VerificationSubmissionScreen
              ├─> Eligible → Form
              └─> Not Eligible → Locked State
```

### Biometric Proof Flow
```
TaskDetailScreen (Worker View)
  └─> [Submit Proof] → ProofSubmissionScreen
      └─> Request GPS Permission
          └─> [Take Photo] → Camera
              └─> Capture GPS + Photo
                  └─> Upload to R2
                      └─> Submit to Backend
                          ├─> Approve → Success Toast
                          ├─> Manual Review → Warning Alert
                          └─> Reject → Retake Flow
```

### Insurance Claim Flow
```
Profile Screen
  └─> InsurancePoolCard
      └─> [File Claim] → FileClaimScreen
          └─> Select Task
              └─> Enter Description
                  └─> Enter Amount
                      └─> Submit → ClaimsHistoryScreen
                          └─> Claim Card → ClaimDetailScreen
                              ├─> Under Review (yellow)
                              ├─> Approved (green)
                              ├─> Denied (red)
                              └─> Paid (blue)
```

---

## ✅ Testing Strategy

### Unit Tests

```typescript
// __tests__/components/TaxBalanceCard.test.tsx
describe('TaxBalanceCard', () => {
  it('displays unpaid amount correctly', () => {
    render(<TaxBalanceCard unpaidAmount={1500} xpHeld={150} />);
    expect(screen.getByText('$15.00')).toBeInTheDocument();
  });

  it('calls onPayPress when Pay Now clicked', () => {
    const onPayPress = jest.fn();
    render(<TaxBalanceCard onPayPress={onPayPress} />);
    fireEvent.press(screen.getByText('Pay Now'));
    expect(onPayPress).toHaveBeenCalled();
  });
});
```

### Integration Tests

```typescript
// __tests__/flows/taxPayment.test.tsx
describe('Tax Payment Flow', () => {
  it('completes full payment flow', async () => {
    // 1. Mock unpaid tax status
    mockTrpcQuery('xpTax.getTaxStatus', {
      unpaid_tax_cents: 1000,
      xp_held_back: 100,
      blocked: true
    });

    // 2. Render profile
    const { getByText } = render(<ProfileScreen />);

    // 3. Click Pay Now
    fireEvent.press(getByText('Pay Now'));

    // 4. Mock Stripe success
    mockStripePayment({ success: true, paymentIntentId: 'pi_test' });

    // 5. Verify XP released
    await waitFor(() => {
      expect(getByText(/unlocked 100 XP/i)).toBeVisible();
    });
  });
});
```

### E2E Tests (Maestro)

```yaml
# e2e/taxPayment.yaml
appId: com.hustlexp.app
---
- launchApp
- tapOn: "Profile"
- assertVisible: "Unpaid Tax Balance"
- tapOn: "Pay Now"
- tapOn: "Pay with Card"
- inputText: "4242424242424242"  # Test card
- tapOn: "Submit Payment"
- assertVisible: "Tax Paid!"
- assertVisible: "You've unlocked 100 XP"
```

---

## 📚 Additional Resources

### Backend Documentation
- **API Contract:** `specs/04-backend/API_CONTRACT.md`
- **Schema:** `specs/02-architecture/schema.sql` (v1.8.0)
- **Changelog:** `CHANGELOG_v1.8.0.md`

### Subsystem Specs
- **Scoper AI:** `specs/02-architecture/subsystems/SCOPER_AGENT_SPEC_LOCKED.md`
- **Logistics AI:** `specs/02-architecture/subsystems/LOGISTICS_AGENT_SPEC_LOCKED.md`
- **XP Tax:** `specs/02-architecture/subsystems/XP_TAX_SYSTEM_SPEC_LOCKED.md`
- **Verification Unlock:** `specs/02-architecture/subsystems/EARNED_VERIFICATION_UNLOCK_SPEC_LOCKED.md`

### Backend Commits Reference
1. Phase 1: `60d02c1` - Documentation specs
2. Phase 2: `bfb0dd6e` - Database migrations
3. Phase 3a: `f29bbbe2` - Core services
4. Phase 3b: `0bb4557e` - AI/biometric services
5. Phase 4: `bc5b3969` - tRPC routers
6. Phase 5: `55fbe908` - Background workers
7. Phase 6: `47489096` - Service integrations

---

## 🚨 Common Pitfalls to Avoid

1. **Don't submit proof without GPS** - Always capture location first
2. **Don't bypass permission checks** - Request camera/location upfront
3. **Don't assume XP is awarded** - Check for tax blocks (HX201 error)
4. **Don't hardcode payment amounts** - Always use cents (multiply by 100)
5. **Don't skip validation feedback** - Always show biometric/GPS results
6. **Don't cache tax status** - Refetch after task completion
7. **Don't forget loading states** - AI pricing takes 2-3 seconds

---

## 🎯 Success Criteria

### Must-Have (P0)
- [ ] XP tax balance shown on profile
- [ ] Stripe payment flow for tax payment
- [ ] Verification unlock progress visible
- [ ] GPS + photo captured for proofs
- [ ] Biometric validation feedback shown

### Should-Have (P1)
- [ ] Insurance claims filing workflow
- [ ] AI pricing suggestions
- [ ] Tax payment history
- [ ] Verification earnings ledger
- [ ] Risk badges on proof review

### Nice-to-Have (P2)
- [ ] LiDAR depth map capture (iOS)
- [ ] Fraud detection alerts
- [ ] Insurance pool balance chart
- [ ] AI pricing rationale explanation
- [ ] Tax payment reminders (push notifications)

---

## 📞 Support Contacts

**Backend Team Lead:** Claude Sonnet 4.5
**Backend Repo:** https://github.com/Sebdysart/hustlexp-ai-backend
**Docs Repo:** https://github.com/Sebdysart/HUSTLEXP-DOCS
**API Base URL:** `https://api.hustlexp.com` (TBD)

**Questions?**
- Refer to `CHANGELOG_v1.8.0.md` for detailed implementation notes
- Check subsystem specs in `specs/02-architecture/subsystems/`
- Review backend commit history for examples

---

**Last Updated:** 2026-02-06
**Version:** 1.8.0
**Status:** Production-Ready ✅
