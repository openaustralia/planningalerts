class ActiveRecord::Base

  def to_dom(*args)

    options = args.extract_options!
    display_id = new_record? ? 'new' : id

    [ options[:prefix], 
      self.class.name.underscore, 
      display_id, 
      options[:suffix] ].compact.join('_')

  end

  ##
  # On a model:
  #
  #     class Post < ActiveRecord::Base
  #       STATUS = { :published => t("Published"), 
  #                  :pending => t("Pending"), 
  #                  :draft => t("Draft") }
  #     end
  #
  #     >> Post.find(:first).status
  #     => "published"
  #     >> Post.find(:first).mapping(:status)
  #     => "Published"
  #     >> I18n.locale = :es
  #     => :es
  #     >> Post.find(:first).mapping(:status)
  #     => "Publicado"
  #
  def mapping(attribute)
    values = self.class::const_get("#{attribute.to_s.upcase}")
    values.kind_of?(Hash) ? values[send(attribute)] : send(attribute)
  end

  ##
  # We had:
  #
  #   def typus_name
  #     respond_to?(:name) ? name : "#{self.class}##{id}"
  #   end
  #
  # ActiveScaffold uses `to_label`, which makes more sense. We want 
  # to keep compatibility with old versions of Typus. The prefered method 
  # is `to_label` and `typus_name` will be deprecated in the next months.
  #
  def to_label
    [ :typus_name, :name ].each do |attribute|
      return send(attribute).to_s if respond_to?(attribute)
    end
    return [ self.class, id ].join("#")
  end

  ##
  # Returns pluralized model name from locale or typus_human_name.pluralized
  #
  def self.pluralized_human_name
    I18n.t "#{self.to_s.underscore}.many", :scope => [:activerecord, :models], :default => self.typus_human_name.gsub('/', ' ').pluralize
  end

end
