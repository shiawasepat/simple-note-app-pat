import 'package:equatable/equatable.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {
  const LoadNotes();
}

class AddNote extends NoteEvent {
  final String title;
  final String body;

  const AddNote({required this.title, required this.body});

  @override
  List<Object?> get props => [title, body];
}

class UpdateNote extends NoteEvent {
  final int id;
  final String title;
  final String body;

  const UpdateNote({
    required this.id,
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [id, title, body];
}

class DeleteNote extends NoteEvent {
  final int id;

  const DeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteMultipleNotes extends NoteEvent {
  final List<int> ids;

  const DeleteMultipleNotes(this.ids);

  @override
  List<Object?> get props => [ids];
}

class ToggleNoteSelection extends NoteEvent {
  final int noteId;

  const ToggleNoteSelection(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class SelectAllNotes extends NoteEvent {
  const SelectAllNotes();
}

class ClearSelection extends NoteEvent {
  const ClearSelection();
}
