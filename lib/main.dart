
import 'dart:io'; // Needed for File operations (Desktop/Mobile)
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart'; // For XFile from desktop_drop

// --- Data Model ---
class Category {
  final String id; // Unique ID for the category
  final String name;
  final List<Category> children;
  String content; // Text content associated with this category
  List<String> imagePaths; // Store paths to dropped images

  Category({
    required this.id,
    required this.name,
    this.children = const [],
    this.content = '',
    List<String>? initialImagePaths,
  }) : imagePaths = initialImagePaths ?? [];

  // Helper to find a category by ID recursively (needed for updates)
  static Category? findById(List<Category> categories, String id) {
    for (var category in categories) {
      if (category.id == id) {
        return category;
      }
      final foundInChildren = findById(category.children, id);
      if (foundInChildren != null) {
        return foundInChildren;
      }
    }
    return null;
  }
}

// --- Dummy Data ---
// Represents the initial state or data loaded from a source
final List<Category> initialCategories = [
  Category(id: 'proj', name: 'Projects', children: [
    Category(id: 'proj-alpha', name: 'Alpha', content: 'Notes for Project Alpha.'),
    Category(id: 'proj-beta', name: 'Beta', children: [
      Category(id: 'proj-beta-ui', name: 'UI/UX', content: 'Mockup links and feedback.'),
      Category(id: 'proj-beta-backend', name: 'Backend', content: 'API specs.'),
    ]),
  ]),
  Category(id: 'notes', name: 'General Notes', content: 'Random thoughts go here.'),
  Category(id: 'research', name: 'Research', children: [
    Category(id: 'research-ai', name: 'AI/ML', content: 'Interesting papers and articles.'),
  ]),
];

// --- Main App Widget ---
void main() {
  runApp(const KnowledgeApp());
}

