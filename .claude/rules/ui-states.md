# Loading, Error & Empty States

Every page that loads data must handle all four states. **A page that only handles the success case is incomplete.**

## State Priority Order

Check in this order — the first match wins:

1. **Loading** — a progress indicator
2. **Error** — the message plus a retry action
3. **Empty** — `AppEmptyState`
4. **Success** — the data

## The Provider Contract

Providers in this codebase expose the state through three getters (see `state-management.md`):

```dart
bool get isLoading => _isLoading;
String get errorMessage => _errorMessage;   // '' when there's no error
bool get hasError => _errorMessage.isNotEmpty;
```

Note `errorMessage` is a **non-nullable String that is empty when fine** — check `hasError`, not `errorMessage != null`.

## The Pattern

```dart
Consumer<WardrobeProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.hasError) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        body: provider.errorMessage,
        action: FilledButton(
          onPressed: () => provider.fetchDresses(),
          child: const Text('Try again'),
        ),
      );
    }
    if (provider.dresses.isEmpty) {
      return AppEmptyState(
        icon: Icons.checkroom_outlined,
        title: 'Your wardrobe is empty',
        body: 'Add your first dress to start taking bookings.',
        action: FilledButton(
          onPressed: () => context.push('/wardrobe/add'),
          child: const Text('Add a dress'),
        ),
      );
    }
    return DressGrid(dresses: provider.dresses);
  },
)
```

## Rules

1. **Never show a blank screen.** Every state gets feedback.
2. **Never show a spinner with no way out.** If a fetch can fail, the error branch must exist.
3. **Every error state offers a retry** where retrying is meaningful.
4. **Never swallow an exception silently.** Every `catch` must rethrow, surface to state, or (at minimum) `debugPrint`. An empty `catch {}` is always wrong.
5. **Never show a raw exception to the user.** `AppException.message` is already written in plain language — show that, not `e.toString()`.

```dart
// ❌ leaks internals
body: e.toString()

// ✅ the message the service already wrote for humans
body: provider.errorMessage
```

## Empty vs Error Are Not the Same

An empty list is a success. Don't render "Something went wrong" when the boutique simply has no dresses yet — the empty state is an opportunity to point at the next action.

## Snackbars for Mutations, Inline State for Loads

- **Loads** (fetching a page's data) → inline loading/error/empty, as above.
- **Mutations** (add, update, delete) → the provider rethrows, the page catches and calls `FeedbackHelpers.showErrorSnackBar` / `showSuccessSnackBar`. Don't replace the whole page with an error view because one save failed.

Use `LoadingButton` (`widgets/common/`) for submit buttons so the in-flight state is visible without blanking the form.

## Known Gap

There is **no shared `LoadingIndicator` or `ErrorView` widget** — 15+ pages hand-roll `Center(child: CircularProgressIndicator())` and their own error layouts. `AppEmptyState` exists and should be used for both the empty and error branches until dedicated widgets are added.

If you're touching several pages' state handling, adding `LoadingIndicator` and `ErrorView` to `widgets/common/` is a worthwhile cleanup — but don't do it as a drive-by on an unrelated change.
