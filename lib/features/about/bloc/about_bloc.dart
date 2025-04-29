import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/about_repository.dart';
import '../models/about_content.dart';

part 'about_event.dart';
part 'about_state.dart';

class AboutBloc extends Bloc<AboutEvent, AboutState> {
  final AboutRepository _aboutRepository;

  AboutBloc(this._aboutRepository) : super(AboutInitial()) {
    on<LoadAboutData>(_onLoadAboutData);
  }

  Future<void> _onLoadAboutData(
    LoadAboutData event,
    Emitter<AboutState> emit,
  ) async {
    emit(AboutLoading());
    try {
      final content = await _aboutRepository.getAboutContent();
      emit(AboutLoaded(content));
    } catch (e) {
      emit(AboutError(e.toString()));
    }
  }
}
