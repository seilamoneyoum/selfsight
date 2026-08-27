import 'package:flutter/material.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';
import 'package:selfsight/presentation/view/templates.dart';

Column alignImagesContainer(
    BuildContext context, VisionBoardViewModel viewModel) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Sélection de l'axe
      _axisSegmentButtons(viewModel),
      const SizedBox(height: 12),

      // Sélection de la position (si axe choisi)
      if (viewModel.alignImagesLogic.axisSelection != null) ...[
        _positionSegmentButtons(viewModel),
        const SizedBox(height: 16),
      ],

      // Boutons d'action final (Cancel or Apply)
      _finalActionButtons(viewModel)
    ],
  );
}

final ButtonStyle _segmentButtonStyle = ButtonStyle(
  fixedSize: WidgetStateProperty.all(const Size(120, 40)),
  textStyle: WidgetStateProperty.all(
    const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
  ),
  backgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.black;
    }
    return Colors.grey.shade200;
  }),
  foregroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.white;
    }
    return Colors.black;
  }),
);

Row _axisSegmentButtons(VisionBoardViewModel viewModel) {
  return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
    SizedBox(width: 12),
    message('Axis:'),
    SizedBox(width: 12),
    SegmentedButton<String>(
      showSelectedIcon: false,
      emptySelectionAllowed: true,
      segments: const [
        ButtonSegment(value: 'horizontal', label: Text('Horizontal')),
        ButtonSegment(value: 'vertical', label: Text('Vertical')),
      ],
      selected: viewModel.alignImagesLogic.axisSelection != null
          ? {viewModel.alignImagesLogic.axisSelection!}
          : {},
      onSelectionChanged: (Set<String> newSelection) {
        viewModel.alignImagesLogic.setAxis(newSelection.first);
      },
      style: _segmentButtonStyle,
    ),
  ]);
}

Row _positionSegmentButtons(VisionBoardViewModel viewModel) {
  return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
    SizedBox(width: 12),
    message('Position:'),
    SizedBox(width: 12),
    SegmentedButton<String>(
      showSelectedIcon: false,
      emptySelectionAllowed: true,
      segments: viewModel.alignImagesLogic.axisSelection == 'horizontal'
          ? const [
              ButtonSegment(value: 'left', label: Text('Left')),
              ButtonSegment(value: 'center', label: Text('Center')),
              ButtonSegment(value: 'right', label: Text('Right')),
            ]
          : const [
              ButtonSegment(value: 'top', label: Text('Top')),
              ButtonSegment(value: 'center', label: Text('Center')),
              ButtonSegment(value: 'bottom', label: Text('Bottom')),
            ],
      selected: viewModel.alignImagesLogic.positionSelection != null
          ? {viewModel.alignImagesLogic.positionSelection!}
          : {},
      onSelectionChanged: (Set<String> newSelection) {
        viewModel.alignImagesLogic.setPosition(newSelection.first);
      },
      style: _segmentButtonStyle,
    ),
  ]);
}

Row _finalActionButtons(VisionBoardViewModel viewModel) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: viewModel.alignImagesLogic.exitAlignMode,
        child: const Text('Cancel'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: (viewModel.alignImagesLogic.axisSelection != null &&
                viewModel.alignImagesLogic.positionSelection != null)
            ? viewModel.alignImagesLogic.applyAlignment
            : null,
        child: const Text('Apply'),
      ),
    ],
  );
}
