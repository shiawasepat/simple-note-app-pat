import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteRepository {
  static const String _notesKey = 'notes';
  static const String _nextIdKey = 'nextId';

  List<Note> _notes = [];
  int _nextId = 1;
  bool _isInitialized = false;

  // Initialize repository by loading data from persistent storage
  Future<void> _initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Load nextId
    _nextId = prefs.getInt(_nextIdKey) ?? 1;

    // Load notes
    final notesJson = prefs.getString(_notesKey);
    if (notesJson != null) {
      final List<dynamic> decodedList = jsonDecode(notesJson);
      _notes = decodedList.map((json) => Note.fromJson(json)).toList();
    } else {
      // Add sample data only if no data exists
      _notes = [
        Note(
          id: _nextId++,
          title: 'Welcome',
          body:
              'Welcome to the Note Taking App! Your notes are now saved permanently.',
        ),
        Note(
          id: _nextId++,
          title: 'Sample Note',
          body: 'This note will persist even after you close the app!',
        ),
      ];
      await _saveToPrefs();
    }

    _isInitialized = true;
  }

  // Save notes and nextId to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = jsonEncode(_notes.map((note) => note.toJson()).toList());
    await prefs.setString(_notesKey, notesJson);
    await prefs.setInt(_nextIdKey, _nextId);
  }

  Future<List<Note>> fetchNotes() async {
    await _initialize();
    return List.from(_notes);
  }

  Future<Note> addNote(String title, String body) async {
    await _initialize();
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
    );
    _notes.add(note);
    await _saveToPrefs();
    return note;
  }

  Future<Note> updateNote(int id, String title, String body) async {
    await _initialize();
    final index = _notes.indexWhere((note) => note.id == id);
    if (index == -1) {
      throw Exception('Note not found');
    }
    final updatedNote = _notes[index].copyWith(title: title, body: body);
    _notes[index] = updatedNote;
    await _saveToPrefs();
    return updatedNote;
  }

  Future<void> deleteNote(int id) async {
    await _initialize();
    _notes.removeWhere((note) => note.id == id);
    await _saveToPrefs();
  }

  Future<void> deleteNotes(List<int> ids) async {
    await _initialize();
    _notes.removeWhere((note) => ids.contains(note.id));
    await _saveToPrefs();
  }

  Future<Note?> getNoteById(int id) async {
    await _initialize();
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Optional: Clear all notes (useful for testing)
  Future<void> clearAllNotes() async {
    await _initialize();
    _notes.clear();
    _nextId = 1;
    await _saveToPrefs();
  }
}
