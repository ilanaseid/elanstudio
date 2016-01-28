require 'spec_helper'
require 'rails_helper'

feature "Selections appear when they are supposed to" do

  scenario "Current in current, no archive", js: true do
    # all three are needed so that the containers will show up to be checked against
    archived_selection = FactoryGirl.create(:content, :archived_selection)
    current_selection = FactoryGirl.create(:content, :selection)
    #current_selection2 = FactoryGirl.create(:content, :selection)
    #current_selection3 = FactoryGirl.create(:content, :selection)

    visit selections_path

    # hero section
    #within('.selection-hero') do
      # have the hero selection
      expect(page).to have_content(current_selection.title)
      # not have the other types of selections:
      #expect(page).to_not have_content(featured_selection.title)
      expect(page).to_not have_content(archived_selection.title)
    #end

    # current section
    #within('.selection-index-item') do
      # have the current selection
      #expect(page).to have_content(current_selection.title)
      # not have the other types of selections:
      #expect(page).to_not have_content(archived_selection.title)
      #expect(page).to_not have_content(featured_selection.title)
    #end

  end

end
