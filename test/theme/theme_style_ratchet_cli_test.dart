import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tools/theme_style_ratchet.dart';

void main() {
  test('production manifest retains exact qualified scopes', () {
    final manifest =
        jsonDecode(File('docs/theme-style-ratchet.json').readAsStringSync())
            as Map<String, dynamic>;
    final files = manifest['files'] as List<dynamic>;
    expect(files, hasLength(18));
    final paths =
        files.cast<Map<String, dynamic>>().map((file) => file['path']).toSet();
    expect(
      paths,
      containsAll([
        'lib/theme/widgets/tonos_expansion_tile_scope.dart',
        'lib/theme/widgets/tonos_surface.dart',
        'lib/widgets/tonos_bottom_navigation_bar.dart',
        'lib/widgets/tonos_train_tabs.dart',
        'lib/widgets/workout_record_badges.dart',
        'lib/widgets/flow_screen_widgets.dart',
        'lib/widgets/recommended_sets_editor_dialog.dart',
        'lib/widgets/session_complete_sheet.dart',
        'lib/widgets/exercise_definition_info_tile.dart',
        'lib/widgets/set_stat_chip.dart',
        'lib/widgets/past_sessions_list.dart',
        'lib/widgets/nutrition_text_details.dart',
        'lib/widgets/seven_day_focus_card.dart',
        'lib/widgets/bodypart_focus_chips.dart',
        'lib/widgets/preset_info_card.dart',
        'lib/widgets/cardio_card.dart',
        'lib/widgets/stretch_card.dart',
        'lib/widgets/data_records_section.dart',
      ]),
    );
    final dataRecordsScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/data_records_section.dart',
    );
    final dataRecordsApprovals =
        (dataRecordsScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(dataRecordsApprovals, hasLength(9));
    expect(
      {
        for (final approval in dataRecordsApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '11ead75329a5f7ba629ad1550e99b3641fabc4e957a0f76efa659920f36f564f': 1,
        '1cf5fa259126054327a3ecd006fad4a99afc3de122cc5224922c8d8e435adce7': 1,
        '3aeaf49868b340b3d3d68b475e2d18bb4fcdfd35b18906bf685583c5cdb60f23': 1,
        '42ad97fd0c17bb28e297844a614644d8e034b283255eb7c4a3add8dacf7e99d4': 2,
        '5bb58bfa504cc1d5eb0210a8b10b2c74204f18e37d776867125156847fc93edf': 1,
        '96307d05652af3c069e7c15a04d96135b0a463295a7f2ab0608f0de0d5793227': 1,
        'acb3263f6faec3bd0578931310ba08f097405f5971de7496952df6314ed75ab1': 1,
        'd9308d8df55d2eb124b654664013611f25915f6e7b8c14d56384af1b7d36d5c9': 1,
        'e7e8fe6c59d5aff692604fa548f02de37c4856722a59d5b21a72b57f1ac769e1': 1,
      },
    );
    expect(
      dataRecordsApprovals.every(
        (approval) => (approval['reason'] as String).trim().isNotEmpty,
      ),
      isTrue,
    );
    final valueCardScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/nutrition_text_details.dart',
    );
    final valueCardApprovals =
        (valueCardScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(valueCardApprovals, hasLength(5));
    expect(
      {
        for (final approval in valueCardApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '70ef76816ec913957345fe31629fa4d10db3d88197f858e0a23ba19250bf7a29': 1,
        '718a863dce6a9c65789b1a4bd3577cc3155adb3dcfd19b878845850ce5d7064c': 1,
        '9b93d7314fdbf72092193b46c552912a20f68b74fa718cc9c1f18d0f423bb5a0': 1,
        'c18d55a4047c052a83f4c73f48a13103cf06c0fc732e13a82669bc80fc81c58e': 1,
        'f158d6bbaafe350627e0cb801e5cb16c1ac38cf1218248bc12ad76b0dcd78f6f': 1,
      },
    );
    expect(
      valueCardApprovals.every(
        (approval) =>
            approval['count'] == 1 &&
            (approval['reason'] as String).trim().isNotEmpty,
      ),
      isTrue,
    );
    final trainTabsScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/tonos_train_tabs.dart',
    );
    final trainTabsApprovals =
        (trainTabsScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(trainTabsApprovals, hasLength(10));
    expect(
      {
        for (final approval in trainTabsApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '0a7365d68272b8817d4c84a36b6d23f75edab387f67398f6019ce46f74e7817a': 1,
        '200cb37f2955432a9ce1d7e5ffac2aaaf07904aa7b56288a3997bc5e7f8856d9': 1,
        '2de734f63ecf28d7a0ed5e7f2dfd2f0d9184f310efb972f2ceee2fbeaac21239': 1,
        '2ed06ab145c2f3dd7bc98cac9fed47ce3c35e5d0ccae3280b7573547c6b371ea': 1,
        '73d044eee9eb451d4267a9aceb5afb59da566cb43ec44d8aecf32259c05fa0f8': 1,
        '92d4cc98d360ce548fc0efe13bc47bc1fe41bda8521363877bd779f2a08d433a': 1,
        'a5e4ca6fe65f2d15bf6b626f177ed3eb66a2f06c4081ee293fbd3b1e51d1fb96': 2,
        'b97cf83a07f0c34fb40826c6e3f830624906eeecb13bcb315a6187e8499d3e26': 1,
        'd52fd99be097bae6d2f1e36362adebeae023df1f4a26c72dec444c42515250e3': 1,
        'ff4cb09888cd128e8d0ee6061d5be12da8189fa081955c553ca2d6402b8eb618': 1,
      },
    );
    expect(
      trainTabsApprovals.every(
        (approval) => (approval['reason'] as String).trim().isNotEmpty,
      ),
      isTrue,
    );
    final navigationScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/tonos_bottom_navigation_bar.dart',
    );
    final navigationApprovals =
        (navigationScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(navigationApprovals, hasLength(8));
    expect(
      {
        for (final approval in navigationApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '0a7365d68272b8817d4c84a36b6d23f75edab387f67398f6019ce46f74e7817a': 1,
        '0d3601f1da4df264c2aef6eea19f0d4ec9b58ab3e317636c4899a9fa1e6368ed': 1,
        '14547d142c719736f56b7d3720acbc57a76d2cab26fcfbc84647e018dfef3f13': 1,
        '1a02edd38f5a7cbdca6c845fea770194fe16d96816ed81a824420eca77283791': 1,
        '657d2f1738bc0e8c38f4f6a8ef73b0677c2b46aeabdf4aa4f1364b02e9b59e18': 1,
        '6e935861fcb507bebb821426e90e2ad6f971d6eda62dd2c5b1cb5df21856e7b4': 1,
        '9b587dc1a09a54ff64331ff81ad911c56b10d82f645ff4c8565372024455eab3': 1,
        'c52be0033ea57248051d9176a33f1e9852c22272b83dcfe6cc34a15a9134a59f': 1,
      },
    );
    expect(
      navigationApprovals.every(
        (approval) =>
            approval['count'] == 1 &&
            (approval['reason'] as String).trim().isNotEmpty,
      ),
      isTrue,
    );
    final expansionScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) =>
          file['path'] == 'lib/theme/widgets/tonos_expansion_tile_scope.dart',
    );
    final expansionApprovals =
        (expansionScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(expansionApprovals, hasLength(3));
    expect(
      expansionApprovals.map((approval) => approval['fingerprint']).toSet(),
      containsAll([
        '01941e88c6ebd2ec01e2857976243cbc5d8f948f7f08bd954ae56c6c457e92c2',
        'bee7073bcd06b3c316dcda9c6eaa21e3a69b1b97f55708540a5c0547f3d77c54',
        'd2d922eabbf86a9668f71c0e18fe5e42425ff589417c18bc990d583b78db8068',
      ]),
    );
    expect(
      expansionApprovals.every(
        (approval) =>
            approval['count'] == 1 &&
            (approval['reason'] as String).trim().isNotEmpty,
      ),
      isTrue,
    );
    final flowScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/flow_screen_widgets.dart',
    );
    final flowApprovals =
        (flowScope['approvals'] as List<dynamic>).cast<Map<String, dynamic>>();
    expect(flowApprovals, hasLength(6));
    expect(flowApprovals.map((approval) => approval['fingerprint']).toSet(), {
      '1a9ae9252a12c1064b8145627e4182aded14d79292508875a29873d2040b3fe4',
      '281df9fbfa41048ffcae611b88ee0cb16cb21f0b07cc9c66315886e5504a62af',
      '62c57e450475048ffbe5b6adc18583b61b658e93ca6051ad86687a613840184d',
      '81c9090586f3b8e2f48159f4cb0dd61ad7a0cd50129578e40931475b1f82dd89',
      'c68e3bf790095e80a15b925385453b8da0a36035d555f10297cdd6b6c6012c08',
      'ef4243683c4d7d24ae8af3b8f98817a5356db2acdf8ea84478c9e999f9a2d00f',
    });
    final recommendedSetsScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) =>
          file['path'] == 'lib/widgets/recommended_sets_editor_dialog.dart',
    );
    final recommendedSetsApprovals =
        (recommendedSetsScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(recommendedSetsApprovals, hasLength(3));
    expect(
      {
        for (final approval in recommendedSetsApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '07742ce012f762528510a3332c9c2d33a75fd4c7725e2d10bc32b405ccfec814': 2,
        '3d9c1636d8bbd84244c2579b5ccb53316502f73ff19c58daf1af88cb6813da97': 2,
        '7466cd9356fa9cb99b588484eabf03cba1c66faf19452cc6c67e3a9ad0aa6b74': 1,
      },
    );
    final completionScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/session_complete_sheet.dart',
    );
    final completionApprovals =
        (completionScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(completionApprovals, hasLength(26));
    expect(
      {
        for (final approval in completionApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        'c8e28842be3909d2556a2831a72a1f955605a7f7025ec9da3200926756f9ca62': 1,
        '1e999f9f6801009aa39e5b4711dd450b5c9892bc77b5fe8702f98352318ed89c': 1,
        '2b5f88a22b89de2aa81acaa3641ef3752c260f4d3c69208b2c859bb8859ed8f5': 1,
        '2dd4a9db369a01b649752e2827bed40479e1c2d46dbe9a87468bc38aef9e55a3': 1,
        '023574243d5d5d754f9c2ee3db83ed2997811329273bd478eef5b00eba5e5598': 1,
        '3a5e4641bfbe15e06cd5a30109a1fba6dc1c4a946551d30d2fd54bee1a244b81': 1,
        '44c05dd366fc4488c8e2a7af42ea9ce2617f7870cc19facd34bdc6dcf7881f1a': 1,
        '49b1144f2d27417bddab6ad544d18216fe3a8e217082ee0cd10c0c4f7a8e02e6': 1,
        '5be8c96cf0a4cc079f2497aaffd5e087d43845df836ddff465311a210ca99760': 1,
        '5e5216888bf64e56c51fa501e7bc87be8722ab846b4e8f0cf4f766095583122c': 1,
        '636542d048c67818f7ff3e40c69c7ead14b9f1674be934d1523f6af0f11bf3bc': 1,
        '76ecc4768ec87f1bda2231f8eb062ab6e422c19fe210839ad17eb6527672b886': 1,
        '8ecc0d84adc6e137fd760145fbabed20d4a7b7597053204e7930508fbf8297ec': 1,
        '926c10b0220dede534e5880e16f456ab05d371f5084e72967be98d8740b202d5': 1,
        'aa0ae7173bebbd1f85f0d6099fa8e9313686d10a9fb440496bdd54b78b25e3eb': 1,
        'b4817b0f2bf4e61fdddfb4b70d4c4cfc38bea3c2bc4430307928a4dc4381d3f1': 1,
        'b5a9efea62a7b810de1732a3b868861049e460586d09900b8043cea550681bf3': 3,
        'b863a683a494bab9e5fdc2c23cf5ef4d7707c4b198c771da5cd86264cb141706': 1,
        'c7d252f7ec610a629afb7830331334b1d41f89f08d93d1e5e62aadc1ded285a1': 1,
        'd8378b37aa487dbb0a8a5482d440bfab2d3f06d924fa6ce57e2a03dc5ecfdec9': 1,
        'd8d9e8b7fb40a6cca2bb2377c7fade633238bf2717c24bf27c187ca58efe772f': 1,
        'd8fa843464f61d8d3786b5e87f75ffc3bd4bbc8eb0473de001286cfb7049c3ea': 1,
        'dea40a108da66e90cf29ea2bb09e752e596c8313a11d2337162ff009aaea670c': 1,
        'ec625f52b672045f12ba4ac04045ae236f84f697a83001b9b86e42fd30373bfd': 1,
        'f79e0b823060c5ac7389a599241c9242f95d4f7d6f1d836572da910198eaa2e0': 1,
        'fc3b4ed7f8396e65c5f82ba115ee85e517d581868e1f081cef979aa9685ef6d7': 1,
      },
    );
    final exerciseInfoScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) =>
          file['path'] == 'lib/widgets/exercise_definition_info_tile.dart',
    );
    final exerciseInfoApprovals =
        (exerciseInfoScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(exerciseInfoApprovals, hasLength(1));
    expect(
      {
        for (final approval in exerciseInfoApprovals)
          approval['fingerprint']: approval['count'],
      },
      {'50ab6b853cf46e7e5a0455cb489b8cad5a697e15cf360f716b8a60f851b8e227': 1},
    );
    final setStatScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/set_stat_chip.dart',
    );
    final setStatApprovals =
        (setStatScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(setStatApprovals, hasLength(2));
    expect(
      {
        for (final approval in setStatApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '912ba3dfc1570e9ba8f95b5e7350970dc666592e5bd2f4365d3797bc434a5866': 1,
        'cc6fd99f4549991e1418de00a3124f125fac10ae7e05bc80f54afcaaadb8eaa5': 1,
      },
    );
    for (final approval in [
      ...flowApprovals,
      ...recommendedSetsApprovals,
      ...completionApprovals,
      ...exerciseInfoApprovals,
      ...setStatApprovals,
    ]) {
      expect((approval['reason'] as String).trim(), isNotEmpty);
    }
    final result = checkStyleRatchet(manifest, root: Directory.current);
    expect(
      result,
      containsPair(
        'lib/theme/widgets/tonos_expansion_tile_scope.dart',
        isNotEmpty,
      ),
    );
    expect(
      result,
      containsPair('lib/theme/widgets/tonos_surface.dart', isNotEmpty),
    );
    expect(
      result,
      containsPair('lib/widgets/tonos_train_tabs.dart', isNotEmpty),
    );
    expect(
      result,
      containsPair('lib/widgets/tonos_bottom_navigation_bar.dart', isNotEmpty),
    );
    expect(
      result,
      containsPair('lib/widgets/workout_record_badges.dart', isNotEmpty),
    );
    expect(
      result,
      containsPair('lib/widgets/flow_screen_widgets.dart', isNotEmpty),
    );
    expect(
      result,
      containsPair(
        'lib/widgets/recommended_sets_editor_dialog.dart',
        isNotEmpty,
      ),
    );
    expect(
      result,
      containsPair('lib/widgets/session_complete_sheet.dart', isNotEmpty),
    );
    expect(
      result,
      containsPair(
        'lib/widgets/exercise_definition_info_tile.dart',
        isNotEmpty,
      ),
    );
    expect(result, containsPair('lib/widgets/set_stat_chip.dart', isNotEmpty));
    final pastSessionsScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/past_sessions_list.dart',
    );
    final pastSessionsApprovals =
        (pastSessionsScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(pastSessionsApprovals, hasLength(1));
    expect(
      pastSessionsApprovals.single['fingerprint'],
      'bfbac33db1e38873346fa38d2104e929f5cfd79b792d0aa2c6e35cf843baebd3',
    );
    expect(pastSessionsApprovals.single['count'], 1);
    expect(
      (pastSessionsApprovals.single['reason'] as String).trim(),
      isNotEmpty,
    );
    expect(
      result,
      containsPair('lib/widgets/past_sessions_list.dart', isNotEmpty),
    );
    final weeklyFocusScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/seven_day_focus_card.dart',
    );
    final weeklyFocusApprovals =
        (weeklyFocusScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(weeklyFocusApprovals, hasLength(6));
    expect(
      {
        for (final approval in weeklyFocusApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '158fb0382b2320120dbc3a07808ceee3f0e913a404fee58254d7989e5f373f51': 1,
        '1a589e19d333469209d6dd7598dcf846010ad50c00ee91a1e5c15910704f368b': 1,
        '36789b54998ceccc9032fa5e455fedeeda3fb8aabf270a1ae1f4a7f1f49d219f': 1,
        '5af65561290bc70f6ceac06eea598028afff67729a38c3b6de66d81d3daa529e': 1,
        'c1ab889e2b5322df241752d144847bf07716ef779d4981ca96fbc47b75514a67': 1,
        'c1e69096be224a5b8c62b9ce57e15da4e9029aa1cf2009760c1a26be6135ef47': 1,
      },
    );
    expect(
      weeklyFocusApprovals.every(
        (approval) =>
            approval['count'] == 1 &&
            (approval['reason'] as String).trim().isNotEmpty,
      ),
      isTrue,
    );
    final bodypartFocusScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/bodypart_focus_chips.dart',
    );
    final bodypartFocusApprovals =
        (bodypartFocusScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(bodypartFocusApprovals, hasLength(6));
    expect(
      {
        for (final approval in bodypartFocusApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '560d0babcccb4b59d70cb10aff1591d17058df10af8b60c9762d38c48d47de6d': 2,
        '66012b7fec4a4c2ae10b7baf6f5107a1fbf5eb15f9303aa0147a19dba2c194c1': 1,
        '8fd4a725ef130da9b7ed66ec8d44c166dcc7ca696d4910c84b5844d7798c3f93': 1,
        'b381477fa2d5c5bebdda57dd5f0c1184b2244bc9443098e3397acd598c7f7e94': 1,
        'd2f521b65022202eab9f02851635ae690b1dd1681374c272828ec536cb5f4242': 1,
        'eaa62c0622cfbefd44eeab710fd5cf18e9731de377c5b1a3865e9e7649b3cdcd': 1,
      },
    );
    final presetInfoScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/preset_info_card.dart',
    );
    final presetInfoApprovals =
        (presetInfoScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(presetInfoApprovals, hasLength(4));
    expect(
      {
        for (final approval in presetInfoApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '3466d571d6462b44c625266035e181fa6013f488f65b82a520984cb59a7875f7': 1,
        '651d278f2226b480a95e2a6f37789a9126e0387dda75051d3c08f2dca32bb45d': 1,
        '23cfd97f904231ffda1ec1e0d345646dcd388a71234cfbe5844f15ad8af9a4ee': 1,
        'f8de1519ee4d0293ed24411bf7a6569df2ec78567d83f571b3f9475aaf61f676': 1,
      },
    );
    final cardioScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/cardio_card.dart',
    );
    final cardioApprovals =
        (cardioScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(cardioApprovals, hasLength(4));
    expect(
      {
        for (final approval in cardioApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '1c8b211f89463240eb3da68edfe41d3d6f7de3dd59ba0257f54af6ca4b818b6b': 1,
        '27e0b79f80254e475daa3e701aeeffe1126f6e071412f24853ada194c412bd1c': 1,
        '12b04fb1e0590c352ee9f980e4da09c186a0fcb646202595ef8e1cedf1ce20fb': 2,
        'e35977c5ccdd21b1a96fd1b7f74eb56f75c6be3130ce549f861c69eb4d41a1c5': 2,
      },
    );
    final stretchScope = files.cast<Map<String, dynamic>>().singleWhere(
      (file) => file['path'] == 'lib/widgets/stretch_card.dart',
    );
    final stretchApprovals =
        (stretchScope['approvals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(stretchApprovals, hasLength(3));
    expect(
      {
        for (final approval in stretchApprovals)
          approval['fingerprint']: approval['count'],
      },
      {
        '29b8ffb5539032429fbe52493ecd7a014d796d5d7c29280313f72f8da6975651': 2,
        '0f53d07c1aac2e359b48380cc6af6413107e5fa87e3a5fccd9089b68e38bd148': 1,
        '90025390c0c0cc3ecefefcdf78526f85049363c82db21b48e1c7ee42500830c0': 1,
      },
    );
    for (final approval in [
      ...bodypartFocusApprovals,
      ...presetInfoApprovals,
      ...cardioApprovals,
      ...stretchApprovals,
    ]) {
      expect((approval['reason'] as String).trim(), isNotEmpty);
    }
    expect(
      result,
      containsPair('lib/widgets/seven_day_focus_card.dart', isNotEmpty),
    );
    expect(
      result,
      containsPair('lib/widgets/bodypart_focus_chips.dart', isNotEmpty),
    );
    expect(
      result,
      containsPair('lib/widgets/preset_info_card.dart', isNotEmpty),
    );
    expect(result, containsPair('lib/widgets/cardio_card.dart', isNotEmpty));
    expect(result, containsPair('lib/widgets/stretch_card.dart', isNotEmpty));
  });

  test(
    'CLI enforces approvals in a nonempty scope',
    () async {
      final root = Directory.systemTemp.createTempSync('ratchet_enforcement_');
      final script = File('tools/theme_style_ratchet.dart').absolute.path;
      final packages = File('.dart_tool/package_config.json').absolute.path;
      try {
        Directory('${root.path}/lib').createSync();
        final source = File('${root.path}/lib/example.dart');
        source.writeAsStringSync('var color = Colors.red;');
        final manifest = File('${root.path}/manifest.json');
        manifest.writeAsStringSync(
          jsonEncode({
            'schemaVersion': 1,
            'files': [
              {
                'path': 'lib/example.dart',
                'owner': 'test',
                'evidence': 'CLI fixture only',
                'approvals': [
                  for (final e
                      in styleFingerprints(source.readAsStringSync()).entries)
                    {
                      'fingerprint': e.key,
                      'count': e.value,
                      'reason': 'fixture',
                    },
                ],
              },
            ],
          }),
        );
        Future<ProcessResult> run({bool report = false}) => Process.run(
          'dart',
          [
            '--packages=$packages',
            script,
            manifest.path,
            if (report) ...['--report', '--details'],
          ],
          workingDirectory: root.path,
          runInShell: Platform.isWindows,
        );
        final approved = await run();
        expect(approved.exitCode, 0, reason: '${approved.stderr}');
        expect(jsonDecode(approved.stdout as String)['protectedFileCount'], 1);
        final report = await run(report: true);
        expect(report.exitCode, 0, reason: '${report.stderr}');
        final reportJson = jsonDecode(report.stdout as String) as Map;
        final details =
            (reportJson['fingerprintDetails'] as Map)['lib/example.dart']
                as Map;
        expect(details.values.single['candidate'], 'Colors');
        expect(
          (details.values.single['statementTokens'] as List).join(' '),
          contains('red'),
        );
        source.writeAsStringSync('var color = Colors.blue;');
        final rejected = await run();
        expect(rejected.exitCode, 64);
        expect(rejected.stderr, contains('lib/example.dart'));
        expect(rejected.stderr, contains('expected'));
      } finally {
        root.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test(
    'CLI reports empty protection honestly and rejects invalid input',
    () async {
      final root = Directory.systemTemp.createTempSync('ratchet_cli_');
      try {
        final manifest = File('${root.path}/manifest.json');
        manifest.writeAsStringSync(
          jsonEncode({'schemaVersion': 1, 'files': []}),
        );
        Future<ProcessResult> run(List<String> args) => Process.run('dart', [
          'run',
          'tools/theme_style_ratchet.dart',
          ...args,
        ], runInShell: Platform.isWindows);
        final valid = await run([manifest.path]);
        expect(valid.exitCode, 0, reason: '${valid.stderr}');
        expect(jsonDecode(valid.stdout as String)['protectedFileCount'], 0);
        final report = await run([manifest.path, '--report']);
        expect(report.exitCode, 0, reason: '${report.stderr}');
        final reportJson = jsonDecode(report.stdout as String) as Map;
        expect(reportJson['mode'], 'report');
        expect(reportJson, isNot(contains('fingerprintDetails')));
        final invalidArgs = await run([manifest.path, '--unknown']);
        expect(invalidArgs.exitCode, 64);
        manifest.writeAsStringSync('{invalid');
        expect((await run([manifest.path])).exitCode, 64);
        manifest.deleteSync();
        expect((await run([manifest.path])).exitCode, 66);
      } finally {
        root.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
