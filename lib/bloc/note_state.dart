import 'package:equatable/equatable.dart';
import '../models/note.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {
  const NoteInitial();
}

class NoteLoading extends NoteState {
  const NoteLoading();
}

class NoteLoaded extends NoteState {
  final List<Note> notes;
  final List<int> selectedNoteIds;
  final bool isSelectionMode;

  const NoteLoaded({
    required this.notes,
    this.selectedNoteIds = const [],
    this.isSelectionMode = false,
  });

  NoteLoaded copyWith({
    List<Note>? notes,
    List<int>? selectedNoteIds,
    bool? isSelectionMode,
  }) {
    return NoteLoaded(
      notes: notes ?? this.notes,
      selectedNoteIds: selectedNoteIds ?? this.selectedNoteIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  @override
  List<Object?> get props => [notes, selectedNoteIds, isSelectionMode];
}

class NoteError extends NoteState {
  final String message;

  const NoteError(this.message);

  @override
  List<Object?> get props => [message];
}

class NoteOperationSuccess extends NoteState {
  final String message;

  const NoteOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
