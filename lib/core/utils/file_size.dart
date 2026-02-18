class FileSizeFormatter {
  static String formatFileSize(int bytes) {
    if (bytes < 0) return '0 B';
    if (bytes == 0) return '0 B';
    
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;
    const int tb = gb * 1024;
    
    if (bytes >= tb) {
      return '${(bytes / tb).toStringAsFixed(1)} TB';
    } else if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(1)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }
}

class FileSizeValidator {
  static bool isValid(int fileSizeInBytes, int allowableLimitInMB) {
    final allowableLimitInBytes = allowableLimitInMB * 1024 * 1024;
    return fileSizeInBytes <= allowableLimitInBytes;
  }
}
