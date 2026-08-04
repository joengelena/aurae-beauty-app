# Widget Conventions

## Keep Widgets Small

If a `build` method exceeds ~50 lines, split it into private widgets or extract a file into the matching `presentation/widgets/` subfolder (`common/`, `form_fields/`, `listing/`, `wardrobe/`, `profile/`, `scaffold/`).

## Prefer StatelessWidget

`StatelessWidget` by default. Reach for `StatefulWidget` only when you need:

- `initState` / `dispose` lifecycle hooks
- A `TextEditingController`, `FocusNode`, `ScrollController`, or `AnimationController`
- Local ephemeral UI state not worth putting in a provider (an expand/collapse toggle)

**Never use `StatefulWidget` just to kick off a provider fetch.** Use a post-frame callback (see below).

## const Everywhere

**Always use `const` constructors where possible.** This isn't style — a non-const `EdgeInsets.all(16)`, `TextStyle(...)`, or `BoxDecoration(...)` in `build` allocates a new object on every rebuild.

```dart
// ❌ new instance every rebuild
child: Padding(padding: EdgeInsets.all(16), ...)

// ✅ reused
child: const Padding(padding: EdgeInsets.all(16), ...)
```

Mark your own widget constructors `const` whenever all fields are final and known at compile time. Treat the linter's `prefer_const_constructors` warning as an error.

## Never Touch context Across an Async Gap

**Always check `mounted` after an `await` before using `context`.** This is the single most common crash source in this codebase's page code.

```dart
Future<void> _handleSubmit() async {
  await context.read<WardrobeProvider>().addDress(data);
  if (!mounted) return;              // required
  FeedbackHelpers.showSuccessSnackBar(context, 'Dress added');
  context.go('/wardrobe');
}
```

Same rule for `setState` — never call it after `dispose()`:

```dart
Future<void> _loadData() async {
  final data = await _service.fetch();
  if (!mounted) return;
  setState(() => _data = data);
}
```

## Always Dispose Controllers

`TextEditingController`, `FocusNode`, `ScrollController`, `AnimationController`, `PageController`, and any `StreamSubscription` must be disposed. Forgetting leaks memory and, for controllers attached to a live widget, throws after the page is popped.

```dart
class _AddDressPageState extends State<AddDressPage> {
  final _nameController = TextEditingController();
  final _brandFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _brandFocus.dispose();
    super.dispose();
  }
}
```

## Never await Inside build()

`build` is synchronous and runs constantly. Trigger the fetch from `initState` via the provider:

```dart
@override
void initState() {
  super.initState();
  SchedulerBinding.instance.addPostFrameCallback((_) {
    context.read<WardrobeProvider>().fetchDresses();
  });
}
```

The post-frame callback matters: calling `context.read` directly in `initState` runs before the widget is mounted into the tree.

`FutureBuilder` is acceptable for one-off async values that genuinely don't belong in a provider — but if the result is page state, it belongs in a provider.

## Rebuild Discipline

- **Never call `notifyListeners()` inside `build()`** — infinite rebuild loop.
- **Never use `context.watch()` outside `build()`** — throws at runtime. Use `context.read()` in callbacks, `initState`, and async methods.
- Use `Selector` over `Consumer` when a widget depends on one field. Rebuilding a whole page because an unrelated provider field changed is a performance bug.

## Reuse Before Building

Check `presentation/widgets/common/` and `form_fields/` before writing a new dialog, button, empty state, or input. See `ui-and-theming.md` for the full inventory.
