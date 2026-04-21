import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_service_app/core/services/providers.dart';

// ── Placeholder entities until full Home feature is built ────────────────────

class CategoryEntity {
  const CategoryEntity({required this.id, required this.name, required this.icon, required this.color});
  final String id;
  final String name;
  final String icon;
  final int color;
}

class ServiceEntity {
  const ServiceEntity({
    required this.id, required this.name, required this.categoryId,
    required this.price, this.imageUrl, this.rating,
  });
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final String? imageUrl;
  final double? rating;
}

class ProviderEntity {
  const ProviderEntity({
    required this.id, required this.name, required this.category,
    this.avatarUrl, this.rating, this.distance,
  });
  final String id;
  final String name;
  final String category;
  final String? avatarUrl;
  final double? rating;
  final String? distance;
}

class BookingEntity {
  const BookingEntity({required this.id, required this.service, required this.status, required this.date});
  final String id;
  final String service;
  final String status;
  final DateTime date;
}

// ── Home State ────────────────────────────────────────────────────────────────

class HomeState {
  const HomeState({
    this.isLoading = false,
    this.categories = const [],
    this.featuredServices = const [],
    this.nearbyProviders = const [],
    this.activeBookings = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<CategoryEntity> categories;
  final List<ServiceEntity> featuredServices;
  final List<ProviderEntity> nearbyProviders;
  final List<BookingEntity> activeBookings;
  final String? errorMessage;

  HomeState copyWith({
    bool? isLoading,
    List<CategoryEntity>? categories,
    List<ServiceEntity>? featuredServices,
    List<ProviderEntity>? nearbyProviders,
    List<BookingEntity>? activeBookings,
    String? errorMessage,
  }) =>
      HomeState(
        isLoading: isLoading ?? this.isLoading,
        categories: categories ?? this.categories,
        featuredServices: featuredServices ?? this.featuredServices,
        nearbyProviders: nearbyProviders ?? this.nearbyProviders,
        activeBookings: activeBookings ?? this.activeBookings,
        errorMessage: errorMessage,
      );
}

// ── Home Notifier ─────────────────────────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier({required this.apiClient}) : super(const HomeState());

  final dynamic apiClient;

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);
    // ✅ Fixed: 1500ms allows the shimmer animation (1500ms duration) to actually be seen
    await Future.delayed(const Duration(milliseconds: 1500)); 
    
    // Mock data
    if (!mounted) return;
    state = state.copyWith(
      isLoading: false,
      categories: const [
        CategoryEntity(id: '1', name: 'Plumbing', icon: '🔧', color: 0xFF6C63FF),
        CategoryEntity(id: '2', name: 'Cleaning', icon: '🧹', color: 0xFF00D4AA),
        CategoryEntity(id: '3', name: 'Electrical', icon: '⚡', color: 0xFFFF6B6B),
        CategoryEntity(id: '4', name: 'Carpenter', icon: '🔨', color: 0xFFF59E0B),
        CategoryEntity(id: '5', name: 'Painter', icon: '🎨', color: 0xFF8B5CF6),
        CategoryEntity(id: '6', name: 'AC Repair', icon: '❄️', color: 0xFF3B82F6),
      ],
      featuredServices: const [
        ServiceEntity(id: 's1', name: 'Pipe Fixing', categoryId: '1', price: 299, rating: 4.8),
        ServiceEntity(id: 's2', name: 'Deep Cleaning', categoryId: '2', price: 599, rating: 4.9),
        ServiceEntity(id: 's3', name: 'Wiring & Fitting', categoryId: '3', price: 399, rating: 4.7),
      ],
      nearbyProviders: const [
        ProviderEntity(id: 'p1', name: 'Rahul Kumar', category: 'Plumber', rating: 4.8, distance: '0.5'),
        ProviderEntity(id: 'p2', name: 'Priya Sharma', category: 'Cleaner', rating: 4.9, distance: '1.2'),
        ProviderEntity(id: 'p3', name: 'Amit Singh', category: 'Electrician', rating: 4.7, distance: '2.0'),
      ],
    );
  }
}

final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(apiClient: ref.watch(apiClientProvider));
});
