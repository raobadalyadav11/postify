# Product Requirements Document (PRD)

## Document Information
- **Product Name:** Election and Festival Banner/Poster Maker
- **Version:** 1.0
- **Date:** August 11, 2025
- **Author:** Grok (AI Assistant)
- **Description:** This PRD outlines the requirements for a mobile application built in Flutter using Firebase for backend services. The app allows users to create, customize, edit, delete, and share posters and banners for political campaigns and festivals. It supports offline functionality, monetization via ads and donations, and follows an MVC architecture.

## 1. Overview
The mobile application enables users to create, customize, edit, delete, and share posters and banners for political campaigns (e.g., BJP, RJD, AAP) and festivals (e.g., Diwali, Holi), supporting a comprehensive list of poster types. Users log in by submitting their mobile number, with credentials automatically set and stored locally. All data (templates, posters, user data) is cached locally using Firebase (with offline persistence enabled), and the app is free with optional in-app purchases/donations via Razorpay and monetization via Google Mobile Ads. Developed in Flutter, it follows the MVC architecture.

### Key Objectives
- Provide an intuitive tool for non-technical users (e.g., political workers, event organizers) to create professional posters offline.
- Support multilingual and customizable designs for diverse Indian audiences.
- Ensure offline-first design with local caching for reliability in low-connectivity areas.
- Monetize through non-intrusive ads and voluntary donations without restricting core features.

### Target Audience
- Political campaigners and party workers.
- Festival organizers and individuals.
- Users in India with varying literacy levels, preferring local languages.

### Assumptions and Dependencies
- Flutter framework for cross-platform development (iOS/Android).
- Firebase for authentication, database, and storage with offline support.
- No server-side processing required; all operations are local or client-side.
- Templates are pre-bundled in app assets for initial offline access.

## 2. Functional Requirements

### 2.1 User Authentication
- Users log in by submitting their mobile number.
- Credentials are auto-generated (e.g., a local token) and stored securely.
- Use Firebase Authentication for phone-based login (optional OTP if needed), with local storage fallback via Firebase's offline persistence.
- No email/password required; support guest mode for first-time use.

### 2.2 Poster Types
The app supports the following poster categories and types:

| Category | Poster Type | Key Elements |
|----------|-------------|--------------|
| Political | Candidate Introduction | Name, photo, party symbol, slogan, bio, vision. |
| Political | Party Symbol | Large party logo, slogan, multi-language support. |
| Political | Voting Appeal | “Please Vote for Me,” voting date/time/booth info. |
| Political | Manifesto | Top promises, development agendas, opponent comparisons. |
| Political | Polling Day Reminder | Voting date, voter ID checklist, booth info. |
| Political | Victory Celebration | “Thanks for Voting,” “We Won!” messages. |
| Festival | Festival Greetings | Diwali, Holi, Eid, etc., with candidate branding. |
| General | Birthday/Anniversary | Wishes for leaders or citizens. |
| Political | Rally & Event | Invitations with date, time, venue, guests. |
| Political | Achievements | Past work (roads, hospitals), before/after images. |
| Political | Opposition Criticism | Fact-based, respectful comparisons. |
| Political | Respected Leader Tribute | Tributes for national leaders’ Jayanti/Punyatithi. |
| Political | Constituency Maps | Region/ward/booth maps with candidate presence. |
| Political | Voter List Awareness | Instructions to check/register voter list. |
| Political | Countdown | Daily countdown to election date. |
| General | Local Language Regional | Templates in Hindi, Tamil, Bengali, etc. |
| Political | Women Empowerment | Appeals to female voters. |
| Political | Youth-Focused | Messages for first-time voters, job/education promises. |
| Political | Booth-Level | Booth team/volunteer lists. |
| Social Media | Social Media Square | Instagram/Facebook-friendly 1:1 posters. |
| Social Media | Video Thumbnail | YouTube/FB Live poster templates. |

### 2.3 Poster Formats
- Portrait: A4 (2480x3508px), A3 (3508x4961px), 1080x1920px.
- Landscape: 1920x1080px (Facebook cover), 1200x628px (banner).
- Square: 1080x1080px (Instagram/WhatsApp).
- Custom: User-defined dimensions.

### 2.4 Customization
- Fully customizable: Text (fonts, sizes, colors), images (upload, resize, rotate, crop), logos, party symbols, colors, filters (brightness, contrast).
- Drag-and-drop interface for elements.
- Real-time preview during editing.

### 2.5 Edit/Delete/Restore
- Users can edit, delete (soft delete), or restore posters at any time.
- Deleted posters marked as 'deleted' in Firebase local cache for easy restoration.

