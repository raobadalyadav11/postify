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

Based on the provided requirements for the Election and Festival Banner/Poster Making mobile application in Flutter with Firebase, I’ve identified the **features** and **pages/screens** that need to be implemented. Below is a detailed breakdown of the features and pages required to meet the functional and non-functional requirements.

## Features to Be Implemented

The application includes a comprehensive set of features to support poster creation, user management, offline functionality, monetization, and optional AI capabilities. Here’s the complete list of features categorized for clarity:

### 1. User Authentication (2 Features)
1. **Mobile Number Login**: Users log in by submitting their mobile number; credentials (local token) are auto-generated and stored locally using Firebase Authentication with offline persistence.
2. **Guest Mode**: Allow users to access the app without immediate login for first-time use, with data saved locally.

### 2. Poster Types (21 Features)
The app supports 21 distinct poster types, each requiring specific design elements and templates:
1. **Candidate Introduction**: Name, photo, party symbol, slogan, bio, vision.
2. **Party Symbol**: Large party logo, slogan, multi-language support.
3. **Voting Appeal**: “Please Vote for Me,” voting date/time/booth info.
4. **Manifesto**: Top promises, development agendas, opponent comparisons.
5. **Polling Day Reminder**: Voting date, voter ID checklist, booth info.
6. **Victory Celebration**: “Thanks for Voting,” “We Won!” messages.
7. **Festival Greetings**: Diwali, Holi, Eid, etc., with candidate branding.
8. **Birthday/Anniversary Wishes**: Wishes for leaders or citizens.
9. **Rally & Event**: Invitations with date, time, venue, guests.
10. **Achievements**: Past work (roads, hospitals), before/after images.
11. **Opposition Criticism**: Fact-based, respectful comparisons.
12. **Respected Leader Tribute**: Tributes for national leaders’ Jayanti/Punyatithi.
13. **Constituency Maps**: Region/ward/booth maps with candidate presence.
14. **Voter List Awareness**: Instructions to check/register voter list.
15. **Countdown**: Daily countdown to election date.
16. **Local Language Regional**: Templates in Hindi, Tamil, Bengali, etc.
17. **Women Empowerment**: Appeals to female voters.
18. **Youth-Focused**: Messages for first-time voters, job/education promises.
19. **Booth-Level**: Booth team/volunteer lists.
20. **Social Media Square**: Instagram/Facebook-friendly 1:1 posters.
21. **Video Thumbnail**: YouTube/FB Live poster templates.

### 3. Poster Formats (4 Features)
Support for multiple poster formats, each requiring rendering and export capabilities:
1. **Portrait**: A4 (2480x3508px), A3 (3508x4961px), 1080x1920px.
2. **Landscape**: 1920x1080px (Facebook cover), 1200x628px (banner).
3. **Square**: 1080x1080px (Instagram/WhatsApp).
4. **Custom Sizes**: User-defined dimensions for flexible poster creation.

### 4. Customization (6 Features)
1. **Text Customization**: Edit fonts, sizes, colors, and alignment.
2. **Image Customization**: Upload, resize, rotate, crop user images.
3. **Logo/Party Symbol Customization**: Add and adjust logos or symbols.
4. **Color Customization**: Apply custom colors or party-specific themes.
5. **Filter Application**: Add brightness, contrast, or other image filters.
6. **Drag-and-Drop Interface**: Intuitive placement of text, images, and logos on the canvas.

### 5. Poster Management (3 Features)
1. **Edit Posters**: Modify existing posters with full customization options.
2. **Delete Posters**: Soft delete posters (mark as deleted in Firebase) with a restore option.
3. **Restore Posters**: Recover deleted posters from local storage.

### 6. Export & Sharing (2 Features)
1. **Export**: Save posters as PNG/JPEG with compression for storage efficiency.
2. **Sharing**: Share posters directly to WhatsApp, Instagram, Facebook, etc., via native APIs.

### 7. Multilingual Support (1 Feature)
1. **Language Support**: Support for Hindi, English, Bengali, Tamil, Telugu, Gujarati, Marathi, Urdu, etc., with auto-detection or manual selection.

### 8. Offline Support (1 Feature)
1. **Offline Functionality**: All features (authentication, template access, poster management) work offline using Firebase Firestore offline persistence and local file storage.

### 9. Monetization (3 Features)
1. **Free Access**: All core features are free without restrictions.
2. **In-App Purchases/Donations**: Optional donations via Razorpay (e.g., for premium templates).
3. **Google Mobile Ads**: Banner ads (home/editor screens) and interstitial ads (on export/share).

