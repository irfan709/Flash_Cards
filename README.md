# 🧠 Flash Cards App

A Flutter-based flashcard app to help users create, manage, and study decks of flashcards. Features include real-time updates, email authentication with Supabase, state management using Riverpod, and smooth card flip animations.

---

## ✨ Features

- 🔐 Email authentication with **Supabase**
- 📁 Organize flashcards into **decks**
- 🎴 **Flip animation** using Flutter animations
- 📦 Data stored in **Supabase Postgres** with **Row-Level Security (RLS)**
- 🔄 Real-time sync with **Supabase streams**
- 📊 Efficient state management via **Riverpod**
- ➕ Add, edit, and delete decks and flashcards
- 🖼️ Clean UI with intuitive navigation

---

## 🚀 Installation

### ⚙️ Prerequisites

- ✅ [Flutter SDK](https://flutter.dev/docs/get-started/install)
- ✅ [Supabase account](https://app.supabase.com/)
- ✅ Emulator or physical device

### 🛠️ Setup Instructions

# 1. Clone the repository
- git clone https://github.com/your-username/flash_cards_app.git
- cd flash_cards_app

# 2. Install dependencies
- flutter pub get

# 3. Run the app
- flutter run

## 🔑 Supabase Setup

1. Go to [Supabase](https://app.supabase.com/) and create a new project.
2. Enable **Email/Password Authentication** under the **Authentication** section.
3. Create the following tables in your Supabase database and apply the RLS (Row-Level Security) policies as specified.

---

### 🗂️ `decks` Table

| Column     | Type      | Constraints              |
|------------|-----------|--------------------------|
| `id`       | UUID      | Primary Key              |
| `deck_name`| Text      | Not null                 |
| `user_id`  | UUID      | References `auth.uid()`  |
| `created_at` | Timestamp | Default: `now()`       |

---

### 🗂️ `flashcards` Table

| Column       | Type      | Constraints                   |
|--------------|-----------|-------------------------------|
| `id`         | UUID      | Primary Key                   |
| `deck_id`    | UUID      | References `decks.id`         |
| `front_text` | Text      | Not null                      |
| `back_text`  | Text      | Not null                      |
| `image_url`  | Text      | Optional                      |
| `created_at` | Timestamp | Default: `now()`              |

---

### 🔒 RLS (Row-Level Security) Policies

-- Enable RLS on both tables
ALTER TABLE decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

-- Allow users to access only their own decks
CREATE POLICY "Users can access their own decks"
  ON decks FOR ALL
  USING (auth.uid() = user_id);

-- Allow users to access flashcards belonging to their decks
CREATE POLICY "Users can access their own flashcards"
  ON flashcards FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM decks
      WHERE decks.id = deck_id AND decks.user_id = auth.uid()
    )
  );


## 🧠 How It Works

### 📁 Deck Management

- ➕ Tap the **add** button to create a new deck
- 📂 Tap on a deck to open its flashcards
- ✏️ Long-press a deck to edit flashcards

### 🎴 Flashcard Management

- 🔄 Tap a flashcard to flip between front and back
- ✏️ Long-press a flashcard to edit
- ➕ Tap the **add** button inside the card screen to create new flashcards

### 🔐 Authentication

- 🔑 Auth is handled via Supabase Email/Password
- 🧠 App state is managed with Riverpod
- 🔁 Auth session persists between app restarts

---

## 📦 Dependencies

| Package           | Purpose                      |
|-------------------|------------------------------|
| flutter_riverpod  | State management             |
| supabase_flutter  | Supabase integration         |
| flutter/material  | UI components and animations |

---

## 🔧 TODO

- 📊 Add review statistics per deck
- 🖼️ Enable image upload support in flashcards
- ⏱️ Implement Spaced Repetition System (SRS)
- 🔍 Add deck/flashcard search functionality

