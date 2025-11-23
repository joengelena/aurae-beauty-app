import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/logic/watchlist_provider.dart';

class ListingsProvider extends ChangeNotifier {
  final WatchlistProvider? watchlistProvider;

  ListingsProvider({this.watchlistProvider});

  final Map<String, String> sortByOptions = {
    'Highest price': 'priceDesc',
    'Lowest price': 'priceAsc',
    'Latest listings': 'uploadDateDesc',
    'Oldest listings': 'uploadDateAsc',
    'Highest kilometers': 'kilometersDesc',
    'Lowest kilometers': 'kilometersAsc',
    'Latest year': 'yearDesc',
    'Oldest year': 'yearAsc',
  };
  final List<Listing> listings = [];
  final int limit = 10;
  int currentPage = 0;
  int totalPages = 1;
  int totalListings = 0;
  bool isLoading = false;

  TextEditingController searchController = TextEditingController();

  String sortBy = 'uploadDateDesc';

  Map<String, String> equalFilters = {};

  Map<String, dynamic> get searchParams => {
    'searchString': searchController.text,
    'sortBy': sortBy,
    ...getEqualFilters(),
  };

  bool get onLastPage => currentPage >= totalPages;
  bool get canLoadMore => !onLastPage && !isLoading;

  Future<void> getNewListings() async {
    listings.clear();
    currentPage = 0;

    isLoading = true;
    notifyListeners();

    await fetchListings();
    return;
  }

  Future<void> getMoreListings() async {
    isLoading = true;
    notifyListeners();
    await fetchListings();
    return;
  }

  Future<void> fetchListings() async {
    try {
      final resp = await ListingsServices().getAllListings(
        allQueries: {
          'limit': limit,
          'pageNumber': currentPage + 1,
          'searchString': searchController.text,
          'sortBy': sortBy,
          'status': 'active',
          ...getEqualFilters(),
        },
      );

      // Set isInWatchlist flag based on watchlistProvider
      final fetchedListings = resp.data.map((listing) {
        final isInWatchlist = watchlistProvider?.isInWatchlist(listing.id) ?? false;
        return Listing(
          id: listing.id,
          userIdFk: listing.userIdFk,
          status: listing.status,
          viewCount: listing.viewCount,
          previewImgUrl: listing.previewImgUrl,
          imageUrls: listing.imageUrls,
          location: listing.location,
          vehicleCondition: listing.vehicleCondition,
          price: listing.price,
          uploadDate: listing.uploadDate,
          description: listing.description,
          endDate: listing.endDate,
          make: listing.make,
          model: listing.model,
          year: listing.year,
          kilometers: listing.kilometers,
          fuelType: listing.fuelType,
          bodyType: listing.bodyType,
          driveType: listing.driveType,
          orcIncluded: listing.orcIncluded,
          numberPlate: listing.numberPlate,
          seats: listing.seats,
          doors: listing.doors,
          previousOwners: listing.previousOwners,
          color: listing.color,
          engineSize: listing.engineSize,
          transmission: listing.transmission,
          cylinders: listing.cylinders,
          regoExpiryDate: listing.regoExpiryDate,
          wofExpiryDate: listing.wofExpiryDate,
          isInWatchlist: isInWatchlist,
        );
      }).toList();

      listings.addAll(fetchedListings);
      totalPages = resp.totalPages;
      currentPage = resp.pageNumber;
      totalListings = resp.totalRows;
    } catch (e) {
      // Silently handle listing loading errors
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, String> getEqualFilters() {
    final Map<String, String> queryFilterOptions = {
      'make': 'make',
      'location': 'location',
      'vehicle_condition': 'vehicleCondition',
      'fuel_type': 'fuelType',
      'body_type': 'bodyType',
      'drive_type': 'driveType',
      'transmission': 'transmission',
      'cylinders': 'cylinders',
    };

    return Map.fromEntries(
      equalFilters.entries
          .where((entry) => entry.value != 'None')
          .map((e) => MapEntry(queryFilterOptions[e.key]!, e.value)),
    );
  }

  void applyFilters(Map<String, String> newEqualFilters) {
    equalFilters = Map.from(newEqualFilters);
    getNewListings();
  }

  void toggleWatchlistStatus(int listingId, bool newStatus) {
    final index = listings.indexWhere((listing) => listing.id == listingId);
    if (index != -1) {
      listings[index] = Listing(
        id: listings[index].id,
        userIdFk: listings[index].userIdFk,
        status: listings[index].status,
        viewCount: listings[index].viewCount,
        previewImgUrl: listings[index].previewImgUrl,
        imageUrls: listings[index].imageUrls,
        location: listings[index].location,
        vehicleCondition: listings[index].vehicleCondition,
        price: listings[index].price,
        uploadDate: listings[index].uploadDate,
        description: listings[index].description,
        endDate: listings[index].endDate,
        make: listings[index].make,
        model: listings[index].model,
        year: listings[index].year,
        kilometers: listings[index].kilometers,
        fuelType: listings[index].fuelType,
        bodyType: listings[index].bodyType,
        driveType: listings[index].driveType,
        orcIncluded: listings[index].orcIncluded,
        numberPlate: listings[index].numberPlate,
        seats: listings[index].seats,
        doors: listings[index].doors,
        previousOwners: listings[index].previousOwners,
        color: listings[index].color,
        engineSize: listings[index].engineSize,
        transmission: listings[index].transmission,
        cylinders: listings[index].cylinders,
        regoExpiryDate: listings[index].regoExpiryDate,
        wofExpiryDate: listings[index].wofExpiryDate,
        isInWatchlist: newStatus,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
