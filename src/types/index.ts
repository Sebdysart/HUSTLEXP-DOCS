/**
 * HustleXP TypeScript Type Definitions
 *
 * AUTHORITY: API_CONTRACT.md, PRODUCT_SPEC.md, FRONTEND_ARCHITECTURE.md
 * STATUS: Constitutional Reference
 *
 * These types are the single source of truth for all data shapes.
 * Cursor MUST use these types — do not invent or guess types.
 */

// =============================================================================
// ENUMS
// =============================================================================

export type TaskState =
  | 'OPEN'
  | 'ACCEPTED'
  | 'PROOF_SUBMITTED'
  | 'DISPUTED'
  | 'COMPLETED'
  | 'CANCELLED'
  | 'EXPIRED';

export type EscrowState =
  | 'PENDING'
  | 'FUNDED'
  | 'LOCKED_DISPUTE'
  | 'RELEASED'
  | 'REFUNDED'
  | 'REFUND_PARTIAL';

export type ProofState =
  | 'PENDING'
  | 'SUBMITTED'
  | 'ACCEPTED'
  | 'REJECTED'
  | 'EXPIRED';

export type OnboardingPhase =
  | 'NOT_STARTED'
  | 'ROLE_SELECTION'
  | 'PROFILE_SETUP'
  | 'CAPABILITY_CLAIMS'
  | 'TUTORIAL'
  | 'COMPLETED';

export type UserRole = 'worker' | 'poster';

export type TrustTier = 1 | 2 | 3 | 4;

export type TaskMode = 'STANDARD' | 'LIVE';

export type LiveModeState = 'OFF' | 'ACTIVE' | 'COOLDOWN' | 'PAUSED';

export type DisputeReason =
  | 'PROOF_INSUFFICIENT'
  | 'WORK_NOT_DONE'
  | 'QUALITY_ISSUE'
  | 'OTHER';

export type DisputeResolution = 'HUSTLER_WINS' | 'CLIENT_WINS' | 'SPLIT';

export type DisputeState =
  | 'OPEN'
  | 'EVIDENCE_REQUESTED'
  | 'ESCALATED'
  | 'RESOLVED';

export type NotificationType =
  | 'TASK_CREATED'
  | 'TASK_ACCEPTED'
  | 'TASK_WORKER_ASSIGNED'
  | 'TASK_CANCELLED'
  | 'TASK_EXPIRED'
  | 'PROOF_SUBMITTED'
  | 'PROOF_ACCEPTED'
  | 'PROOF_REJECTED'
  | 'DISPUTE_OPENED'
  | 'DISPUTE_RESOLVED'
  | 'XP_EARNED'
  | 'LEVEL_UP'
  | 'BADGE_EARNED'
  | 'ESCROW_FUNDED'
  | 'ESCROW_RELEASED'
  | 'ESCROW_REFUNDED'
  | 'TRUST_TIER_UP'
  | 'TRUST_TIER_DOWN'
  | 'LIVE_TASK_MATCH'
  | 'NEW_MESSAGE'
  | 'SYSTEM_ANNOUNCEMENT';

export type NotificationPriority = 'HIGH' | 'NORMAL' | 'LOW';

export type MessageType = 'TEXT' | 'PHOTO' | 'LOCATION' | 'AUTO_STATUS' | 'SYSTEM';

export type BadgeRarity = 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';

export type BadgeCategory = 'achievement' | 'milestone' | 'special' | 'seasonal';

export type EligibilityBlockerType =
  | 'TRUST_TIER'
  | 'LICENSE'
  | 'INSURANCE'
  | 'BACKGROUND'
  | 'LOCATION'
  | 'VERIFICATION';

export type VerificationStatus =
  | 'pending'
  | 'processing'
  | 'verified'
  | 'failed'
  | 'expired';

export type BackgroundCheckStatus =
  | 'NOT_STARTED'
  | 'PENDING'
  | 'APPROVED'
  | 'REJECTED'
  | 'EXPIRED';

export type InsuranceStatus =
  | 'NOT_UPLOADED'
  | 'PENDING'
  | 'VERIFIED'
  | 'EXPIRED';

export type RiskClearance = 'low' | 'medium' | 'high';

// =============================================================================
// CORE ENTITIES
// =============================================================================

