# HustleXP Assets Strategy

**AUTHORITY:** FRONTEND_ARCHITECTURE.md, DESIGN_SYSTEM.md
**STATUS:** Constitutional Reference for Cursor
**VERSION:** 1.0.0

This document defines HOW to handle images, icons, and assets. Cursor MUST follow these patterns.

---

## Table of Contents

1. [Asset Types](#1-asset-types)
2. [File Structure](#2-file-structure)
3. [Image Handling](#3-image-handling)
4. [Icon System](#4-icon-system)
5. [Loading & Fallbacks](#5-loading--fallbacks)
6. [Performance Guidelines](#6-performance-guidelines)

---

## 1. Asset Types

### Static Assets (bundled with app)

| Type | Location | Format | Use Case |
|------|----------|--------|----------|
| App icons | `assets/` | PNG | App icon, splash |
| Logo | `assets/` | PNG/SVG | Branding |
| Illustrations | `assets/illustrations/` | PNG/SVG | Empty states, onboarding |
| Badge icons | `assets/badges/` | PNG | Achievement badges |
| Placeholders | `assets/placeholders/` | PNG | Fallback images |

### Dynamic Assets (loaded from server)

| Type | Source | Format | Use Case |
|------|--------|--------|----------|
| User avatars | Firebase Storage URL | JPEG/PNG | Profile pictures |
| Proof photos | Firebase Storage URL | JPEG/PNG/HEIC | Task proof |
| Task images | Firebase Storage URL | JPEG/PNG | Task descriptions |

---

## 2. File Structure

```
HUSTLEXP-DOCS/
├── assets/
│   ├── adaptive-icon.png      # Android adaptive icon
│   ├── favicon.png            # Web favicon
│   ├── icon.png               # App icon (1024x1024)
│   ├── splash-icon.png        # Splash screen icon
│   │
│   ├── images/
│   │   ├── logo.png           # HustleXP logo
│   │   ├── logo-dark.png      # Logo for dark backgrounds
│   │   └── wordmark.png       # Text logo
│   │
│   ├── illustrations/
│   │   ├── empty-tasks.png    # No tasks available
│   │   ├── empty-wallet.png   # No earnings yet
│   │   ├── onboarding-1.png   # Onboarding frame 1
│   │   ├── onboarding-2.png   # Onboarding frame 2
│   │   ├── success.png        # Task completed
│   │   └── error.png          # Error state
│   │
│   ├── badges/
│   │   ├── first-task.png     # First task completed
│   │   ├── streak-7.png       # 7-day streak
│   │   ├── streak-30.png      # 30-day streak
│   │   ├── level-up.png       # Level up animation frame
│   │   └── verified.png       # Verification badge
│   │
│   └── placeholders/
│       ├── avatar.png         # Default avatar
│       ├── task-image.png     # Default task image
│       └── photo.png          # Default photo placeholder
```

---

## 3. Image Handling

### 3.1 Importing Static Images

```typescript
// Import static images
import logo from '@/assets/images/logo.png';
import emptyTasks from '@/assets/illustrations/empty-tasks.png';
import defaultAvatar from '@/assets/placeholders/avatar.png';

// Usage
<Image source={logo} style={styles.logo} />
```

### 3.2 Remote Images

```typescript
// Remote images with fallback
const RemoteImage = ({
  uri,
  fallback,
  style,
}: {
  uri: string | null;
  fallback: ImageSource;
  style: ImageStyle;
}) => {
  const [error, setError] = useState(false);

  if (!uri || error) {
    return <Image source={fallback} style={style} />;
  }

  return (
    <Image
      source={{ uri }}
      style={style}
      onError={() => setError(true)}
    />
  );
};

// Usage
<RemoteImage
  uri={user.avatar_url}
  fallback={defaultAvatar}
  style={styles.avatar}
/>
```

### 3.3 Avatar Component

```typescript
import defaultAvatar from '@/assets/placeholders/avatar.png';

const Avatar = ({
  source,
  name,
  size = 'md',
}: AvatarProps) => {
  const [error, setError] = useState(false);
  const sizeValue = AVATAR_SIZES[size];

  // Show image if available and not errored
  if (source && !error) {
    return (
      <Image
        source={{ uri: source }}
        style={[styles.avatar, { width: sizeValue, height: sizeValue }]}
        onError={() => setError(true)}
      />
    );
  }

  // Show initials as fallback
  const initials = getInitials(name);

  return (
    <View style={[styles.initialsContainer, { width: sizeValue, height: sizeValue }]}>
      <HXText variant="label" color="inverse">{initials}</HXText>
    </View>
  );
};

const getInitials = (name: string): string => {
  const parts = name.trim().split(/\s+/);
  if (parts.length >= 2) {
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
  return parts[0]?.slice(0, 2).toUpperCase() || '??';
};
```

### 3.4 Photo Upload

```typescript
import * as ImagePicker from 'expo-image-picker';

const pickImage = async (): Promise<string | null> => {
  const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();

  if (status !== 'granted') {
    toast.show({
      message: 'Photo library access is required',
      variant: 'error',
    });
    return null;
  }

  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ImagePicker.MediaTypeOptions.Images,
    allowsEditing: true,
    aspect: [1, 1], // Square for avatars
    quality: 0.8,
    exif: false,
  });

  if (result.canceled) {
    return null;
  }

  return result.assets[0].uri;
};

const takePhoto = async (): Promise<string | null> => {
  const { status } = await ImagePicker.requestCameraPermissionsAsync();

  if (status !== 'granted') {
    toast.show({
      message: 'Camera access is required',
      variant: 'error',
    });
    return null;
  }

  const result = await ImagePicker.launchCameraAsync({
    allowsEditing: true,
    quality: 0.8,
    exif: true, // Include for proof timestamp
  });

  if (result.canceled) {
    return null;
  }

  return result.assets[0].uri;
};
```

### 3.5 Image Upload to Server

```typescript
const uploadImage = async (
  uri: string,
  type: 'avatar' | 'proof' | 'task'
): Promise<string> => {
  // Get file info
  const filename = uri.split('/').pop() || 'image.jpg';
  const match = /\.(\w+)$/.exec(filename);
  const mimeType = match ? `image/${match[1]}` : 'image/jpeg';

  // Create form data
  const formData = new FormData();
  formData.append('file', {
    uri,
    name: filename,
    type: mimeType,
  } as unknown as Blob);
  formData.append('type', type);

  // Upload
  const response = await fetch(`${API_URL}/upload`, {
    method: 'POST',
    headers: {
      'Content-Type': 'multipart/form-data',
      Authorization: `Bearer ${token}`,
    },
    body: formData,
  });

  if (!response.ok) {
    throw new Error('Upload failed');
  }

  const { url } = await response.json();
  return url;
};
```

---

## 4. Icon System

### 4.1 Icon Library

Use `lucide-react-native` for ALL icons.

```typescript
import {
  Home,
  Search,
  Bell,
  User,
  MapPin,
  Clock,
  DollarSign,
  CheckCircle,
  XCircle,
  AlertTriangle,
  ChevronRight,
  ChevronLeft,
  Plus,
  Minus,
  Settings,
  LogOut,
  Camera,
  Image as ImageIcon,
  Send,
  Star,
  Zap,
  Shield,
  Award,
} from 'lucide-react-native';
```

### 4.2 Icon Sizes

From DESIGN_SYSTEM.md:

```typescript
const ICON_SIZES = {
  xs: 12,
  sm: 16,
  md: 20,
  lg: 24,
  xl: 32,
  xxl: 48,
};
```

### 4.3 Icon Colors

```typescript
// Use semantic colors from design system
import { NEUTRAL, XP, MONEY, STATUS } from '@/constants/colors';

// Default icons
<MapPin size={20} color={NEUTRAL.TEXT_SECONDARY} />

// Status icons
<CheckCircle size={20} color={STATUS.SUCCESS} />
<XCircle size={20} color={STATUS.ERROR} />
<AlertTriangle size={20} color={STATUS.WARNING} />

// XP icons (only in XP contexts!)
<Zap size={20} color={XP.PRIMARY} />

// Money icons (only in financial contexts!)
<DollarSign size={20} color={MONEY.POSITIVE} />
```

### 4.4 Icon Component Wrapper

```typescript
import * as Icons from 'lucide-react-native';
import { NEUTRAL } from '@/constants/colors';

const ICON_SIZES = {
  xs: 12,
  sm: 16,
  md: 20,
  lg: 24,
  xl: 32,
  xxl: 48,
};

interface IconProps {
  name: keyof typeof Icons;
  size?: keyof typeof ICON_SIZES;
  color?: string;
}

export const Icon = ({
  name,
  size = 'md',
  color = NEUTRAL.TEXT,
}: IconProps) => {
  const IconComponent = Icons[name] as React.ComponentType<{
    size: number;
    color: string;
  }>;

  if (!IconComponent) {
    console.warn(`Icon "${name}" not found`);
    return null;
  }

  return <IconComponent size={ICON_SIZES[size]} color={color} />;
};

// Usage
<Icon name="MapPin" size="md" color={NEUTRAL.TEXT_SECONDARY} />
```

---

## 5. Loading & Fallbacks

### 5.1 Image Loading States

```typescript
const ImageWithLoading = ({
  uri,
  style,
  fallback,
}: {
  uri: string;
  style: ImageStyle;
  fallback: ImageSource;
}) => {
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(false);

  if (error) {
    return <Image source={fallback} style={style} />;
  }

  return (
    <View style={[style, { overflow: 'hidden' }]}>
      {isLoading && (
        <Skeleton
          variant="rect"
          width={style.width}
          height={style.height}
        />
      )}
      <Image
        source={{ uri }}
        style={[style, isLoading && { position: 'absolute', opacity: 0 }]}
        onLoadEnd={() => setIsLoading(false)}
        onError={() => {
          setIsLoading(false);
          setError(true);
        }}
      />
    </View>
  );
};
```

### 5.2 Fallback Strategy

| Asset Type | Fallback |
|------------|----------|
| User avatar | Initials on colored background |
| Task image | Gray placeholder |
| Proof photo | "Photo unavailable" placeholder |
| Badge icon | Generic badge silhouette |
| Illustration | Text description |

### 5.3 Placeholder Colors

For initials/text fallbacks, generate consistent colors from name:

```typescript
const AVATAR_COLORS = [
  '#EF4444', // Red
  '#F97316', // Orange
  '#EAB308', // Yellow
  '#22C55E', // Green
  '#14B8A6', // Teal
  '#3B82F6', // Blue
  '#8B5CF6', // Purple
  '#EC4899', // Pink
];

const getAvatarColor = (name: string): string => {
  const hash = name.split('').reduce((acc, char) => {
    return char.charCodeAt(0) + ((acc << 5) - acc);
  }, 0);
  return AVATAR_COLORS[Math.abs(hash) % AVATAR_COLORS.length];
};
```

---

## 6. Performance Guidelines

### 6.1 Image Optimization

| Context | Max Size | Format | Quality |
|---------|----------|--------|---------|
| Avatar upload | 512x512 | JPEG | 80% |
| Proof photo | 1920x1920 | JPEG | 80% |
| Task image | 1200x1200 | JPEG | 80% |

### 6.2 Caching

```typescript
// Use expo-image for better caching
import { Image } from 'expo-image';

<Image
  source={{ uri }}
  style={styles.image}
  contentFit="cover"
  cachePolicy="memory-disk" // Cache in memory and disk
  placeholder={blurhash} // Optional blur placeholder
  transition={200} // Fade in duration
/>
```

### 6.3 List Image Optimization

For lists with many images:

```typescript
// Only load images when visible
<List
  data={tasks}
  renderItem={({ item }) => (
    <TaskCard task={item} />
  )}
  initialNumToRender={10}
  maxToRenderPerBatch={5}
  windowSize={5}
  removeClippedSubviews={true}
/>
```

### 6.4 Preloading Critical Images

```typescript
import { Asset } from 'expo-asset';

// Preload on app start
const preloadAssets = async () => {
  const images = [
    require('@/assets/images/logo.png'),
    require('@/assets/placeholders/avatar.png'),
    require('@/assets/illustrations/empty-tasks.png'),
  ];

  await Promise.all(
    images.map(image => Asset.loadAsync(image))
  );
};
```

---

## Asset Checklist for Cursor

When implementing a screen, check:

1. **Static images** — Import from `@/assets/`
2. **Remote images** — Use fallback pattern
3. **Icons** — Use lucide-react-native only
4. **Loading states** — Show skeleton while loading
5. **Error states** — Show appropriate fallback
6. **Colors** — Match semantic context (XP, money, status)

---

**END OF ASSETS STRATEGY**
