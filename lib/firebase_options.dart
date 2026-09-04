// The historical Firebase client configuration was intentionally removed from
// the public archive. Generate fresh platform options for a separate Firebase
// project before evaluating cloud-backed features.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'Firebase configuration is not included in this archived repository.',
      );
}
