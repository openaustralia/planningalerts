// Javascript used on applications pages
$('#add_comment_address_input a').click(function(e) {
  e.preventDefault();
  $('#faq_commenting_address').slideToggle('fast');
});

$('#add_comment_text_input a').click(function(e) {
  e.preventDefault();
  $('#disclosure_explanation').slideToggle('fast');
});

$('a.hideable').click(function(e) {
  e.preventDefault();
  target = $(e.target).attr("data-target");
  $(target).slideToggle('fast');
});

function updateLink() {
    let councilRef = $("#council_ref");
    let reference = councilRef.data('reference');
    let ignoringComment = councilRef.data('ignoringcomment');
    if (ignoringComment === false) {
        return;
    }
    let councilEmail = councilRef.data('email');

    let comment = $("#add_comment_text").val();
    let address = $("#map_div").data('address');
    $("#council-mail-button").attr('href', 'mailto:' + councilEmail +
            '?subject=' + encodeURIComponent(reference + " " + address) +
            '&body=' + encodeURIComponent(comment)
    );
}

$('#add_comment_text').change(function(e) {
    updateLink();
});

$(document).ready(function() {
    updateLink();
});

