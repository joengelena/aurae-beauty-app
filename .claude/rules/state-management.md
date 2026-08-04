# State Management Rules

Provider (`ChangeNotifier`) is the state management for this project.

## Hard Rules

1. **NEVER introduce Riverpod, Bloc, Redux, GetX, or MobX.** If a state problem feels like it needs another library, it needs a better-shaped provider.

2. **NEVER call a service from a widget.** The flow is one-directional:

   ```
   Page/Widget → Provider → Service → ApiClient
   ```

   A page reads state and calls provider methods. Nothing else.

3. **NEVER let a service import a provider.** `data/` must not depend on `logic/`. If a service seems to need provider state, pass it in as an argument.

4. **NEVER call `notifyListeners()` inside `build()`** or synchronously during a widget lifecycle callback without a post-frame callback.

5. **ALWAYS register new providers in `main.dart`.** If the provider holds user-scoped data, use `ChangeNotifierProxyProvider<AuthProvider, X>` and implement `updateAuthStatus`.

## The Standard Provider Shape

Every user-scoped provider follows this pattern. Match it.

```dart
class WardrobeProvider extends ChangeNotifier {
  final DressServices _dressServices = DressServices();

  List<BusinessDress> _dresses = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSignedIn = false;

  // Expose state read-only — never hand out the mutable list
  List<BusinessDress> get dresses => List.unmodifiable(_dresses);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Called by ChangeNotifierProxyProvider — reset on sign-out
  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      reset();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> fetchDresses() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _dresses = await _dressServices.getAllDresses();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while loading your dresses.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## Read vs Fetch — Two Error Conventions

Deliberate split. Follow it:

- **Fetch/load methods** — swallow the exception, store it in `_errorMessage`, and `notifyListeners()`. The page renders an error state.
- **Mutation methods** (add/update/delete) — `rethrow` so the calling page can show a snackbar or keep the user on the form.

```dart
Future<void> addDress(Map<String, dynamic> dressData) async {
  try {
    await _dressServices.addDress(dressData);
    await fetchDresses();          // refresh after mutation
  } on AppException {
    rethrow;                        // page handles the feedback
  } catch (e) {
    throw AppException('Failed to add dress: ${e.toString()}');
  }
}
```

## Derived State Belongs in Getters

Filter and compute in the provider, not the widget:

```dart
List<BusinessDress> get activeDresses =>
    _dresses.where((d) => d.status != 'sold').toList();
List<BusinessDress> get soldDresses =>
    _dresses.where((d) => d.status == 'sold').toList();
```

## Never Expose Mutable Collections

Return `List.unmodifiable(...)` from list getters. Handing out the internal list lets a widget mutate provider state without a `notifyListeners()`, which produces UI that is silently out of date.

## Consuming in Widgets

- `context.watch<X>()` / `Consumer<X>` — when the widget should rebuild.
- `context.read<X>()` — in callbacks, `initState`, and async methods. **Never in `build`.**
- `Selector<X, T>` — when a large widget only depends on one field.

`context.watch()` outside `build()` throws at runtime:

```dart
// ❌ crashes
void initState() {
  context.watch<WardrobeProvider>().fetchDresses();
}

// ✅ post-frame callback, so the widget is mounted
@override
void initState() {
  super.initState();
  SchedulerBinding.instance.addPostFrameCallback((_) {
    context.read<WardrobeProvider>().fetchDresses();
  });
}
```

## Selector Over Consumer for Single Fields

```dart
// ❌ rebuilds the whole page when any WardrobeProvider field changes
Consumer<WardrobeProvider>(
  builder: (context, provider, _) => Text('${provider.dresses.length} dresses'),
)

// ✅ rebuilds only when the count changes
Selector<WardrobeProvider, int>(
  selector: (_, provider) => provider.dresses.length,
  builder: (context, count, _) => Text('$count dresses'),
)
```

Rebuilding an entire page because an unrelated field changed is a performance bug, not a style preference.