export interface UserSummary {
  id: string;
  full_name: string;
  avatar_url: string | null;
  trust_tier: TrustTier;
  is_verified: boolean;
}

export interface UserProfile {
  id: string;
  email: string;
  phone: string | null;
  full_name: string;
  avatar_url: string | null;
  default_mode: UserRole;
  trust_tier: TrustTier;
  xp_total: number;
  current_level: number;
  current_streak: number;
  is_verified: boolean;
  verified_at: string | null;
  onboarding_completed_at: string | null;
  created_at: string;
}

export interface Task {
  id: string;
  poster_id: string;
  worker_id: string | null;
  title: string;
  description: string;
  requirements: string | null;
  location: string;
  location_lat: number | null;
  location_lng: number | null;
  category: string;
  price: number; // USD cents
  state: TaskState;
  mode: TaskMode;
  deadline: string; // ISO 8601
  requires_proof: boolean;
  proof_instructions: string | null;
  accepted_at: string | null;
  proof_submitted_at: string | null;
  completed_at: string | null;
  cancelled_at: string | null;
  created_at: string;
  updated_at: string;
  // Expanded relations
  poster: UserSummary;
  worker: UserSummary | null;
  escrow: EscrowSummary | null;
  proof: ProofSummary | null;
}

export interface TaskSummary {
  id: string;
  title: string;
  category: string;
  price: number;
  state: TaskState;
  mode: TaskMode;
  location: string;
  deadline: string;
  poster: UserSummary;
  created_at: string;
}

export interface Escrow {
  id: string;
  task_id: string;
  amount: number;
  state: EscrowState;
  stripe_payment_intent_id: string;
  stripe_transfer_id: string | null;
  stripe_refund_id: string | null;
  funded_at: string | null;
  released_at: string | null;
  refunded_at: string | null;
  created_at: string;
}

export interface EscrowSummary {
  id: string;
  amount: number;
  state: EscrowState;
}

export interface Proof {
  id: string;
  task_id: string;
  submitter_id: string;
  state: ProofState;
  description: string | null;
  photos: ProofPhoto[];
  submitted_at: string | null;
  reviewed_by: string | null;
  reviewed_at: string | null;
  rejection_reason: string | null;
}

export interface ProofSummary {
  id: string;
  state: ProofState;
  submitted_at: string | null;
}

export interface ProofPhoto {
  id: string;
  proof_id: string;
  storage_key: string;
  content_type: string;
  file_size_bytes: number;
  sequence_number: number;
  capture_time?: string;
  created_at: string;
}

// =============================================================================
// ELIGIBILITY
// =============================================================================

export interface EligibilityBlocker {
  type: EligibilityBlockerType;
  requirement: string;
  message: string;
}

export interface EligibilityResult {
  eligible: boolean;
  blockers: EligibilityBlocker[];
}

export interface CapabilityProfile {
  user_id: string;
  profile_id: string;
  trust_tier: TrustTier;
  trust_tier_updated_at: string;
  risk_clearance: RiskClearance[];
  insurance_valid: boolean;
  insurance_expires_at?: string;
  background_check_valid: boolean;
  background_check_expires_at?: string;
  location_state: string;
  location_city?: string;
  willingness_flags: WillingnessFlags;
  verification_status: Record<string, boolean>;
  derived_at: string;
}

export interface WillingnessFlags {
  in_home_work: boolean;
  high_risk_tasks: boolean;
  urgent_jobs: boolean;
}

// =============================================================================
// GAMIFICATION
// =============================================================================

export interface XPSummary {
  total_xp: number;
  current_level: number;
  current_streak: number;
  level_progress: LevelProgress;
  recent_entries: XPLedgerEntry[];
}

export interface LevelProgress {
  current_threshold: number;
  next_threshold: number;
  progress_percent: number;
}

export interface XPLedgerEntry {
  id: string;
  user_id: string;
  task_id?: string;
  amount: number;
  reason: string;
  decay_factor: number;
  effective_amount: number;
  balance_after: number;
  created_at: string;
}

export interface Badge {
  id: string;
  slug: string;
  name: string;
  description: string;
  icon_url: string;
  category: BadgeCategory;
  rarity: BadgeRarity;
  earned_at: string;
}

