import 'dart:async';

/// Emits whenever any source emits, once all three have produced a value.
///
/// Drift gives one stream per query, and the active-session screen needs the
/// session row, its exercise list and its sets to move together — this keeps
/// them in one emission instead of three rebuilds.
Stream<T> combineLatest3<A, B, C, T>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  T Function(A, B, C) combine,
) {
  late StreamController<T> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  StreamSubscription<C>? subC;

  A? latestA;
  B? latestB;
  C? latestC;
  var hasA = false;
  var hasB = false;
  var hasC = false;

  void emit() {
    if (!hasA || !hasB || !hasC) return;
    if (controller.isClosed) return;
    controller.add(combine(latestA as A, latestB as B, latestC as C));
  }

  void onError(Object error, StackTrace stack) {
    if (!controller.isClosed) controller.addError(error, stack);
  }

  controller = StreamController<T>(
    onListen: () {
      subA = a.listen((v) {
        latestA = v;
        hasA = true;
        emit();
      }, onError: onError);
      subB = b.listen((v) {
        latestB = v;
        hasB = true;
        emit();
      }, onError: onError);
      subC = c.listen((v) {
        latestC = v;
        hasC = true;
        emit();
      }, onError: onError);
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
      await subC?.cancel();
    },
  );

  return controller.stream;
}
