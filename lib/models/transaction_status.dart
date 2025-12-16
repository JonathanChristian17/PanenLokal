enum TransactionStatus {
  negotiating, // Sedang negosiasi
  success,     // Deal berhasil
  failed,      // Tidak jadi
  pending,     // Masih menunggu
}

// ✅ Extension untuk konversi string
extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.negotiating:
        return 'Negosiasi';
      case TransactionStatus.success:
        return 'Berhasil';
      case TransactionStatus.failed:
        return 'Gagal';
      case TransactionStatus.pending:
        return 'Menunggu';
    }
  }

  String get value {
    switch (this) {
      case TransactionStatus.negotiating:
        return 'negotiating';
      case TransactionStatus.success:
        return 'success';
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.pending:
        return 'pending';
    }
  }

  // ✅ Parse dari string (dari API)
  static TransactionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'negotiating':
        return TransactionStatus.negotiating;
      case 'success':
        return TransactionStatus.success;
      case 'failed':
        return TransactionStatus.failed;
      case 'pending':
        return TransactionStatus.pending;
      default:
        return TransactionStatus.negotiating;
    }
  }
}