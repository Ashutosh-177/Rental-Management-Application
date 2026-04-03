# Rent Collect

A professional, real-time rent collection and property management ecosystem built with Flutter and Firebase. This application seamlessly connects Property Owners and Tenants through a robust synchronization layer.

---

## 📦 Module 1: Foundation & Authentication
*The secure gateway and user identity management system.*

### 🛡️ Authentication Features
- **Phone Number + OTP**: Seamless registration and login via mobile verification for enhanced security.
- **Email & Password**: Standard authentication flow for users preferring traditional login.
- **Forgot Password**: Fully functional password recovery system via Firebase Auth.
- **Role Selection**: Intent-based onboarding where users choose to be an **Owner** or a **Tenant**.
- **Real-time Session Management**: Persistent login states that survive app restarts.

### 👤 Profile Management
- **User Discovery**: Automated user profile creation in Firestore upon first registration.
- **Dynamic Profiles**: Editable metadata including Name, Bio, and Contact Information.
- **Biometric/Visual ID**: Integrated **ImagePicker** for selecting or capturing profile photos.
- **Avatar Storage**: Direct integration with **Firebase Storage** for high-resolution profile images.

---

## 🏠 Module 2: Dashboards & Real-time Synchronization
*The operational core providing instant feedback and connectivity.*

### 📊 Owner Dashboard
- **Instant Statistics**: Real-time counters for Total Properties, Total Rooms, and Total Tenants.
- **Management Shortcuts**: Quick-access portals to Properties, Occupancy, and Maintenance requests.
- **Occupancy Insights**: Visual breakdown of which rooms are full and which require attention.

### 🏘️ Tenant Dashboard
- **Context-Aware UI**: The interface dynamically changes based on the user's state:
    - **No Property**: Shows an inviting empty state with an "Explorer" to find homes.
    - **Pending Request**: Displays a "Waiting for Approval" status with property details.
    - **Active Tenant**: Provides a full suite of tools (My Room, Maintenance, Rent status).

### 🔔 Real-time Communication
- **Global Notification System**: A centralized system that alerts users to important events.
- **Unread Badges**: Real-time counters on navigation icons to ensure no message is missed.
- **Meaningful Webbing**: Zero-refresh updates—when an owner approves a request, the tenant's screen updates instantly.

---

## 🛠️ Module 3: Property Operations & Communication
*The business logic layer where property management happens.*

### 🏫 Property & Room Engine
- **Property Studio**: Owners can create properties with detailed names and addresses.
- **Room Architect**: Granular control over rooms, including defining occupancy limits.
- **Join Logic**: Automatic generation of unique 6-digit security codes for private property joining.

### 📑 Request & Approval Hub
- **Join Requests**: Tenants search for properties via codes and send binding requests.
- **Room Placement**: Internal requests for specific rooms within a property.
- **The Decider**: A dedicated hub for owners to review tenant bios and **Approve/Reject** requests with one tap.

### 🔧 Maintenance & Safety
- **Issue Reporting**: Tenants can report maintenance problems (e.g., plumbing, electric) with:
    - Detailed titles and long-form descriptions.
    - **Visual Evidence**: Camera integration to upload photos of the problem.
- **Service Dashboard**: Owners track issues through a pipeline (Pending -> In Progress -> Resolved).
- **Identity Verification**: Secure document vault where tenants upload IDs (Aadhaar/PAN) for owner verification.

### 🔒 Enterprise-Grade Security
- **Firestore Security Rules**: Custom ruleset that prevents data leaks between unrelated users.
- **Private Data Streams**: Ensures tenants only see their own room/property data.
- **Secure File Storage**: Role-protected access to identity documents and private photos.

---

## 💰 Module 4: Rent Collection & Payment Tracking
*The financial engine — the feature the entire app is built around.*

### 🧾 Rent Record Generation (Owner)
- **One-Tap Generation**: Owners generate rent records for all tenants across all properties for any selected month and year.
- **Smart Deduplication**: The system skips tenants who already have a record for the selected period — no double entries.
- **Automatic Overdue Detection**: Records with a past due date are automatically marked as **Overdue** at creation time.
- **Room-Linked Amounts**: Rent amount is pulled directly from the room's configured rent value.

### 📊 Rent Collection Dashboard (Owner)
- **Month/Year Selector**: Filter rent records by any month and year — full historical control.
- **Revenue Summary Bar**: Live totals for **Total Expected**, **Collected**, and **Pending** amounts for the selected period.
- **Smart Sorting**: Records are sorted by urgency — Overdue first, then Pending, then Paid.
- **Mark as Paid**: One-tap confirmation to record a payment, with an optional notes field (e.g., "Cash received", "UPI transfer").
- **Rent Reminders**: Send instant in-app notifications to tenants with outstanding dues.
- **Status Chips**: Visual color-coded badges (Green/Orange/Red) for quick status identification.

### 🏠 My Rent Screen (Tenant)
- **Current Month Card**: A prominent, color-coded card showing this month's rent — amount, due date, status, and payment date if paid.
- **Full Payment History**: A scrollable timeline of all past rent records with status and dates.
- **Notes Display**: Any payment notes left by the owner are shown on the card.
- **Real-time Updates**: The dashboard rent summary card updates instantly when the owner marks a payment.

### 🔔 Rent Notification Flow
- **Paid Confirmation**: Tenant receives a notification when their rent is marked as paid.
- **Reminder Alerts**: Tenant receives a targeted reminder with the due amount and month.

---

### 🚀 Technical Stack
- **Framework**: Flutter (Dart)
- **Backend Architecture**: Firebase Serverless (Auth, Firestore, Cloud Storage)
- **State Management**: Provider Pattern for predictable data flow.
- **Design Ethos**: Modern UI with high-contrast typography and interactive micro-animations.

*Project status: Modules 1, 2, 3, and 4 are complete and ready for deployment.*
