/**
 * HustleXP Component Exports v2.0.0
 *
 * UPDATED 2026-01-23: Added all 21 components from COMPONENT_LIBRARY.md
 *
 * AUTHORITY: specs/03-frontend/COMPONENT_LIBRARY.md
 */

// ═══════════════════════════════════════════════════════════════════════════
// PRIMITIVE COMPONENTS (§1-4)
// ═══════════════════════════════════════════════════════════════════════════

export { Button } from './Button';
export { Card } from './Card';
export { HXText } from './Text';
export { Input } from './Input';

// ═══════════════════════════════════════════════════════════════════════════
// CORE UI COMPONENTS (§5-8)
// ═══════════════════════════════════════════════════════════════════════════

export { Avatar } from './Avatar';
export { Badge } from './Badge';
export { TaskCard } from './TaskCard';
export { SearchBar } from './SearchBar';

// ═══════════════════════════════════════════════════════════════════════════
// OVERLAY COMPONENTS (§9-10)
// ═══════════════════════════════════════════════════════════════════════════

export { Modal } from './Modal';
export { BottomSheet } from './BottomSheet';

// ═══════════════════════════════════════════════════════════════════════════
// LIST & PROGRESS COMPONENTS (§11-13)
// ═══════════════════════════════════════════════════════════════════════════

export { List } from './List';
export { ProgressBar } from './ProgressBar';
export {
  Skeleton,
  SkeletonText,
  SkeletonAvatar,
  SkeletonTaskCard,
  SkeletonTaskList,
} from './Skeleton';

// ═══════════════════════════════════════════════════════════════════════════
// FEEDBACK COMPONENTS (§14)
// ═══════════════════════════════════════════════════════════════════════════

export { ToastProvider, useToast } from './Toast';

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION COMPONENTS (§15-16)
// ═══════════════════════════════════════════════════════════════════════════

export { TabBar } from './TabBar';
export { Header, LargeHeader } from './Header';

// ═══════════════════════════════════════════════════════════════════════════
// CONSTITUTIONAL COMPONENTS (§17-21)
// ═══════════════════════════════════════════════════════════════════════════

export { FirstXPCelebration } from './FirstXPCelebration';
export { LockedGamificationUI } from './LockedGamificationUI';
export { MoneyTimeline } from './MoneyTimeline';
export {
  FailureRecovery,
  TaskFailedScreen,
  TrustTierChangeScreen,
  DisputeLostScreen,
} from './FailureRecovery';
export {
  LiveTaskCard,
  LiveModeToggle,
  PosterLiveConfirmation,
} from './LiveModeUI';
