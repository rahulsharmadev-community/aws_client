import 'package:meta/meta.dart';
import 'package:shared_aws_api/shared.dart' as _s;

abstract class AwsClient {
  final _s.JsonProtocol protocol;
  AwsClient(
      {required String region,
      _s.AwsClientCredentials? credentials,
      _s.AwsClientCredentialsProvider? credentialsProvider,
      _s.ServiceMetadata? service,
      _s.Client? client,
      String? endpointUrl})
      : protocol = _s.JsonProtocol(
            client: client,
            service: service,
            region: region,
            credentials: credentials,
            credentialsProvider: credentialsProvider,
            endpointUrl: endpointUrl);

  /// Closes the internal HTTP client if none was provided at creation.
  /// If a client was passed as a constructor argument, this becomes a noop.
  ///
  /// It's important to close all clients when it's done being used; failing to
  /// do so can cause the Dart process to hang.
  @mustCallSuper
  void close() {
    protocol.close();
  }
}
