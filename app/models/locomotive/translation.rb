module Locomotive
  class Translation

    include Locomotive::Mongoid::Document
    include Concerns::Shared::Userstamp

    ## fields ##
    field :key
    field :values,      type: Hash,     default: {}
    field :completion,  type: Integer,  default: 0

    ## associations ##
    belongs_to :site, class_name: 'Locomotive::Site', validate: false, autosave: false

    ## validations ##
    validates_uniqueness_of :key, scope: :site_id
    validates_presence_of   :site, :key

    ## named scopes ##
    scope :ordered,       -> { order_by(key: :asc) }
    scope :by_id_or_key,  ->(id_or_key) { all.or({ _id: id_or_key }, { key: id_or_key }) }

    ## callbacks ##
    before_validation :underscore_key
    before_validation :set_completion
    # before_validation :remove_blanks

    ## indexes ##
    index site_id: 1
    index site_id: 1, key: 1
    index site_id: 1, completion: 1
    index site_id: 1, key: 1, completion: 1

    ## methods ##

    protected

    # Make sure the translation key is underscored
    # since it is the unique way to use it in a liquid template.
    #
    def underscore_key
      if self.key
        self.key = self.key.permalink(true)
      end
    end

    def set_completion
      self.completion = values.count { |_, v| v.present? }
    end

    # def remove_blanks
    #   self.values.delete_if { |k,v| v.blank? }
    # end

  end
end