### 10. AI Features (Optional, 4 Features)
1. **AI Text Suggestion**: Generate slogan suggestions using local ML models (e.g., TensorFlow Lite).
2. **AI Background Removal**: Automatically remove photo backgrounds.
3. **Auto-Fit Candidate Face**: Adjust candidate photos to fit template placeholders.
4. **Party-Color Theme Detection**: Automatically detect and apply party-specific color schemes.

### 11. Performance & Usability (3 Features)
1. **Fast Loading**: Template loading and rendering in <2 seconds using local storage.
2. **Intuitive UI**: Simple navigation, large buttons, and tooltips for non-technical users.
3. **Low Storage Usage**: Optimize templates and assets to use <100MB of device storage.

### 12. Security (2 Features)
1. **Secure Authentication**: Store credentials securely using Firebase Authentication and encrypted local storage.
2. **Data Privacy**: Encrypt user data and posters using flutter_secure_storage.

### Total Features
- **Core Features**: 28 (Authentication: 2, Poster Types: 21, Formats: 4, Customization: 6, Management: 3, Export/Sharing: 2, Multilingual: 1, Offline: 1, Monetization: 3, Performance/Usability: 3, Security: 2)
- **Optional AI Features**: 4
- **Total**: 32 (if AI features are included)

## Pages/Screens to Be Implemented

The app requires the following screens to support the features and provide an intuitive user experience. Each screen corresponds to specific functionalities in the MVC architecture’s View layer.

1. **Login Screen**
   - Purpose: Allow users to log in using their mobile number or access guest mode.
   - Features: Mobile number input with formatting (flutter_masked_text2), submit button, Firebase Authentication integration.
   - UI Elements: Text field, submit button, guest mode option.

2. **Home Screen**
   - Purpose: Display poster categories, types, and user’s saved posters.
   - Features: Categories (Political, Festival), poster type grid, saved posters list, filter options (party, language), banner ad integration.
   - UI Elements: Grid view, filter buttons, ad container, navigation bar.

3. **Template Selection Screen**
   - Purpose: Allow users to browse and select templates by category, party, or language.
   - Features: Grid view of templates, filters for category/party/language, search bar.
   - UI Elements: Template thumbnails, filter dropdowns, search input.

4. **Editor Screen**
   - Purpose: Provide a canvas for creating and editing posters.
   - Features: Drag-and-drop canvas (flutter_canvas), text/image/logo customization, color picker, filter application, real-time preview, save/export options.
   - UI Elements: Canvas, toolbar (text, image, logo, filters), preview button, save button.

5. **Poster Management Screen**
   - Purpose: View, edit, delete, or restore user-created posters.
   - Features: List of saved posters, edit/delete/restore options, soft deletion logic.
   - UI Elements: Poster list, action buttons (edit, delete, restore).

6. **Preview & Share Screen**
   - Purpose: Preview final poster and share/export it.
   - Features: Full-screen poster preview, export as PNG/JPEG, share via WhatsApp/Instagram/Facebook, interstitial ad on export.
   - UI Elements: Preview area, export button, share buttons, ad container.

7. **Profile Screen**
   - Purpose: Manage user account and view saved posters.
   - Features: Display user details (mobile number, name), list of saved posters, logout option.
   - UI Elements: User info, poster list, logout button.

8. **Donation Screen**
   - Purpose: Allow optional in-app donations or purchases.
   - Features: Razorpay integration for donations (e.g., for premium templates), donation amount selection.
   - UI Elements: Donation form, payment button, amount options.

### Total Screens
- **Total**: 8 screens

## Summary
- **Total Features**: 32 (28 core + 4 optional AI features)
- **Total Pages/Screens**: 8

## Notes
- **Feature Implementation**: Each poster type (21) requires distinct template designs but shares the same customization, editing, and sharing logic, reducing development complexity.
- **Screen Optimization**: Screens like Template Selection and Poster Management can reuse components (e.g., grid view) to streamline development.
- **Optional AI Features**: These can be implemented later as a phase 2 enhancement, as they are not critical to the core functionality.
- **Firebase Integration**: Offline persistence and local caching ensure all features work offline, with Firebase Firestore and Storage handling data efficiently.
- **Monetization**: Ads and donations are non-intrusive, ensuring free access to all core features.

This list covers all required features and screens based on the provided requirements, ensuring the app meets its goals for usability, functionality, and offline support. Let me know if you need further details or assistance with implementation steps!