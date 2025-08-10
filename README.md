# Crunch and Dash

**Crunch and Dash** is a Flutter-based eCommerce application designed for ordering food online. The app utilizes **Firebase** for authentication and storage, **OpenStreetMap** and **Project OSRM** for map and route navigation, providing a seamless ordering experience.

## Features

- 🔐 **User Authentication** (Sign up, Sign in, Google Authentication) using Firebase.
- 📦 **Product Management** (View menu, add to cart, place orders).
- 🛒 **Cart & Checkout** (Manage cart, apply discounts, and process payments).
- 📍 **Location Tracking & Delivery** using OpenStreetMap & Project OSRM.
- 📊 **Order History & Status Updates**.

## Tech Stack

- **Flutter** - Cross-platform UI development.
- **Firebase** - Authentication, Firestore Database, Storage.
- **OpenStreetMap** - Interactive maps.
- **Project OSRM** - Routing & navigation.

## Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/VanVu1104/FoodApp.git
   cd FoodApp
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Set up Firebase:**
   - Create a Firebase project.
   - Add the `google-services.json` (Android) & `GoogleService-Info.plist` (iOS) to the respective directories.
   - Enable Authentication & Firestore.
4. **Run the app:**
   ```sh
   flutter run
   ```

## Folder Structure

```
lib/
│-- main.dart          # Entry point of the app
│-- core/              # Configuration & constants
│-- models/            # Data models
│-- services/          # API & Firebase services
│-- views/             # UI screens
│-- widgets/           # Reusable UI components
```

## Screenshots

*(Add some screenshots here!)*

## Contribution

Contributions are welcome! Feel free to fork and submit pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For any inquiries, reach out to:
- Email: tuyetngan3454@gmail.com

---

🚀 **Crunch and Dash – Bringing Your Favorite Meals to Your Doorstep!** 🍗

