import 'dart:async';
import 'package:fleet_monitoring_app/models/car_api_model.dart';
import 'package:fleet_monitoring_app/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class CarProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Moving', 'Parked'
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  int? _selectedCarId;

  // Getters
  List<Car> get cars => _cars;
  List<Car> get filteredCars => _filteredCars;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  int? get selectedCarId => _selectedCarId;

  Car? get selectedCar => _selectedCarId != null
      ? _cars.firstWhere((car) => car.id == _selectedCarId, orElse: () => _cars.first)
      : null;

  CarProvider() {
    _initProvider();
  }

  Future<void> _initProvider() async {
    // Load cached data (if any)
    await _loadCachedData();

    // Fetch fresh data
    await fetchCars();

    // Start periodic updates
    startPeriodicUpdates();
  }

  // Start periodic updates
  void startPeriodicUpdates() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds:5), (_) {
      fetchCars();
    });
  }

  // Stop periodic updates
  void stopPeriodicUpdates() {
    _refreshTimer?.cancel();
  }

  @override
  void dispose() {
    stopPeriodicUpdates();
    super.dispose();
  }

  // Fetch cars from API
  Future<void> fetchCars() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final cars = await _apiService.fetchCars();
      _cars = cars;
      _applyFilters();

      // Cache the data
      _cacheData();


    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply search and status filters
  void _applyFilters() {
    _filteredCars = _cars.where((car) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          car.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          car.id.toString().contains(_searchQuery);

      // Apply status filter
      final matchesStatus = _statusFilter == 'All' || car.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Update status filter
  void updateStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  // Select a car
  void selectCar(int id) {
    _selectedCarId = id;
    notifyListeners();
  }

  // Clear selected car
  void clearSelectedCar() {
    _selectedCarId = null;
    notifyListeners();
  }

  // Cache car data to local storage
  Future<void> _cacheData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carsJson = json.encode(_cars.map((car) => car.toJson()).toList());
      await prefs.setString('cached_cars', carsJson);
      await prefs.setString('last_updated', DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) {
        print('Error caching car data: $e');
      }
    }
  }

  // Load cached car data from local storage
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carsJson = prefs.getString('cached_cars');

      if (carsJson != null) {
        final List<dynamic> decoded = json.decode(carsJson);
        _cars = decoded.map((json) => Car.fromJson(json)).toList();
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cached data: $e');
      }
    }
  }
}