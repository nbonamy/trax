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
  final T? initialData;
  final Widget? placeholder;
  const DatabaseBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.initialData,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TraxDatabase>(
      builder: (context, database, child) => FutureBuilder<T>(
        future: future(database),
        initialData: initialData,
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
