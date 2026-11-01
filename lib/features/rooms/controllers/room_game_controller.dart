import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller_variables.dart';
import 'package:tom_chat/features/rooms/models/game_config_model.dart';
import 'package:tom_chat/features/rooms/models/game_model.dart';

mixin LiveGamesController on GetxController implements RoomControllerVariables {
  Future<void> fetchGames(int type) async {
    games.clear();
    gameIsLoading.value = true;
    try {
      final response = await CallServerAPI.post('game/list', {
        'rid': room.value.id,
        'type': type,
      }, withMessage: false);
      games.value = GameModel.listFromResponse(response);
      gameConfig.value = GameConfigModel.fromJson(
        response['config'] is Map
            ? Map<String, dynamic>.from(response['config'])
            : {},
      );
    } finally {
      gameIsLoading.value = false;
    }
  }

  void toggleGame(GameModel game) {
    if (selectedGame.value?.gid == game.gid) {
      unselectGame();
    } else {
      selectGame(game);
    }
  }

  void selectGame(GameModel game) {
    selectedGame.value = null;
    selectedGame.value = game;
  }

  void unselectGame() {
    selectedGame.value = null;
  }

  // String get gameUrl {
  //   return '${selectedGame.value?.url}?appchannel=${gameConfig.value.appChannel}&appid=${gameConfig.value.appId}&userId=${gameConfig.value.userId}&code=${gameConfig.value.code}&roomId=${gameConfig.value.roomId}&gameMode=${gameConfig.value.gameMode}&language=${gameConfig.value.language}&gsp=${gameConfig.value.gsp}';
  // }
}
