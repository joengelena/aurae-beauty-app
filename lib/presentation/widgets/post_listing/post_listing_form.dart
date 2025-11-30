import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/post_listing/listing_info_fields.dart';
import 'package:motorix_app/presentation/widgets/post_listing/select_multiple_images.dart';
import 'package:motorix_app/presentation/widgets/post_listing/vehicle_info_fields.dart';
import 'package:motorix_app/presentation/widgets/post_listing/vehicle_info_optional_fields.dart';
import 'package:provider/provider.dart';

class PostListingForm extends StatefulWidget {
  const PostListingForm({super.key});

  @override
  State<PostListingForm> createState() => _PostListingFormState();
}

class _PostListingFormState extends State<PostListingForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToFirstError() async {
    // Allow time for validation error states to be applied
    await Future.delayed(Duration(milliseconds: 50));

    final formContext = _formKey.currentContext;
    if (formContext == null) return;

    final firstErrorField = _findFirstErrorField(formContext);
    if (firstErrorField == null) return;

    await _scrollToField(firstErrorField);
  }

  RenderBox? _findFirstErrorField(BuildContext formContext) {
    RenderBox? firstErrorField;

    void visitor(Element element) {
      if (element.widget is FormField) {
        final fieldState = element as StatefulElement;
        final state = fieldState.state;

        if (state is FormFieldState && state.hasError) {
          final renderObject = element.renderObject;
          if (renderObject is RenderBox && renderObject.attached) {
            firstErrorField ??= renderObject;
            return; // Found the first error, stop searching
          }
        }
      }
      element.visitChildElements(visitor);
    }

    formContext.visitChildElements(visitor);
    return firstErrorField;
  }

  Future<void> _scrollToField(RenderBox fieldRenderBox) async {
    try {
      final scrollableRenderBox =
          _scrollController.position.context.notificationContext
                  ?.findRenderObject()
              as RenderBox?;

      if (scrollableRenderBox == null) return;

      // Calculate field position relative to scrollable viewport
      final fieldGlobalPosition = fieldRenderBox.localToGlobal(Offset.zero);
      final scrollableGlobalPosition = scrollableRenderBox.localToGlobal(
        Offset.zero,
      );
      final relativePosition =
          fieldGlobalPosition.dy - scrollableGlobalPosition.dy;

      // Calculate target scroll with padding from top
      const topPadding = 150.0;
      final currentScroll = _scrollController.position.pixels;
      final targetScroll = currentScroll + relativePosition - topPadding;

      await _scrollController.animateTo(
        targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      // Fallback: scroll to top if calculation fails
      await _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PostListingProvider>();

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 32,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                VehicleInfoFields(),
                VehicleInfoOptionalFields(),
                ListingInfoFields(),
                SelectMultipleImages(),
                SizedBox(height: 20),
                FilledButton(
                  onPressed:
                      provider.isLoading
                          ? null // disables the button when loading
                          : () {
                            if (_formKey.currentState!.validate()) {
                              if (provider.imageBytesList.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please add at least one photo',
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                );
                                return;
                              }

                              provider.postListing();
                            } else {
                              // Validation failed, scroll to first error
                              _scrollToFirstError();
                            }
                          },
                  child:
                      provider.isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                          : Text('Submit listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
