import 'package:flutter_bloc/flutter_bloc.dart';
import 'note_event.dart';
import 'note_state.dart';
import '../repository/note_repository.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repository;

  NoteBloc({required this.repository}) : super(const NoteInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<DeleteMultipleNotes>(_onDeleteMultipleNotes);
    on<ToggleNoteSelection>(_onToggleNoteSelection);
    on<SelectAllNotes>(_onSelectAllNotes);
    on<ClearSelection>(_onClearSelection);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NoteState> emit) async {
    emit(const NoteLoading());
    try {
      final notes = await repository.fetchNotes();
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      emit(NoteError('Failed to load notes: ${e.toString()}'));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NoteState> emit) async {
    try {
      await repository.addNote(event.title, event.body);
      final notes = await repository.fetchNotes();
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      emit(NoteError('Failed to add note: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NoteState> emit) async {
    try {
      await repository.updateNote(event.id, event.title, event.body);
      final notes = await repository.fetchNotes();
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      emit(NoteError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    try {
      await repository.deleteNote(event.id);
      final notes = await repository.fetchNotes();
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      emit(NoteError('Failed to delete note: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMultipleNotes(
      DeleteMultipleNotes event, Emitter<NoteState> emit) async {
    try {
      await repository.deleteNotes(event.ids);
      final notes = await repository.fetchNotes();
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      emit(NoteError('Failed to delete notes: ${e.toString()}'));
    }
  }

  void _onToggleNoteSelection(
      ToggleNoteSelection event, Emitter<NoteState> emit) {
    if (state is NoteLoaded) {
      final currentState = state as NoteLoaded;
      final selectedIds = List<int>.from(currentState.selectedNoteIds);

      if (selectedIds.contains(event.noteId)) {
        selectedIds.remove(event.noteId);
      } else {
        selectedIds.add(event.noteId);
      }

      emit(currentState.copyWith(
        selectedNoteIds: selectedIds,
        isSelectionMode: selectedIds.isNotEmpty,
      ));
    }
  }

  void _onSelectAllNotes(SelectAllNotes event, Emitter<NoteState> emit) {
    if (state is NoteLoaded) {
      final currentState = state as NoteLoaded;
      final allIds = currentState.notes.map((note) => note.id).toList();
      emit(currentState.copyWith(
        selectedNoteIds: allIds,
        isSelectionMode: true,
      ));
    }
  }

  void _onClearSelection(ClearSelection event, Emitter<NoteState> emit) {
    if (state is NoteLoaded) {
      final currentState = state as NoteLoaded;
      emit(currentState.copyWith(
        selectedNoteIds: [],
        isSelectionMode: false,
      ));
    }
  }
}
