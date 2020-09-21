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

if ($('#comment-receiver-inputgroup').length) {
  // TODO: Add aria attributes for accessibility
  // TODO: Fix keyboard navigation
  councillorTogglerRadio = document.createElement('input');
  $(councillorTogglerRadio).attr('type','radio')
                           .attr('name','councillors_list_toggler')
                           .attr('value','open')
                           .attr('id', 'councillors-list-toggler')
                           .attr('class', 'receiver-select-radio receiver-type-option');

  councillorTogglerLabel = document.createElement('label');
  $(councillorTogglerLabel).attr('for', 'councillors-list-toggler')
                           .attr('class', 'receiver-select-label receiver-type-option');

  councillorListWrapper = $('.councillor-select-list');

   if ($(councillorListWrapper).is('.open')) {
     $(councillorTogglerRadio).prop('checked', true);
   }

  councillorListWrapper.before(councillorTogglerRadio)
                       .before(councillorTogglerLabel);

  $('label[for="councillors-list-toggler"]').append('<strong>' + $('.councillor-select-list-intro strong').text() + '</strong><p>' + $('.councillor-select-list-intro p').text() + '</p>');

  $('.councillor-select-list-intro').remove();

  radioForAuthorityOption = $('#receiver-to-authority-option')
  radioForCouncillorsList = $('#councillors-list-toggler')

  $(radioForCouncillorsList).click(function(e) {
    if ($(radioForAuthorityOption).prop('checked') === true) {
      $(radioForAuthorityOption).prop('checked', false);
    }

    $(councillorListWrapper).addClass('open');
  });

  $(radioForAuthorityOption).click(function(e) {
    if ($(radioForCouncillorsList).prop('checked') === true) {
      $(radioForCouncillorsList).prop('checked', false);
    }

    if ($(councillorListWrapper).hasClass('open')) {
      $(councillorListWrapper).removeClass('open');
    }

    $('#add_comment_address_input').attr('aria-hidden', 'false');
    $('#add_comment_address_input input').attr('required', 'required');
  });

  if ( radioForAuthorityOption.prop('checked') === true  ) {
    $('#add_comment_address_input input').attr('required', 'required');
  }

  $('.councillor-select-radio').each(function() {
    if ( $(this).prop('checked') === true ) {
      $('#add_comment_address_input').attr('aria-hidden', 'true');
    }

    $(this).click(function() {
      $('#add_comment_address_input').attr('aria-hidden', 'true');
      $('#add_comment_address_input input').removeAttr('required');
    });
  });
}