export interface BadgeDefinition {
  id: string;
  slug: string;
  name: string;
  description: string;
  icon_url: string;
  category: BadgeCategory;
  rarity: BadgeRarity;
}

export interface TrustTierInfo {
  current_tier: TrustTier;
  tier_name: string;
  next_tier: TrustTier | null;
  requirements_for_next: TrustTierRequirements | null;
  tier_benefits: string[];
}

export interface TrustTierRequirements {
  tasks_completed: { required: number; current: number };
  approval_rate: { required: number; current: number };
  avg_rating: { required: number; current: number };
}

// =============================================================================
// MESSAGING
// =============================================================================

export interface Message {
  id: string;
  task_id: string;
  sender_id: string;
  message_type: MessageType;
  content: string;
  photo_url?: string;
  location?: GeoLocation;
  read_at: string | null;
  created_at: string;
}

export interface GeoLocation {
  lat: number;
  lng: number;
}

// =============================================================================
// NOTIFICATIONS
// =============================================================================

export interface Notification {
  id: string;
  user_id: string;
  type: NotificationType;
  title: string;
  body: string;
  priority: NotificationPriority;
  task_id?: string;
  badge_id?: string;
  read: boolean;
  created_at: string;
}

export interface NotificationPreferences {
  push_enabled: boolean;
  email_enabled: boolean;
  sms_enabled: boolean;
  quiet_hours: QuietHours;
  categories: NotificationCategories;
}

export interface QuietHours {
  enabled: boolean;
  start: string; // "22:00"
  end: string;   // "08:00"
}

export interface NotificationCategories {
  task_updates: boolean;
  messages: boolean;
  xp_badges: boolean;
  marketing: boolean;
}

// =============================================================================
// DISPUTES
// =============================================================================

export interface Dispute {
  id: string;
  task_id: string;
  opened_by: string;
  reason: DisputeReason;
  description: string;
  evidence: Evidence[];
  state: DisputeState;
  resolution: DisputeResolution | null;
  resolved_by: string | null;
  resolved_at: string | null;
  created_at: string;
}

export interface DisputeSummary {
  id: string;
  task_id: string;
  status: string;
  opened_by: UserRole;
  reason: string;
  created_at: string;
  resolved_at?: string;
  resolution_notes?: string;
}

export interface Evidence {
  id: string;
  dispute_id: string;
  submitted_by: string;
  evidence_type: 'PHOTO' | 'MESSAGE' | 'LOCATION' | 'DOCUMENT';
  storage_key: string;
  description?: string;
  created_at: string;
}

// =============================================================================
// RATINGS
// =============================================================================

export interface Rating {
  id: string;
  task_id: string;
  rater_id: string;
  ratee_id: string;
  stars: number; // 1-5
  comment: string | null;
  tags: string[];
  created_at: string;
}

export interface RatingAggregate {
  average_stars: number;
  total_ratings: number;
  star_distribution: {
    '1': number;
    '2': number;
    '3': number;
    '4': number;
    '5': number;
  };
  common_tags: { tag: string; count: number }[];
}

// =============================================================================
// LIVE MODE
// =============================================================================

export interface LiveModeSession {
  id: string;
  started_at: string;
  location: GeoLocation;
  radius_miles: number;
  tasks_accepted: number;
  earnings_cents: number;
}

export interface LiveModeStatus {
  state: LiveModeState;
  session: LiveModeSession | null;
  cooldown_ends_at: string | null;
  ban_ends_at: string | null;
  stats_today: LiveModeStats;
}

export interface LiveModeStats {
  sessions: number;
  total_minutes: number;
  tasks_completed: number;
  earnings_cents: number;
}

export interface LiveTaskBroadcast {
  broadcast_id: string;
  task: {
    id: string;
    title: string;
    description: string;
    price: number;
    location: string;
    distance_miles: number;
    deadline: string;
    xp_multiplier: number;
  };
  expires_at: string;
  poster: UserSummary;
}

// =============================================================================
// ONBOARDING
// =============================================================================

export interface OnboardingProgress {
  phase: OnboardingPhase;
  completed_steps: string[];
  next_step: string | null;
  role: UserRole | null;
  profile_percent_complete: number;
  started_at: string | null;
  completed_at: string | null;
}

export interface CalibrationAnswer {
  question_id: string;
  answer: string;
}

