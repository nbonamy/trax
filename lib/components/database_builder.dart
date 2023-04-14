import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';

typedef DatabaseFuture<T> = Future<T> Function(TraxDatabase);
typedef DatabaseBuilderBuilder<T> = Widget Function(
  BuildContext,
  TraxDatabase,
  T,
);

class DatabaseBuilder<T> extends StatelessWidget {
  final DatabaseFuture<T> future;
  final DatabaseBuilderBuilder<T> builder;
  final T? cachedValue;
  final Widget? placeholder;
  const DatabaseBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.cachedValue,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TraxDatabase>(
      builder: (context, database, child) => FutureBuilder<T>(
        future:
            cachedValue == null ? future(database) : Future.value(cachedValue!),
        builder: (context, snapshot) {
          if (snapshot.hasData == false || snapshot.data == null) {
            return placeholder ?? Container();
          } else {
            return builder(context, database, snapshot.data as T);
          }
        },
      ),
    );
  }
}
