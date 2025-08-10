# Service Complaint Buddy (SCB)

A comprehensive home service complaint management system built with Flutter and Node.js. This project consists of three separate Flutter applications for different user roles and a centralized Node.js backend API.

## 🏗️ Project Structure

```
Service-Complaint-Buddy/
├── scb/                    # Customer Flutter App
├── admin/                  # Admin Flutter App  
├── technician/             # Technician Flutter App
├── my_api/                 # Node.js Backend API
└── README.md
```

## 📱 Applications

### 1. Customer App (`scb/`)
The main customer-facing application where users can:
- Register and login
- Submit service complaints
- Track complaint status
- View complaint history
- Upload images and provide location data
- Use AI-powered appliance detection

**Key Features:**
- Image capture and upload
- GPS location tracking
- Real-time complaint tracking
- Push notifications
- Modern UI with motion animations

### 2. Admin App (`admin/`)
Administrative dashboard for managing complaints:
- View pending complaints
- Approve/reject complaints
- Assign technicians
- Monitor complaint history
- Analytics and reporting

**Key Features:**
- Complaint approval workflow
- Technician assignment
- Status management
- Historical data viewing

### 3. Technician App (`technician/`)
Field technician application for:
- Viewing assigned complaints
- Updating complaint status
- Location-based navigation
- Photo documentation
- Work completion reporting

**Key Features:**
- Accept/reject assigned complaints
- Update work progress
- Location services
- Photo documentation
- Status updates

## 🛠️ Technology Stack

### Frontend (Flutter)
- **Framework:** Flutter 3.3.4+
- **State Management:** Provider
- **UI Components:** Material Design
- **Key Dependencies:**
  - `http` - API communication
  - `shared_preferences` - Local storage
  - `image_picker` - Camera functionality
  - `geolocator` - Location services
  - `provider` - State management
  - `google_fonts` - Typography
  - `carousel_slider` - Image carousels

### Backend (Node.js)
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** PostgreSQL with Sequelize ORM
- **Authentication:** JWT with bcrypt
- **Key Dependencies:**
  - `express` - Web framework
  - `pg` - PostgreSQL client
  - `sequelize` - ORM
  - `jsonwebtoken` - JWT authentication
  - `bcryptjs` - Password hashing
  - `nodemailer` - Email notifications
  - `twilio` - SMS notifications
  - `cors` - Cross-origin resource sharing

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.3.4 or higher)
- Node.js (v16 or higher)
- PostgreSQL database
- Android Studio / VS Code

### Backend Setup

1. **Navigate to the API directory:**
   ```bash
   cd my_api
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   Create a `.env` file in the `my_api` directory with:
   ```
   DB_HOST=localhost
   DB_USER=your_username
   DB_PASSWORD=your_password
   DB_NAME=your_database
   JWT_SECRET=your_jwt_secret
   ```

4. **Start the server:**
   ```bash
   npm start
   ```

### Flutter Apps Setup

#### Customer App
1. **Navigate to the customer app:**
   ```bash
   cd scb
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   Update `lib/config/api_config.dart` with your backend URL

4. **Run the app:**
   ```bash
   flutter run
   ```

#### Admin App
1. **Navigate to the admin app:**
   ```bash
   cd admin
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   Update `lib/api_config.dart` with your backend URL

4. **Run the app:**
   ```bash
   flutter run
   ```

#### Technician App
1. **Navigate to the technician app:**
   ```bash
   cd technician
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   Update `lib/config/api_config.dart` with your backend URL

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📊 Database Schema

The system uses PostgreSQL with the following main tables:
- `users` - User accounts and authentication
- `complaints` - Service complaint records
- `technicians` - Technician profiles
- `assignments` - Complaint-technician assignments

## 🔐 Authentication

The system uses JWT-based authentication with role-based access control:
- **Customer:** Can submit and track complaints
- **Admin:** Can manage complaints and assign technicians
- **Technician:** Can view and update assigned complaints

## 📱 Features

### Customer Features
- User registration and login
- Complaint submission with photos
- Real-time status tracking
- Location-based services
- Push notifications
- Complaint history

### Admin Features
- Dashboard with complaint overview
- Complaint approval workflow
- Technician assignment
- Analytics and reporting
- User management

### Technician Features
- View assigned complaints
- Update work progress
- Location tracking
- Photo documentation
- Status updates

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

### Complaints
- `GET /api/complaints/pending` - Get pending complaints
- `GET /api/complaints/completed` - Get completed complaints
- `GET /api/complaints/accepted` - Get accepted complaints
- `POST /api/complaints/approve` - Approve complaint
- `POST /api/complaints/rejectComplaint` - Reject complaint
- `GET /api/complaints/:id` - Get complaint details

## 📦 Building for Production

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the ISC License.

## 👥 Authors

- Service Complaint Buddy Team

## 🆘 Support

For support and questions, please contact the development team or create an issue in the repository.

---

**Note:** Make sure to configure all environment variables and database connections before running the applications. The system requires a PostgreSQL database to be set up and running.
