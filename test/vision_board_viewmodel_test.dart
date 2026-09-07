import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';
import 'package:selfsight/services/vision_board_service.dart';

class MockVisionBoardService extends Mock implements VisionBoardService {}

class FakeVisionBoard extends Fake implements VisionBoard {}

void main() {
  late MockVisionBoardService mockVisionBoardService;

  const goalId = 'goal_123';

  setUpAll(() {
    registerFallbackValue(FakeVisionBoard());
  });

  setUp(() {
    mockVisionBoardService = MockVisionBoardService();
    locator.registerSingleton<VisionBoardService>(mockVisionBoardService);
  });

  tearDown(() {
    locator.reset();
  });

  VisionBoardItem buildItem(String id) {
    return VisionBoardItem(
      id: id,
      imagePath: '/fake/path/$id.png',
      position: const Offset(0, 0),
      size: const Size(100, 100),
      rotation: 0,
      scale: 1,
      createAt: DateTime.now().toIso8601String(),
    );
  }

  // ==================== loadVisionBoard ====================

  group('loadVisionBoard', () {
    test(
      'When goalId is null, does nothing and never calls the service',
      () async {
        // Arrange
        final viewModel = VisionBoardViewModel(goalId: null);

        // Act
        await viewModel.loadVisionBoard();

        // Assert
        expect(viewModel.allElements, isEmpty);
        verifyNever(() => mockVisionBoardService.getVisionBoardByGoalId(any()));
      },
    );

    test(
      'When no vision board exists yet for this goal, elements stay empty',
      () async {
        // Arrange
        when(() => mockVisionBoardService.getVisionBoardByGoalId(goalId))
            .thenAnswer((_) async => null);
        final viewModel = VisionBoardViewModel(goalId: goalId);

        // Act
        await viewModel.loadVisionBoard();

        // Assert
        expect(viewModel.allElements, isEmpty);
        verify(() => mockVisionBoardService.getVisionBoardByGoalId(goalId))
            .called(1);
      },
    );

    test(
      'When a vision board exists with items, they are loaded into allElements',
      () async {
        // Arrange
        final items = [buildItem('item_1'), buildItem('item_2')];
        final board = VisionBoard(goalId: goalId, items: items);
        when(() => mockVisionBoardService.getVisionBoardByGoalId(goalId))
            .thenAnswer((_) async => board);
        final viewModel = VisionBoardViewModel(goalId: goalId);

        // Act
        await viewModel.loadVisionBoard();

        // Assert
        expect(viewModel.allElements, items);
      },
    );

    test(
      'When the board has a background image path, it is restored as an image background',
      () async {
        // Arrange
        final board = VisionBoard(
          goalId: goalId,
          backgroundImagePath: '/fake/background.png',
        );
        when(() => mockVisionBoardService.getVisionBoardByGoalId(goalId))
            .thenAnswer((_) async => board);
        final viewModel = VisionBoardViewModel(goalId: goalId);

        // Act
        await viewModel.loadVisionBoard();

        // Assert
        expect(viewModel.backgroundLogic.isImageBackgroundSelected, isTrue);
        expect(viewModel.backgroundLogic.backgroundImage?.path,
            '/fake/background.png');
      },
    );

    test(
      'When the board has a background color value, it is restored as a color background',
      () async {
        // Arrange
        final colorValue = VisionBoard.colorToInt(Colors.blue);
        final board = VisionBoard(
          goalId: goalId,
          backgroundColorValue: colorValue,
        );
        when(() => mockVisionBoardService.getVisionBoardByGoalId(goalId))
            .thenAnswer((_) async => board);
        final viewModel = VisionBoardViewModel(goalId: goalId);

        // Act
        await viewModel.loadVisionBoard();

        // Assert
        expect(viewModel.backgroundLogic.isImageBackgroundSelected, isFalse);
        expect(
            viewModel.backgroundLogic.backgroundColor.value, Colors.blue.value);
      },
    );
  });

  // ==================== saveVisionBoard ====================

  group('saveVisionBoard', () {
    test(
      'When goalId is null, does nothing and never calls the service',
      () async {
        // Arrange
        final viewModel = VisionBoardViewModel(goalId: null);

        // Act
        await viewModel.saveVisionBoard();

        // Assert
        verifyNever(() => mockVisionBoardService.saveVisionBoard(any()));
      },
    );

    test(
      'When background is a color, saves backgroundColorValue and leaves backgroundImagePath null',
      () async {
        // Arrange
        when(() => mockVisionBoardService.saveVisionBoard(any()))
            .thenAnswer((_) async {});
        final viewModel = VisionBoardViewModel(goalId: goalId);
        viewModel.backgroundLogic.backgroundColor = Colors.red;

        // Act
        await viewModel.saveVisionBoard();

        // Assert
        final captured =
            verify(() => mockVisionBoardService.saveVisionBoard(captureAny()))
                .captured;
        expect(captured.length, 1);
        final capturedBoard = captured.single as VisionBoard;
        expect(capturedBoard.goalId, goalId);
        expect(capturedBoard.backgroundColorValue,
            VisionBoard.colorToInt(Colors.red));
        expect(capturedBoard.backgroundImagePath, isNull);
      },
    );

    test(
      'When background is an image, saves backgroundImagePath and leaves backgroundColorValue null',
      () async {
        // Arrange
        when(() => mockVisionBoardService.saveVisionBoard(any()))
            .thenAnswer((_) async {});
        final viewModel = VisionBoardViewModel(goalId: goalId);
        viewModel.backgroundLogic.backgroundImage = File('/fake/bg.png');

        // Act
        await viewModel.saveVisionBoard();

        // Assert
        final captured =
            verify(() => mockVisionBoardService.saveVisionBoard(captureAny()))
                .captured;
        final capturedBoard = captured.single as VisionBoard;
        expect(capturedBoard.backgroundImagePath, '/fake/bg.png');
        expect(capturedBoard.backgroundColorValue, isNull);
      },
    );

    test(
      'When a snapshotPath is provided, it is saved and stored on the ViewModel',
      () async {
        // Arrange
        when(() => mockVisionBoardService.saveVisionBoard(any()))
            .thenAnswer((_) async {});
        final viewModel = VisionBoardViewModel(goalId: goalId);

        // Act
        await viewModel.saveVisionBoard(snapshotPath: '/fake/snapshot.png');

        // Assert
        expect(viewModel.snapshotPath, '/fake/snapshot.png');
        final captured =
            verify(() => mockVisionBoardService.saveVisionBoard(captureAny()))
                .captured;
        final capturedBoard = captured.single as VisionBoard;
        expect(capturedBoard.snapshotPath, '/fake/snapshot.png');
      },
    );

    test(
      'When no new snapshotPath is provided, the previous one is kept',
      () async {
        // Arrange
        when(() => mockVisionBoardService.saveVisionBoard(any()))
            .thenAnswer((_) async {});
        final viewModel = VisionBoardViewModel(goalId: goalId);
        await viewModel.saveVisionBoard(snapshotPath: '/fake/first.png');

        // Act
        await viewModel.saveVisionBoard(); // pas de nouveau snapshot fourni

        // Assert
        expect(viewModel.snapshotPath, '/fake/first.png');
      },
    );

    test(
      'Saves the current elements exactly as they are on the ViewModel',
      () async {
        // Arrange
        when(() => mockVisionBoardService.saveVisionBoard(any()))
            .thenAnswer((_) async {});
        final viewModel = VisionBoardViewModel(goalId: goalId);
        final item = buildItem('item_1');
        viewModel.allElements.add(item);

        // Act
        await viewModel.saveVisionBoard();

        // Assert
        final captured =
            verify(() => mockVisionBoardService.saveVisionBoard(captureAny()))
                .captured;
        final capturedBoard = captured.single as VisionBoard;
        expect(capturedBoard.items, [item]);
      },
    );
  });

  // ==================== resetValues / selectItem ====================

  group('resetValues and selectItem', () {
    test('resetValues clears selectedId and selectedItem', () {
      // Arrange
      final viewModel = VisionBoardViewModel(goalId: goalId);
      final item = buildItem('item_1');
      viewModel.allElements.add(item);
      viewModel.selectItem('item_1');

      // Act
      viewModel.resetValues();

      // Assert
      expect(viewModel.selectedId, '-1');
      expect(viewModel.selectedItem, isNull);
    });

    test('selectItem sets selectedId and selectedItem to the matching item',
        () {
      // Arrange
      final viewModel = VisionBoardViewModel(goalId: goalId);
      final item1 = buildItem('item_1');
      final item2 = buildItem('item_2');
      viewModel.allElements.addAll([item1, item2]);

      // Act
      viewModel.selectItem('item_2');

      // Assert
      expect(viewModel.selectedId, 'item_2');
      expect(viewModel.selectedItem, item2);
    });
  });

  // ==================== bringForward / sendBackward ====================

  group('bringForward', () {
    test('Moves the selected item one position forward in the list', () {
      // Arrange
      final viewModel = VisionBoardViewModel(goalId: goalId);
      final item1 = buildItem('item_1');
      final item2 = buildItem('item_2');
      final item3 = buildItem('item_3');
      viewModel.allElements.addAll([item1, item2, item3]);

      // Act
      viewModel.bringForward('item_1');

      // Assert
      expect(viewModel.allElements, [item2, item1, item3]);
    });

    test('Does nothing when the item is already at the front (last index)', () {
      // Arrange
      final viewModel = VisionBoardViewModel(goalId: goalId);
      final item1 = buildItem('item_1');
      final item2 = buildItem('item_2');
      viewModel.allElements.addAll([item1, item2]);

      // Act
      viewModel.bringForward('item_2');

      // Assert
      expect(viewModel.allElements, [item1, item2]);
    });

    test('Does nothing when the item id does not exist', () {
      // Arrange
      final viewModel = VisionBoardViewModel(goalId: goalId);
      final item1 = buildItem('item_1');
      viewModel.allElements.add(item1);

      // Act
      viewModel.bringForward('unknown_id');

      // Assert
      expect(viewModel.allElements, [item1]);
    });
  });

  group('sendBackward', () {
    test('Moves the selected item one position backward in the list', () {
      // Arrange
      final viewModel = VisionBoardViewModel(goalId: goalId);
      final item1 = buildItem('item_1');
      final item2 = buildItem('item_2');
      final item3 = buildItem('item_3');
      viewModel.allElements.addAll([item1, item2, item3]);

      // Act
      viewModel.sendBackward('item_3');

      // Assert
      expect(viewModel.allElements, [item1, item3, item2]);
    });

    test('Does nothing when the item is already at the back (index 0)', () {
      // Arrange
      final viewModel = VisionBoardViewModel(goalId: goalId);
      final item1 = buildItem('item_1');
      final item2 = buildItem('item_2');
      viewModel.allElements.addAll([item1, item2]);

      // Act
      viewModel.sendBackward('item_1');

      // Assert
      expect(viewModel.allElements, [item1, item2]);
    });

    test('Does nothing when the item id does not exist', () {
      // Arrange
      final viewModel = VisionBoardViewModel(goalId: goalId);
      final item1 = buildItem('item_1');
      viewModel.allElements.add(item1);

      // Act
      viewModel.sendBackward('unknown_id');

      // Assert
      expect(viewModel.allElements, [item1]);
    });
  });
}
