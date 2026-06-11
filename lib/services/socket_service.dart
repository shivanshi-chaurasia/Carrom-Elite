import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/constants/api_endpoints.dart';

class SocketService {
  io.Socket? _socket;

  void connect(String token) {
    _socket = io.io(
      ApiEndpoints.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );
    _socket?.connect();
  }

  void handleDefaults({
    void Function(dynamic data)? onMatchAssigned,
    void Function(dynamic data)? onScoreUpdate,
  }) {
    _socket?.on('join_room', (data) => print('joined $data'));
    _socket?.on('order_status_update', (data) => print('order update $data'));
    _socket?.on('live_location_update', (data) => print('location update $data'));
    _socket?.on('new_match_notification', (data) => print('new match $data'));
    _socket?.on('match_assigned', onMatchAssigned ?? (_) {});
    _socket?.on('score_update', onScoreUpdate ?? (_) {});
  }

  void emit(String event, dynamic data) => _socket?.emit(event, data);
  void dispose() => _socket?.dispose();
}
