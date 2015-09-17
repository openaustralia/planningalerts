require 'spec_helper'

feature "Send a message to a councilor" do
  # As someone interested in a local development application,
  # let me write to my local councillor about it,
  # so that I can get their help or feedback
  # and find out where they stand on this development I care about

  context "when not logged in" do
    scenario "can’t see councilor messages sections" do
      # visit an application page
      # there should not be an introduction to writing to your councillors
      # and you should not be able to write and submit a message.
    end
  end

  context "when logged in as admin" do
    scenario "sending a message" do
      # visit an application page
      # there should be a short text introduction to writing to your councillors
      # there should be an expanation that this wont necessarily impact the decision about this application,
      #   encourage people to use the official process for that.
      # there should be a list of councilors to select from
      # select the councillor you would like to write to
      # fill out your name
      # write your message
      # post your message
      # the message appears on the page
      # the message is sent off to the councillor
    end
  end
end
