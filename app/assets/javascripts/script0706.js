function OnButtonClick() {
		$('#links ul').click(function () {$(this).fadeOut();});
}

$(function(){
	$('div.check-group label').toggle(
		function () {
			$(this)
				.addClass('checked')
				.prev('input').attr('checked','checked');
		},
		function () {
			$(this)
				.removeClass('checked')
				.prev('input').removeAttr('checked');
		}
	);
});
