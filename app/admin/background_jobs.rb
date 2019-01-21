# frozen_string_literal: true

ActiveAdmin.register_page "Background Jobs" do
  content do
    iframe src: sidekiq_web_path, width: "100%", height: "1000px"
  end
end
