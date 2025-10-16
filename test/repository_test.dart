import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/repository/note_repository.dart';

void main() {
  group('NoteRepository Persistence Tests', () {
    setUp(() async {
      // Initialize SharedPreferences with mock values
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and load notes from SharedPreferences', () async {
      // Create repository and add a note
      final repo = NoteRepository();

      // Add a note
      await repo.addNote('Test Title', 'Test Body');

      // Verify note was added
      final notes = await repo.fetchNotes();
      expect(notes.length, greaterThan(0));

      // Check if note exists with correct data
      final testNote = notes.firstWhere(
        (note) => note.title == 'Test Title',
      );
      expect(testNote.body, 'Test Body');
    });

    test('should persist notes across repository instances', () async {
      // First repository - add a note
      final repo1 = NoteRepository();
      await repo1.addNote('Persistent Note', 'This should persist');

      // Create new repository instance (simulates app restart)
      final repo2 = NoteRepository();
      final notes = await repo2.fetchNotes();

      // Verify note persisted
      final persistentNote = notes.firstWhere(
        (note) => note.title == 'Persistent Note',
        orElse: () => throw Exception('Note not found - persistence failed!'),
      );
      expect(persistentNote.body, 'This should persist');
    });

    test('should update and persist note changes', () async {
      final repo = NoteRepository();

      // Add initial note
      final note = await repo.addNote('Original Title', 'Original Body');

      // Update the note
      await repo.updateNote(note.id, 'Updated Title', 'Updated Body');

      // Create new repository to verify persistence
      final repo2 = NoteRepository();
      final notes = await repo2.fetchNotes();

      final updatedNote = notes.firstWhere((n) => n.id == note.id);
      expect(updatedNote.title, 'Updated Title');
      expect(updatedNote.body, 'Updated Body');
    });

    test('should delete and persist note removal', () async {
      final repo = NoteRepository();

      // Add a note
      final note = await repo.addNote('To Delete', 'Delete this');
      final initialCount = (await repo.fetchNotes()).length;

      // Delete the note
      await repo.deleteNote(note.id);

      // Verify deletion persisted
      final repo2 = NoteRepository();
      final notes = await repo2.fetchNotes();

      expect(notes.length, initialCount - 1);
      expect(
        notes.any((n) => n.id == note.id),
        false,
        reason: 'Deleted note should not exist',
      );
    });

    test('should clear all notes', () async {
      final repo = NoteRepository();

      // Add multiple notes
      await repo.addNote('Note 1', 'Body 1');
      await repo.addNote('Note 2', 'Body 2');
      await repo.addNote('Note 3', 'Body 3');

      // Clear all notes
      await repo.clearAllNotes();

      // Verify all notes cleared
      final notes = await repo.fetchNotes();
      expect(notes.length, 0);

      // Verify persistence of empty state
      final repo2 = NoteRepository();
      final notesAfterRestart = await repo2.fetchNotes();
      expect(notesAfterRestart.length, 0);
    });
  });
}
