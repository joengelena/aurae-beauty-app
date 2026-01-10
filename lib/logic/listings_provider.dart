import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class ListingsProvider extends ChangeNotifier {
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
  final List<Listing> latestListings = [];
  final int limit = 10;
  int currentPage = 0;
  int totalPages = 1;
  int totalListings = 0;
  bool isLoading = false;
  bool isLoadingLatest = false;

  TextEditingController searchController = TextEditingController();

  String sortBy = 'uploadDateDesc';

  Map<String, String> equalFilters = {};

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
      final res = await ListingsServices().getAllListings(
        allQueries: {
          'limit': limit,
          'pageNumber': currentPage + 1,
          'searchString': searchController.text,
          'sortBy': sortBy,
          'status': 'active',
          ...getEqualFilters(),
        },
      );

      final fetchedListings =
          res.data.map((listing) {
            return Listing(
              id: listing.id,
              userIdFk: listing.userIdFk,
              status: listing.status,
              viewCount: listing.viewCount,
              previewImgUrl: listing.previewImgUrl,
              imageUrls: listing.imageUrls,
              location: listing.location,
              vehicleCondition: listing.vehicleCondition,
              originalPrice: listing.originalPrice,
              discountedPrice: listing.discountedPrice,
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
              isInWatchlist: listing.isInWatchlist,
            );
          }).toList();

      listings.addAll(fetchedListings);
      totalPages = res.totalPages;
      currentPage = res.pageNumber;
      totalListings = res.totalRows;
    } catch (e) {
      debugPrint('⚠️ Failed to fetch listings: $e');
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

  Future<void> fetchLatestListings() async {
    isLoadingLatest = true;
    notifyListeners();

    try {
      final res = await ListingsServices().getAllListings(
        allQueries: {
          'limit': 10,
          'pageNumber': 1,
          'sortBy': 'uploadDateDesc',
          'status': 'active',
        },
      );

      final fetchedListings = res.data
          .map((listing) {
            return Listing(
              id: listing.id,
              userIdFk: listing.userIdFk,
              status: listing.status,
              viewCount: listing.viewCount,
              previewImgUrl: listing.previewImgUrl,
              imageUrls: listing.imageUrls,
              location: listing.location,
              vehicleCondition: listing.vehicleCondition,
              originalPrice: listing.originalPrice,
              discountedPrice: listing.discountedPrice,
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
              isInWatchlist: listing.isInWatchlist,
            );
          })
          .toList();

      latestListings.clear();
      latestListings.addAll(fetchedListings);
    } catch (e) {
      debugPrint('⚠️ Failed to fetch latest listings: $e');
    } finally {
      isLoadingLatest = false;
      notifyListeners();
    }
  }

  void toggleWatchlistStatus(int listingId, bool newStatus) {
    // Update in main listings
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
        originalPrice: listings[index].originalPrice,
        discountedPrice: listings[index].discountedPrice,
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
    }

    // Update in latest listings
    final latestIndex = latestListings.indexWhere((listing) => listing.id == listingId);
    if (latestIndex != -1) {
      latestListings[latestIndex] = Listing(
        id: latestListings[latestIndex].id,
        userIdFk: latestListings[latestIndex].userIdFk,
        status: latestListings[latestIndex].status,
        viewCount: latestListings[latestIndex].viewCount,
        previewImgUrl: latestListings[latestIndex].previewImgUrl,
        imageUrls: latestListings[latestIndex].imageUrls,
        location: latestListings[latestIndex].location,
        vehicleCondition: latestListings[latestIndex].vehicleCondition,
        originalPrice: latestListings[latestIndex].originalPrice,
        discountedPrice: latestListings[latestIndex].discountedPrice,
        uploadDate: latestListings[latestIndex].uploadDate,
        description: latestListings[latestIndex].description,
        endDate: latestListings[latestIndex].endDate,
        make: latestListings[latestIndex].make,
        model: latestListings[latestIndex].model,
        year: latestListings[latestIndex].year,
        kilometers: latestListings[latestIndex].kilometers,
        fuelType: latestListings[latestIndex].fuelType,
        bodyType: latestListings[latestIndex].bodyType,
        driveType: latestListings[latestIndex].driveType,
        orcIncluded: latestListings[latestIndex].orcIncluded,
        numberPlate: latestListings[latestIndex].numberPlate,
        seats: latestListings[latestIndex].seats,
        doors: latestListings[latestIndex].doors,
        previousOwners: latestListings[latestIndex].previousOwners,
        color: latestListings[latestIndex].color,
        engineSize: latestListings[latestIndex].engineSize,
        transmission: latestListings[latestIndex].transmission,
        cylinders: latestListings[latestIndex].cylinders,
        regoExpiryDate: latestListings[latestIndex].regoExpiryDate,
        wofExpiryDate: latestListings[latestIndex].wofExpiryDate,
        isInWatchlist: newStatus,
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