### 2.6 Export & Sharing
- Export as PNG/JPEG with compression.
- Share directly to WhatsApp, Instagram, Facebook, etc., via native sharing APIs.

### 2.7 Multilingual Support
- Languages: Hindi, English, Bengali, Tamil, Telugu, Gujarati, Marathi, Urdu, etc.
- Auto-detect device language or manual selection.

### 2.8 Offline Support
- All features (authentication, template access, poster management) work offline.
- Use Firebase Firestore offline persistence for data syncing when online.

### 2.9 Monetization
- Free app with all features accessible.
- Optional in-app purchases/donations via Razorpay (e.g., for premium templates).
- Google Mobile Ads: Banner ads on home/editor screens, interstitial on export/share.

### 2.10 AI Features (Optional)
- AI text suggestion for slogans (using local ML models like TensorFlow Lite).
- AI photo background removal.
- Auto-fit candidate face in templates.
- Party-color theme detection.

## 3. Non-Functional Requirements

### 3.1 Performance
- Template loading and rendering in <2 seconds using local storage.
- Efficient queries and caching to handle 100+ templates.

### 3.2 Usability
- Intuitive UI/UX for non-technical users.
- Simple navigation, large buttons, and tooltips.

### 3.3 Storage
- Minimize device space: <100MB for templates and app assets.
- Compress images and use efficient data formats.

### 3.4 Security
- Secure local storage of user data and credentials using Firebase Authentication and encrypted storage.
- Protect against unauthorized access to posters/images.

### 3.5 Cross-Platform
- Full support for iOS and Android via Flutter.

### 3.6 Reliability
- Offline-first: App functions without internet; sync data when online.

## 4. System Architecture (MVC)

### 4.1 Model
Manages data and business logic using Firebase.

- **Entities:**
  - User: user_id (UUID), mobile_number, name (optional), credentials (local token).
  - Template: template_id, category, party, type, image_path (local asset), metadata (language, resolution, fonts).
  - Poster: poster_id, user_id, template_id, customizations (JSON), created_at, updated_at, status (active/deleted).

- **Data Sources:**
  - Database: Firebase Firestore with offline persistence for user data, templates metadata, and posters.
  - Storage: Firebase Storage for user-uploaded images (local cache); app assets for templates.
  - Template Storage: Pre-bundled in app assets.
  - Poster Storage: JSON in Firestore, images in device storage.

- **Data Management:**
  - Templates pre-loaded from assets.
  - Soft deletion for posters.

### 4.2 View
Handles UI rendering with Flutter.

- **Screens:**
  - Login: Mobile number input.
  - Home: Categories, poster types, saved posters.
  - Template Selection: Grid view with filters.
  - Editor: Canvas for drag-and-drop editing.
  - Poster Management: View/edit/delete/restore.
  - Preview & Share: Export and share options.
  - Profile: Account management.
  - Donation: Razorpay interface.

- **UI Components:**
  - Canvas: Custom painter for editing.
  - Multilingual: flutter_i18n.
  - Ads: Google Mobile Ads integration.

### 4.3 Controller
Processes inputs, updates Model, refreshes View.

- **Actions:**
  - Authenticate via Firebase.
  - Load/save templates/posters.
  - Handle editing, export, sharing.
  - Manage ads and donations.

- **Business Logic:**
  - Generate local token on login.
  - Real-time customizations using image processing packages.
  - Compress exports.

## 5. System Components

### 5.1 Frontend
- Framework: Flutter.
- Packages: firebase_auth, cloud_firestore, firebase_storage, image_picker, share_plus, google_mobile_ads, razorpay_flutter, flutter_i18n, image, flutter_canvas.

### 5.2 Backend/Local Storage
- Database: Firebase Firestore (offline-enabled).
- Storage: Firebase Storage with local cache; device file system for exports.

### 5.3 External Integrations
- Sharing: share_plus.
- Payments: Razorpay.
- Ads: Google Mobile Ads.
- AI (Optional): TensorFlow Lite.

## 6. Data Flow
1. User submits mobile number; Controller authenticates via Firebase, stores token.
2. Home loads templates from assets/Firestore cache.
3. User selects/customizes template; saves to Firestore and storage.
4. Edit/delete/restore updates Firestore.
5. Export/share processes image and integrates with social media.
6. Donations/ads handled via integrations.

## 7. Scalability
- Local-only operations; no server scaling needed.
- Optimize assets for size (<100MB).

## 8. Security
- Encrypted storage via Firebase.
- Secure token management.

## 9. Deployment
- Build: Flutter for APK/IPA.
- Stores: Google Play, App Store (free app).

## 10. Future Enhancements
- User-uploaded templates.
- Video banner support.
- AR preview for posters.