export interface CapabilityClaims {
  claimed_trades: string[];
  license_claims: LicenseClaim[];
  insurance_claimed: boolean;
  work_state: string;
  work_region?: string;
  risk_preferences: WillingnessFlags;
}

export interface LicenseClaim {
  trade: string;
  state: string;
  license_number: string;
}

// =============================================================================
// VERIFICATION
// =============================================================================

export interface LicenseVerification {
  id: string;
  trade: string;
  state: string;
  status: VerificationStatus;
  verified_at: string | null;
  expires_at: string | null;
  failure_reason: string | null;
}

export interface InsuranceVerification {
  id: string;
  trade: string;
  status: VerificationStatus;
  coverage_amount: number;
  verified_at: string | null;
  expires_at: string | null;
}

export interface BackgroundCheck {
  id: string;
  status: VerificationStatus;
  provider: string;
  verified_at: string | null;
  expires_at: string | null;
}

export interface VerificationStatusSummary {
  licenses: LicenseVerification[];
  insurance: InsuranceVerification[];
  background_check: BackgroundCheck | null;
}

// =============================================================================
// TASK FEED
// =============================================================================

export interface FeedTask {
  id: string;
  title: string;
  description: string;
  category: string;
  price: number;
  location: string;
  distance_miles: number | null;
  deadline: string;
  mode: TaskMode;
  poster: UserSummary;
  matching_score: number;
  eligibility: EligibilityResult;
  created_at: string;
}

export interface TaskFeedResponse {
  tasks: FeedTask[];
  pagination: CursorPagination;
  feed_metadata: FeedMetadata;
}

export interface CursorPagination {
  next_cursor: string | null;
  has_more: boolean;
  total_estimate: number;
}

export interface FeedMetadata {
  location_used: GeoLocation | null;
  radius_miles: number;
  applied_filters: string[];
  personalization_factors: string[];
}

export interface MatchingScore {
  overall_score: number;
  components: {
    distance_score: number;
    price_attractiveness: number;
    category_match: number;
    poster_rating: number;
    urgency_fit: number;
    trust_compatibility: number;
  };
  eligibility: {
    eligible: boolean;
    checks: {
      name: string;
      passed: boolean;
      requirement?: string;
    }[];
  };
}

// =============================================================================
// API PAGINATION (Standard List Endpoints)
// =============================================================================

export interface OffsetPagination {
  limit: number;
  offset: number;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  has_more: boolean;
}

// =============================================================================
// COMPONENT PROPS
// =============================================================================

export interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
  fullWidth?: boolean;
  accessibilityLabel?: string;
  style?: object;
  textStyle?: object;
}

export interface CardProps {
  children: React.ReactNode;
  variant?: 'elevated' | 'outlined' | 'filled';
  padding?: number;
  onPress?: () => void;
  style?: object;
}

export interface HXTextProps {
  children: React.ReactNode;
  variant?: 'h1' | 'h2' | 'h3' | 'h4' | 'body' | 'bodySmall' | 'caption' | 'label';
  color?: 'primary' | 'secondary' | 'tertiary' | 'inverse' | 'error';
  weight?: 'normal' | 'medium' | 'semibold' | 'bold';
  align?: 'left' | 'center' | 'right';
  style?: object;
}

export interface InputProps {
  label?: string;
  error?: string;
  hint?: string;
  containerStyle?: object;
  // Extends React Native TextInputProps
  value?: string;
  onChangeText?: (text: string) => void;
  placeholder?: string;
  secureTextEntry?: boolean;
  keyboardType?: 'default' | 'email-address' | 'numeric' | 'phone-pad';
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  autoComplete?: string;
  autoFocus?: boolean;
  editable?: boolean;
  maxLength?: number;
  multiline?: boolean;
  numberOfLines?: number;
  onBlur?: () => void;
  onFocus?: () => void;
  onSubmitEditing?: () => void;
  returnKeyType?: 'done' | 'go' | 'next' | 'search' | 'send';
}

export interface FirstXPCelebrationProps {
  xpAmount: number;
  levelProgress: number;
  badgeUnlocked?: Badge;
  onComplete?: () => void;
  reducedMotion?: boolean;
}

export interface LockedGamificationUIProps {
  currentLevel?: number;
  streakCount?: number;
  lockedBadgeCount?: number;
}

