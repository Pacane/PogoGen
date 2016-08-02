const String recycleItemsTask = 'ReycleItems';

void applyItemFilters(Map<String, dynamic> config, Map<String, dynamic> items) {
  final tasks = config['tasks'] as List<Map<String, dynamic>>;
  final recycleTask =
      tasks.singleWhere((final m) => m['type'] == recycleItemsTask);

  items.forEach((final key, final value) {
    recycleTask['key'] = {'keep': value};
  });
}
