# there is no Boolean
module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

class SimpleAdmin
  attr_accessor :model_blacklist, :visible_columns_blacklist, :editable_columns_blacklist, :creatable_models_whitelist, :editable_associations_whitelist, :extensions

  def initialize
    @model_blacklist = []
    @visible_columns_blacklist = []
    @editable_columns_blacklist = []
    @creatable_models_whitelist = []
    @editable_associations_whitelist = {}.with_indifferent_access
    @extensions = []
  end

  def model_blacklist=(items)
    raise Exception.new("params must be of type Array") unless items.is_a? Array
    @model_blacklist << items
    @model_blacklist.flatten!.uniq!
  end

  def visible_columns_blacklist=(items)
    raise Exception.new("params must be of type Array") unless items.is_a? Array
    @visible_columns_blacklist << items
    @visible_columns_blacklist.flatten!.uniq!
  end

  def editable_columns_blacklist=(items)
    raise Exception.new("params must be of type Array") unless items.is_a? Array
    @editable_columns_blacklist << items
    @editable_columns_blacklist.flatten!.uniq!
  end

  def creatable_models_whitelist=(items)
    raise Exception.new("params must be of type Array") unless items.is_a? Array
    @creatable_models_whitelist << items
    @creatable_models_whitelist.flatten!.uniq!
    @creatable_models_whitelist = @creatable_models_whitelist.map(&:constantize)
  end

  def editable_associations_whitelist=(items_hash)
    # key should be model name, values should be array of permitted editable associations
    raise Exception.new("param must be of type Hash") unless items_hash.is_a? Hash
    @editable_associations_whitelist = @editable_associations_whitelist.merge items_hash
  end

  def table_models
    @table_models = []
    ActiveRecord::Base.connection.tables.collect do |table|
      unless model_blacklist.include? table.classify
        begin
          @table_models << table.classify.constantize
        rescue
          nil
        end
      end
    end
    @table_models.compact! || @table_models
  end

  def decorate_column_class(col_name)
    case col_name
      when 'created_at'
        'format-date'
      when 'updated_at'
        'format-date'
      end
  end

  def visible_attributes_for_model(my_model)
    my_model = my_model.constantize if my_model.is_a? String
    my_model.new.attribute_names - visible_columns_blacklist
  end

  def editable_attributes_for_model(my_model)
    my_model = my_model.constantize if my_model.is_a? String
    my_model.new.attribute_names - editable_columns_blacklist
  end

  def get_resource(model_name, id)
    model_name.constantize.find(id)
  end

  def new_resource(model_name)
    model_name.constantize.new
  end

  def simple_form_field(simple_form_obj, my_model, alternate_input_hash={})
    editable_attributes = self.editable_attributes_for_model my_model
    collection_validators = my_model.constantize.validators.select{|v| v.options.keys.include? :in }
    html = ""

    # table columns
    editable_attributes.each do |ea|
      if !alternate_input_hash.blank? && ea =~ Regexp.new(alternate_input_hash.keys.first.to_s)
        # non simple_form inputs
        html += "<div class='form-group'>"
        html += simple_form_obj.send(alternate_input_hash.values.first.to_s, ea.to_sym, {}, { class: "form-control" })
        html += "</div>"
      else
        # simple_form inputs
        collection_validator = collection_validators.select{|cv| cv.attributes.include? ea.to_sym}.first
        if collection_validator
          # treat as a collection
          html += simple_form_obj.input(ea.to_sym, collection: collection_validator.send(:delimiter), input_html: {class: 'form-control'}, wrapper_html: {class: 'form-group'})
        else
          if simple_form_obj.object.send(ea.to_sym).is_a? Boolean
            class_for_group = nil
            class_for_control = nil
          else
            class_for_group = "form-group"
            class_for_control = "form-control"
          end
          # is not a collection
          html += simple_form_obj.input(ea.to_sym, input_html: {class: class_for_control}, wrapper_html: {class: class_for_group})
        end
      end
    end

    # model associations
    my_model.constantize.reflections.keys.each do |associated|
      if editable_associations_whitelist[my_model] &&
         editable_associations_whitelist[my_model].include?(associated)

        html += simple_form_obj.association(associated, as: :check_boxes)
      end
    end

    html.html_safe
  end

  def extensions=(ext)
    raise Exception.new("Extension requires a hash formatted: {lib_class_name: 'ExtensionLibClassName'}") unless ext.is_a?(Hash) && ext.keys == [:lib_class_name]

    @extensions << Extension.new(ext[:lib_class_name])
  end
end

Extension = Struct.new(:class_name) do
  def view_name
    self.class_name.underscore
  end

  def name
    self.class_name.titleize
  end

  def instantiate
    self.class_name.constantize.new
  end
end