class KnowledgeApp extends StatelessWidget {
  const KnowledgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knowledge Organizer',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Changed theme color
        useMaterial3: true, // Use Material 3 design
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define consistent styling for selection
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo).copyWith(
          primaryContainer: Colors.indigo.shade100, // Color for selected background
          onPrimaryContainer: Colors.indigo.shade900, // Color for selected text/icon
        ),
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Main Page (Stateful) ---
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Holds the current state of the categories (mutable)
  late List<Category> _categories;
  String? _selectedCategoryId; // ID of the currently selected category
  Category? _selectedCategory; // The actual selected category object

  final TextEditingController _textEditingController = TextEditingController();
  bool _isDragging = false; // For visual feedback on drop zone

  @override
  void initState() {
    super.initState();
    // Initialize state with a deep copy of initial data if needed,
    // but for this example, we'll modify the initial list directly.
    _categories = initialCategories;
    // Optionally select the first item or leave null
    // if (_categories.isNotEmpty) {
    //   _selectCategory(_categories.first);
    // }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  // --- Methods ---

  void _selectCategory(Category category) {
    setState(() {
      _selectedCategoryId = category.id;
      _selectedCategory = category;
      _textEditingController.text = category.content; // Load content into editor
      _isDragging = false; // Reset drag state on selection change
    });
  }

  void _saveContent() {
    if (_selectedCategory != null) {
      setState(() {
        // Find the category in our state list and update it
        // This is crucial if _categories is a deep copy or fetched data
        final categoryToUpdate = Category.findById(_categories, _selectedCategory!.id);
        if (categoryToUpdate != null) {
          categoryToUpdate.content = _textEditingController.text;
          // Update the _selectedCategory reference as well, in case it's needed directly
          _selectedCategory = categoryToUpdate;
        } else {
          // Handle case where category might have been deleted elsewhere
          print("Error: Could not find category with ID ${_selectedCategory!.id} to save.");
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content saved!'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _handleDrop(DropDoneDetails details) {
    if (_selectedCategory == null) return;

    final imageFiles = details.files.where((file) {
      // Basic image extension check (add more if needed: webp, bmp, etc.)
      final pathLower = file.path.toLowerCase();
      return pathLower.endsWith('.png') ||
          pathLower.endsWith('.jpg') ||
          pathLower.endsWith('.jpeg') ||
          pathLower.endsWith('.gif');
    }).toList();

    if (imageFiles.isNotEmpty) {
      setState(() {
        final categoryToUpdate = Category.findById(_categories, _selectedCategory!.id);
        if (categoryToUpdate != null) {
          categoryToUpdate.imagePaths.addAll(imageFiles.map((file) => file.path));
          _selectedCategory = categoryToUpdate; // Update reference
        }
        _isDragging = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${imageFiles.length} image(s) added.'), duration: Duration(seconds: 2)),
      );
    } else {
       setState(() => _isDragging = false);
    }
  }

  // --- UI Building ---

  // Recursive function to build the ToC list widgets
  List<Widget> _buildTocWidgets(List<Category> categories, int level) {
    const double indentSize = 20.0; // Pixels per indentation level
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return categories.map((category) {
      final bool isSelected = category.id == _selectedCategoryId;
      final double currentIndent = level * indentSize;

      // Style for selected items
      final selectedStyle = TextStyle(
        fontWeight: FontWeight.w600, // Slightly bolder
        color: colorScheme.onPrimaryContainer,
      );
      final selectedTileColor = colorScheme.primaryContainer;

      if (category.children.isEmpty) {
        // Leaf Node: ListTile
        return Padding(
          padding: EdgeInsets.only(left: currentIndent),
          child: ListTile(
            title: Text(category.name, style: isSelected ? selectedStyle : null),
            selected: isSelected,
            selectedTileColor: selectedTileColor,
            dense: true,
            onTap: () => _selectCategory(category),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Standard padding
          ),
        );
      } else {
        // Branch Node: ExpansionTile
        return Padding(
          padding: EdgeInsets.only(left: currentIndent),
          child: ExpansionTile(
            key: PageStorageKey(category.id), // Preserve expansion state
            // Make the title area itself selectable
            title: InkWell(
              onTap: () => _selectCategory(category),
              child: Container(
                width: double.infinity, // Take full width for tap area
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                color: isSelected ? selectedTileColor.withOpacity(0.5) : Colors.transparent, // Subtle highlight if selected
                child: Text(category.name, style: isSelected ? selectedStyle : null),
              ),
            ),
            // Remove default padding to align InkWell correctly
            tilePadding: const EdgeInsets.only(right: 16.0), // Only keep padding for the icon
            childrenPadding: EdgeInsets.zero, // Children handle their own padding
            // Recursively build children
            children: _buildTocWidgets(category.children, level + 1),
            // Align icon nicely
            controlAffinity: ListTileControlAffinity.trailing,
            // Optional: Initially expand selected parent?
            // initiallyExpanded: isSelected, // Can be complex if deep nesting
          ),
        );
      }
    }).toList();
  }

  // Builds the image display area
  Widget _buildImageDisplayArea() {
    if (_selectedCategory == null || _selectedCategory!.imagePaths.isEmpty) {
      // Show placeholder if no images or nothing selected
      return const Center(
        child: Text('No images yet. Drag files here.', style: TextStyle(color: Colors.grey)),
      );
    }

    // Display images in a scrollable Wrap layout
    return SingleChildScrollView( // Allow scrolling if many images
      child: Wrap(
        spacing: 8.0, // Horizontal gap
        runSpacing: 8.0, // Vertical gap
        children: _selectedCategory!.imagePaths.map((path) {
          try {
            final file = File(path);
            // Basic check if file seems to exist (can still fail to load)
            if (!file.existsSync()) {
               print("Warning: Image file not found at $path");
               return Container(width: 100, height: 100, color: Colors.red.shade100, child: const Tooltip(message: 'File not found', child: Icon(Icons.error_outline)));
            }
            return SizedBox(
              width: 100, // Thumbnail size
              height: 100,
              child: Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading image $path: $error");
                  return Container(color: Colors.grey.shade300, child: const Tooltip(message: 'Cannot load image', child: Icon(Icons.broken_image)));
                },
              ),
            );
          } catch (e) {
             print("Error accessing file $path: $e");
             return Container(width: 100, height: 100, color: Colors.orange.shade100, child: Tooltip(message: 'Error: $e', child: const Icon(Icons.warning_amber)));
          }
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme for consistent styling

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Hub'),
        backgroundColor: theme.colorScheme.primaryContainer, // Use theme color
        // Add actions later (e.g., Add Category)
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align tops
        children: [
          // --- Left Panel: Table of Contents ---
          Container(
            width: 280, // Adjust width as needed
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: theme.dividerColor)),
              color: theme.canvasColor, // Use theme background
            ),
            child: ListView(
              padding: const EdgeInsets.only(top: 8.0), // Add some top padding
              children: _buildTocWidgets(_categories, 0), // Start ToC build
            ),
          ),

          // --- Right Panel: Content ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _selectedCategory == null
                  ? const Center(child: Text('Select an item from the left.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Title and Save Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategory!.name,
                              style: theme.textTheme.headlineSmall,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save'),
                              onPressed: _saveContent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),

                        // Text Editor (Flexible height)
                        Expanded(
                          flex: 3, // Give editor more space
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextField(
                              controller: _textEditingController,
                              maxLines: null, // Allow infinite lines
                              expands: true, // Fill available space
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                hintText: 'Enter your notes...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Preview Area (Read-only display of saved content)
                        Text('Preview:', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4.0),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 60, maxHeight: 150), // Limit preview height
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.5), // Subtle background
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                          ),
                          child: SingleChildScrollView( // Scroll if content overflows
                            child: Text(_selectedCategory?.content ?? ''),
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Image Drop Zone & Display (Flexible height)
                        Text('Images:', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8.0),
                        Expanded(
                          flex: 2, // Give image area reasonable space
                          child: DropTarget(
                            onDragDone: _handleDrop,
                            onDragEntered: (details) => setState(() => _isDragging = true),
                            onDragExited: (details) => setState(() => _isDragging = false),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: _isDragging
                                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                                    : theme.colorScheme.surfaceVariant.withOpacity(0.3), // Use theme colors
                                border: Border.all(
                                  color: _isDragging ? theme.colorScheme.primary : theme.dividerColor,
                                  width: _isDragging ? 2.0 : 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: _buildImageDisplayArea(), // Display images or placeholder
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
