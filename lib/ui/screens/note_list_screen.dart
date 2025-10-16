import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/note_bloc.dart';
import '../../bloc/note_event.dart';
import '../../bloc/note_state.dart';
import 'note_detail_screen.dart';
import 'add_note_screen.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Note List'),
            actions: [
              if (state is NoteLoaded && !state.isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () {
                    context.read<NoteBloc>().add(const SelectAllNotes());
                  },
                ),
              if (state is NoteLoaded && state.isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<NoteBloc>().add(
                          DeleteMultipleNotes(state.selectedNoteIds),
                        );
                  },
                ),
              if (state is NoteLoaded && state.isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context.read<NoteBloc>().add(const ClearSelection());
                  },
                ),
            ],
          ),
          body: _buildBody(state),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNoteScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(NoteState state) {
    if (state is NoteLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is NoteLoaded) {
      if (state.notes.isEmpty) {
        return const Center(
          child: Text('No notes yet. Add one!'),
        );
      }
      return ListView.builder(
        itemCount: state.notes.length,
        itemBuilder: (context, index) {
          final note = state.notes[index];
          final isSelected = state.selectedNoteIds.contains(note.id);

          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.body),
            leading: state.isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      context.read<NoteBloc>().add(
                            ToggleNoteSelection(note.id),
                          );
                    },
                  )
                : null,
            onTap: () {
              if (state.isSelectionMode) {
                context.read<NoteBloc>().add(
                      ToggleNoteSelection(note.id),
                    );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(note: note),
                  ),
                );
              }
            },
          );
        },
      );
    } else if (state is NoteError) {
      return Center(
        child: Text('Error: ${state.message}'),
      );
    }
    return const Center(child: Text('Welcome! Load your notes.'));
  }
}
