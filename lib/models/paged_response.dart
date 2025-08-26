// Generic pagination wrapper for RM API
class PagedResponse<T> {
  final int? count;
  final int? pages;
  final String? next; // next URL or null
  final String? prev; // prev URL or null
  final List<T> results;

  PagedResponse({
    this.count,
    this.pages,
    this.next,
    this.prev,
    required this.results,
  });
}
