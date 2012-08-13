# Workaround for annoying bug in active_admin. See https://github.com/gregbell/active_admin/issues/64
ActiveAdmin.register Comment, :as => "ApplicationComment" do
end
