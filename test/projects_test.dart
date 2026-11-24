import 'package:flutter_test/flutter_test.dart';
import 'package:fzy_portfolio/features/projects/data/local_project_repository.dart';
import 'package:fzy_portfolio/features/projects/presentation/providers/projects_provider.dart';

void main() {
  final provider = ProjectsProvider(const LocalProjectRepository());

  test('contains the five CV projects in order', () {
    expect(
      provider.projects.map((p) => p.id),
      ['ealzo', 'furnyshop', 'mindiko', 'washsouq', 'sharetok'],
    );
  });

  test('ids are unique and every project has content', () {
    final ids = provider.projects.map((p) => p.id).toSet();
    expect(ids.length, provider.projects.length);
    for (final p in provider.projects) {
      expect(p.contributions, isNotEmpty, reason: p.id);
      expect(p.technologies, isNotEmpty, reason: p.id);
      expect(p.keyFeatures, isNotEmpty, reason: p.id);
    }
  });

  test('spotlight is Ealzo and is excluded from others', () {
    expect(provider.spotlight.id, 'ealzo');
    expect(provider.others.any((p) => p.id == 'ealzo'), isFalse);
    expect(provider.others.length, 4);
  });

  test('only Ealzo links to an external website', () {
    expect(provider.byId('ealzo')?.websiteUrl, 'https://landing.ealzo.com/');
    expect(provider.projects.where((p) => p.hasWebsite).map((p) => p.id), ['ealzo']);
  });

  test('byId and next wrap around', () {
    expect(provider.byId('mindiko')?.name, 'Mindiko');
    expect(provider.byId('missing'), isNull);
    expect(provider.next(provider.projects.last).id, 'ealzo');
  });
}