export interface MoneyTimelineProps {
  availableNow: number;
  todayReleases: MoneyTimelineEntry[];
  comingSoon: MoneyTimelineEntry[];
  blocked: MoneyTimelineEntry[];
}

export interface MoneyTimelineEntry {
  id: string;
  amount: number;
  description: string;
  taskTitle: string;
  timestamp?: string;
  reason?: string;
}

export interface FailureRecoveryProps {
  whatHappened: string;
  impact: string;
  whatYouCanDo: string[];
  recoveryPath?: string;
  onRetry?: () => void;
  onDismiss?: () => void;
}

// =============================================================================
// API REQUEST TYPES
// =============================================================================

export interface TaskCreateInput {
  title: string;
  description: string;
  requirements?: string;
  location: string;
  location_lat?: number;
  location_lng?: number;
  category: string;
  price: number; // USD cents, min 500 ($5.00), min 1500 ($15.00) for LIVE
  deadline: string; // ISO 8601
  mode?: TaskMode;
  requires_proof?: boolean;
  proof_instructions?: string;
}

export interface TaskListFilter {
  state?: TaskState | TaskState[];
  category?: string;
  mode?: TaskMode;
  poster_id?: string;
  worker_id?: string;
  min_price?: number;
  max_price?: number;
}

export interface TaskListSort {
  field: 'created_at' | 'price' | 'deadline';
  direction: 'asc' | 'desc';
}

export interface TaskFeedInput {
  location?: GeoLocation;
  radius_miles?: number; // Default: 25, max: 100
  categories?: string[];
  min_price?: number;
  max_price?: number;
  sort_by?: 'relevance' | 'distance' | 'price_desc' | 'price_asc' | 'deadline';
  pagination?: {
    limit?: number; // Default: 20, max: 50
    cursor?: string;
  };
}

export interface ProofSubmitInput {
  task_id: string;
  description: string;
  photo_urls: string[]; // 1-5 photos
}

export interface DisputeCreateInput {
  task_id: string;
  reason: DisputeReason;
  description: string;
  evidence_urls?: string[];
}

export interface RatingSubmitInput {
  task_id: string;
  stars: number; // 1-5
  comment?: string;
  tags?: string[];
}

export interface MessageSendInput {
  task_id: string;
  message_type: 'TEXT' | 'PHOTO' | 'LOCATION';
  content: string;
  photo_urls?: string[];
  location?: GeoLocation;
}

export interface LiveModeActivateInput {
  location: GeoLocation;
  radius_miles?: number; // Default: 5, max: 25
  categories?: string[];
}

export interface OnboardingRoleInput {
  role: UserRole;
  confidence: 'STRONG' | 'MODERATE' | 'WEAK';
}

// =============================================================================
// API RESPONSE TYPES
// =============================================================================

export interface ApiSuccessResponse<T> {
  result: {
    data: T;
  };
}

export interface ApiErrorResponse {
  error: {
    message: string;
    code: string;
    data?: unknown;
  };
}

export type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse;

// =============================================================================
// WEBSOCKET EVENT TYPES
// =============================================================================

export interface WSLiveTaskBroadcast {
  type: 'LIVE_TASK_BROADCAST';
  data: LiveTaskBroadcast;
}

export interface WSLiveTaskUnavailable {
  type: 'LIVE_TASK_UNAVAILABLE';
  data: {
    broadcast_id: string;
    reason: 'EXPIRED' | 'CLAIMED' | 'CANCELLED';
  };
}

export interface WSLiveModeStateChange {
  type: 'LIVE_MODE_STATE_CHANGE';
  data: {
    state: LiveModeState;
    reason?: string;
    cooldown_ends_at?: string;
  };
}

export interface WSTaskStatusUpdate {
  type: 'TASK_STATUS_UPDATE';
  data: {
    task_id: string;
    state: TaskState;
    updated_at: string;
  };
}

export interface WSNewMessage {
  type: 'NEW_MESSAGE';
  data: {
    task_id: string;
    message: Message;
  };
}

export type WSServerEvent =
  | WSLiveTaskBroadcast
  | WSLiveTaskUnavailable
  | WSLiveModeStateChange
  | WSTaskStatusUpdate
  | WSNewMessage;
