//= require active_admin/base

window.onload = function() {
  const $algorithmSelectionField = $(".algorithm-selection select");

  const initializeAlgorithmParameters = function(currentAlgorithm) {
    $(`.algorithm-selection-group[data-algorithm=${currentAlgorithm}]`).show();
    $(`.algorithm-selection-group[data-algorithm!=${currentAlgorithm}]`).hide();
  }

  $algorithmSelectionField.on("change", function() {
      const currentAlgorithm = $(this).val();

      initializeAlgorithmParameters(currentAlgorithm);
  });

  initializeAlgorithmParameters($algorithmSelectionField.val());
}
