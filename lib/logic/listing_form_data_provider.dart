import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/logic/form_data_provider.dart';

/// Interface for providers that manage listing form data.
///
/// This interface enables form field widgets to work with both
/// post and edit listing providers without coupling to specific implementations.
///
/// Implementations:
/// - [PostListingProvider] - For creating new listings
/// - [EditListingProvider] - For updating existing listings
abstract class ListingFormDataProvider implements FormDataProvider {
  /// Available listing attributes for dropdown fields.
  ///
  /// Contains options like vehicle makes, body types, fuel types, etc.
  /// Loaded asynchronously from the API.
  List<ListingAttribute> get listingAttributeOptions;
}
