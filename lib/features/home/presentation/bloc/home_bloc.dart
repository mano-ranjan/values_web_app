import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeInitialized extends HomeEvent {}

class HomeNavigationChanged extends HomeEvent {
  final String section;

  const HomeNavigationChanged(this.section);

  @override
  List<Object> get props => [section];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String currentSection;

  const HomeLoaded({this.currentSection = 'Home'});

  @override
  List<Object> get props => [currentSection];
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialized>(_onHomeInitialized);
    on<HomeNavigationChanged>(_onHomeNavigationChanged);
  }

  void _onHomeInitialized(HomeInitialized event, Emitter<HomeState> emit) {
    emit(HomeLoading());
    emit(const HomeLoaded());
  }

  void _onHomeNavigationChanged(
    HomeNavigationChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeLoading());
    emit(HomeLoaded(currentSection: event.section));
  }
}
