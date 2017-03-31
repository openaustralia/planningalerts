module AutocompleteHelpers
  def expect_autocomplete_suggestions_to_include(expected_address)
    # this simulates focusing on the input field, which triggers the autocomplete search
    page.execute_script("el = document.querySelector('.address-autocomplete-input');
                          event = document.createEvent('HTMLEvents');
                          event.initEvent('focus', false, true);
                          el.dispatchEvent(event);")

    # Confirm that the suggested addresses appear.
    within ".pac-container" do
      # This regex is a hack because google seems to change how results are returned
      # it would be better to find less brittle way of testing this.
      expect(page).to have_content /#{expected_address.sub(", ","(, )?")}/
    end
  end
end
