# Lineless 🎫
### Smart Campus Queue Management System

> **No more standing in lines.** Students generate digital tokens from their phones, track their queue position in real time, and get notified when it's their turn — all without being physically present in a queue.

---

## 📱 Download the App

**[⬇️ Download Latest APK](https://github.com/NikhilSharma201/Lineless/releases/latest)**

> Android only · Requires Android 6.0+
>
> **How to install:**
> 1. Download the APK file from the link above
> 2. Open the file on your Android phone
> 3. If prompted, go to **Settings → Security → Enable "Install unknown apps"** for your browser/file manager
> 4. Tap **Install** and you're done

> ⚠️ Live backend currently paused (free tier expired).
> To run the project, follow the local setup instructions below.
---

## 🧩 What Problem Does It Solve?

College students waste significant time standing in physical queues for routine services — scholarship applications, train concession passes, visa letters, fee waivers. Lineless digitizes this entirely:

- Students join a queue remotely from their phone
- They can monitor their position without being physically present
- Admin staff manage the queue from a dedicated panel
- Automatic notifications update students when their position changes or their turn arrives

---

## ✨ Features

### Student Side
- 🔐 Secure registration and login with bcrypt-hashed 6-digit PIN
- 🎫 Generate digital queue tokens for any available service
- 📊 Real-time queue position tracking with estimated wait times
- 📱 QR code on each token for counter verification
- 🔔 Push notifications for queue updates and admin messages
- ❌ Cancel tokens anytime

### Admin Side
- 📋 Live dashboard grouped by service category
- ✅ Mark tokens as completed or remove them from queue
- 📢 Send custom broadcast notifications to all students or a specific service queue
- 🔄 Queue positions auto-update for all students when someone is served

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter App (Android)               │
│                                                      │
│  Student Login → Token Generation → QR Code         │
│  Admin Panel → Queue Management → Notifications     │
└─────────────────┬───────────────────────────────────┘
                  │  HTTP REST API (JSON)
                  │  via https://
                  ▼
┌─────────────────────────────────────────────────────┐
│              Flask Backend (Python)                  │
│              Hosted on Railway                       │
│                                                      │
│  /login        /register      /tokens               │
│  /services     /notifications /admin/*              │
│                                                      │
│  Gunicorn (2 workers) · CORS enabled                │
└─────────────────┬───────────────────────────────────┘
                  │  SQLAlchemy ORM
                  ▼
┌─────────────────────────────────────────────────────┐
│           PostgreSQL Database                        │
│           Hosted on Railway                          │
│                                                      │
│  users · admins · services · tokens · notifications  │
└─────────────────────────────────────────────────────┘
```

### Notification Flow
```
Admin sends message
        │
        ▼
Backend saves Notification row to DB (per recipient)
        │
        ▼
Flutter app polls /notifications/<user_id> every 30s
        │
        ▼
flutter_local_notifications shows system notification
        │
        ▼
Backend marks notification as read
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter 3.x + Dart |
| Backend API | Python 3.13 + Flask |
| Database ORM | SQLAlchemy |
| Production Database | PostgreSQL |
| Password Security | bcrypt |
| Production Server | Gunicorn |
| Cloud Hosting | Railway |
| Notifications | flutter_local_notifications (DB polling) |
| QR Codes | qr_flutter |
| HTTP Client | http (Dart package) |

---

## 📂 Project Structure

```
lineless/
│
├── backend/
│   ├── app.py              # All Flask routes and business logic
│   ├── models.py           # SQLAlchemy database models
│   ├── notifications.py    # Notification service (DB-based)
│   ├── config.py           # Environment configuration
│   ├── requirements.txt    # Python dependencies
│   ├── Procfile            # Gunicorn start command for Railway
│   └── nixpacks.toml       # Railway build config (PostgreSQL system lib)
│
└── linelss/ (Flutter project)
    ├── lib/
    │   ├── main.dart               # All screens and UI
    │   ├── notification_service.dart   # flutter_local_notifications init
    │   └── notification_poller.dart    # 30s polling timer
    └── android/
        └── app/
            └── build.gradle        # Android build config
```

---

## 🗄️ Database Schema

```
users
├── id (PK)
├── student_id (unique, 8 digits)
├── name
├── email (unique)
├── pin_hash          ← bcrypt hashed, never plain text
├── max_active_tokens (default: 3)
└── created_at

tokens
├── id (PK)
├── token_id          ← e.g. "LL-88291"
├── user_id (FK → users)
├── service_id (FK → services)
├── status            ← ACTIVE / COMPLETED / CANCELLED
├── queue_position
└── created_at

services
├── id (PK)
├── name              ← Scholarships, Train Concessions, etc.
├── description
├── icon
└── is_active

notifications
├── id (PK)
├── user_id (FK → users)
├── title
├── message
├── type              ← queue_update / admin_message / token_completed
├── read (boolean)
└── sent_at
```

---

## 🚀 Running Locally

### Backend

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Initialize database with default data
flask init-db

# Run development server
python app.py
```

Backend runs at `http://localhost:5000`

Default admin credentials:
- Email: `admin@apsit.edu.in`
- Password: `admin123`

### Flutter App

```bash
cd linelss

# Install dependencies
flutter pub get

# Update baseUrl in lib/main.dart to point to your local backend
# const String baseUrl = 'http://YOUR_LOCAL_IP:5000';

# Run on connected device or emulator
flutter run
```

---

## ☁️ Deployment

The backend is deployed on **Railway** with a managed PostgreSQL database.

- **Backend URL:** `https://lineless-backend-production.up.railway.app`
- **Health check:** `https://lineless-backend-production.up.railway.app/health`

### Deploy your own instance

1. Fork this repo
2. Go to [railway.app](https://railway.app) → New Project → Deploy from GitHub
3. Add a PostgreSQL database service
4. Set environment variables:
   - `FLASK_ENV` = `production`
   - `SECRET_KEY` = your secret key
   - `DATABASE_URL` = reference from your PostgreSQL service
5. Run `flask init-db` from the Railway shell once deployed

---

## 🔐 Security

- Student PINs and admin passwords are hashed with **bcrypt** — never stored as plain text
- Input validation on both client (Flutter) and server (Flask) sides
- Students are limited to **3 active tokens maximum** to prevent abuse
- Duplicate service tokens are blocked — one active token per service per student
- CORS is configured on the backend

---

## 👥 Team

Built as a Mini Project at **APSIT (A.P. Shah Institute of Technology)**

>By Nikhil Sharma, Aarya Shinkar, Disha Patel, Mehaan Churi
---

## 📄 License

MIT License — feel free to use, modify, and distribute.
