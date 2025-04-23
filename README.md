# Knowledge Organizer App (Flutter)

A Flutter-based desktop application designed for organizing information, visualizing notes with images, and planned integration with Large Language Models (LLMs). Think of it as a personal, structured knowledge base with AI capabilities.

## Features

### Current Features:

*   **Hierarchical Table of Contents (ToC):**
    *   Create and visualize nested categories and subcategories.
    *   Clear visual indentation for structure.
    *   Select categories to view associated content.
*   **Text Content Editing:**
    *   A dedicated area to write and edit notes for the selected category.
    *   Save button to persist changes (currently in-memory).
*   **Live Preview:**
    *   Immediately see the saved text content in a read-only preview area below the editor.
*   **Image Drag & Drop:**
    *   Drag image files (PNG, JPG, GIF, WEBP, BMP) from your computer onto the designated image area.
    *   Images are immediately displayed as thumbnails for the selected category.
*   **Basic Two-Pane Layout:**
    *   Resizable (implicitly via `Expanded`) content area.
    *   Clear separation between navigation (ToC) and content.

### Planned Features:

*   **Database Persistence:** Store all categories, text content, and image references (or data) in a database (e.g., PostgreSQL).
*   **Image Compression:** Automatically compress images upon dropping to save storage space.
*   **LLM Integration:**
    *   Chat interface to interact with configured LLMs.
    *   Context-aware LLM: Send current note text and images to the LLM.
    *   LLM-driven content modification (e.g., summarization, rephrasing, generating content based on prompts) via Function Calling/Tool Use.
    *   Multi-modal understanding (text, images, potentially audio).
*   **Rich Text Editing:** Replace the plain text editor with a rich text editor (e.g., using `flutter_quill`).
*   **ToC Management:** Implement adding, deleting, renaming, and reordering categories.
*   **Search Functionality:** Search across all notes and categories.
*   **Audio Support:** Ability to attach and potentially transcribe audio notes.
*   **Performance Optimizations:** Lazy loading, database indexing, efficient state management for large knowledge bases.

## Screenshots / Demo

*(Recommended: Add a screenshot or GIF of the app in action here)*

![App Screenshot Placeholder](placeholder.png) <!-- Replace placeholder.png -->

## Getting Started

### Prerequisites

*   Flutter SDK: Make sure you have the Flutter SDK installed. See [Flutter installation guide](https://docs.flutter.dev/get-started/install).
*   Target Platform: Currently designed for **Desktop** (Windows, macOS, Linux) due to the `desktop_drop` package. Mobile/Web would require different drag-and-drop handling.

### Installation & Running

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/knowledge-app.git # Replace with your repo URL
    cd knowledge-app
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run -d windows # or -d macos / -d linux
    ```

## Technology Stack

*   **Framework:** Flutter (v3.x.x or later)
*   **Language:** Dart
*   **UI:** Flutter Material Widgets
*   **Drag & Drop:** `desktop_drop` package
*   **File Handling:** `cross_file` package, `dart:io`
*   **State Management:** `StatefulWidget` (Basic - consider Provider/Riverpod/Bloc for scaling)
*   **(Planned) Database:** PostgreSQL
*   **(Planned) LLM:** OpenAI API / Google Gemini API / Anthropic Claude API

## Project Structure