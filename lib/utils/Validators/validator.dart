class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (value.trim().length > 100) {
      return 'Email length should not exceed 100 characters';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 8) {
      return 'Password length should be at least 8 characters';
    }
    if (value.trim().length > 16) {
      return 'Password length should not exceed 16 characters';
    }
    return null;
  }

  static String? newPassword(
    String? oldValue,
    String? newValue,
  ) {
    if (newValue == null || newValue.trim().isEmpty) {
      return 'New Password is required';
    } else if (oldValue == newValue) {
      return 'New password cannot be the same as the old password';
    }
    if (newValue.trim().length > 16) {
      return 'Password length should not exceed 16 characters';
    }
    return null;
  }

  static String? confirmPassword(
    String? value,
    String? confirmValue,
  ) {
    if (confirmValue == null || confirmValue.trim().isEmpty) {
      return 'Confirm Password is required';
    } else if (value != confirmValue.trim()) {
      return 'Passwords do not match';
    }
    if (confirmValue.trim().length > 16) {
      return 'Password length should not exceed 16 characters';
    }
    return null;
  }

  // ---------------- NAME ----------------
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length > 100) {
      return 'Name length should not exceed 100 characters';
    }

    if (value.trim().length < 3) {
      return 'Name length should be at least 3 characters';
    }

    final hasLetterOrNumber = RegExp(r'[\p{L}\p{N}]', unicode: true);

    if (!hasLetterOrNumber.hasMatch(value.trim())) {
      return 'Invalid character used in name';
    }

    return null;
  }

  // ---------------- ADDRESS ----------------
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.trim().length < 3) {
      return 'Address length should be at least 3 characters';
    }

    final hasLetterOrNumber = RegExp(r'[\p{L}\p{N}]', unicode: true);

    if (!hasLetterOrNumber.hasMatch(value.trim())) {
      return 'Invalid character used in address';
    }

    return null;
  }

  // ---------------- PHONE NUMBER ----------------
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    } else if (value.trim().length != 10) {
      return 'Phone number should be 10 digits';
    }
    if (!value.startsWith('97') && !value.startsWith('98')) {
      return 'Phone number should start with 97 or 98';
    }
    return null;
  }

  // ---------------- REQUIRED ----------------
  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }
}
