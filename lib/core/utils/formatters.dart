class AppFormatters {
  static String money(num val) => '₹${val.toStringAsFixed(val % 1 == 0 ? 0 : 2)}';

  static String compact(num val) {
    if (val >= 100000) return '${(val / 100000).toStringAsFixed(1)}L';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}K';
    return val.toString();
  }
}
