const String recycleItemsTask = 'RecycleItems';

void applyItemFilters(Map<String, dynamic> config, Map<String, dynamic> items) {
  final tasks = config['tasks'] as List<Map<String, dynamic>>;
  final recycleTask =
      tasks.singleWhere((final m) => m['type'] == recycleItemsTask);

  final taskConfig = recycleTask['config']['item_filter'];

  items.forEach((final key, final value) {
    taskConfig[key] = {'keep': value};
  });
}
