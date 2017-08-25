ActiveAdmin.register SuggestedCouncillor do
 belongs_to :councillor_contribution

 filter :councillor_contribution, :collection => proc { @councillor_contribution.suggested_councillors}
  csv do
    column :name
    column (:start_date){nil}
    column (:end_date){nil}
    column (:exective){nil}
    column (:council){@councillor_contribution.authority.full_name}
    column (:council_website){nil}
    column (:id){nil}
    column :email
    column (:image){nil}
    column (:party){nil}
    column (:source){nil}
    column (:ward){nil}
    column (:phone_mobile){nil}
  end
end
