=begin

Copyright (c) 2008-2009 Ian White - ian.w.white@gmail.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=end

# Allow your controllers to inherit their views from parent controllers, or from
# specified view paths.
#
# === Example
#  
#   class FooController < ApplicationController
#     inherit_views
#   end
#
#   class BarController < FooController
#     ... # will look for views in 'views/bar' and 'views/foo' 
#   end
#
# In the example above, If BarController, or any of the views in views/bar, renders 'bar/view'
# and it is not found then 'foo/view' is rendered (if it can be found)
#
# You can also specify an inherit path other than the default (it does not have to be the default controller path)
# If your controller inherits from a controller with inherit_views then that controller
# gets the inherited view paths as well.
#
#   class FooController < ApplicationController
#     inherit_views 'far', 'faz'   # will look for views in 'foo', then 'far', then 'faz'
#   end
#
#   class BarController < FooController 
#     # will look for views in 'bar', 'foo', 'far', 'faz'
#   end
#
# If you want to turn off inherited views for a controller that has inherit_views in its
# ancestors use self.inherit_views=
#
#   class BarController < FooController
#     self.inherit_views = false
#   end
#
# You can completely override the inherited view paths in a subclass controller using
# inherit_view_paths=
#
#   class BarController < FooController
#     self.inherit_view_paths = ['you_can_go', 'your_own_way']
#     # will look for views in 'bar', 'you_can_go', and 'your_own_way'
#     # (not 'far' or 'faz' from FooController)
#   end

module InheritViews

  # class extension which enables specification of inherit_views
  module ActMethod
    # Specify this to have your controller or mailer inherit its views from the specified path
    # or the current controller/mailer's default path if no argument is given
    def inherit_views(*paths)
      class_eval do
        extend PathsContainer unless respond_to?(:inherit_views_paths)
        self.inherit_views = true
        self.inherit_view_paths = paths if paths.any?
      end
    end
  end

  # class extension that enables inherit_view_paths to be calculated/set
  #
  # requires a class method called 'controller_path' (ActionController::Base & ActionMailer::Base have this)
  module PathsContainer

    def self.extended(base)
      base.class_eval do
        delegate :inherit_views?, :inherit_view_paths, :to => 'self.class'
      end
    end

    # Return true if the class is inheriting views
    def inherit_views?
      read_inheritable_attribute('inherit_views') ? true : false
    end

    # Instruct the class that it is, or is not, inheriting views
    def inherit_views=(bool)
      write_inheritable_attribute('inherit_views', bool)
    end

    # Return the inherit view paths, in order of self to ancestor.
    # Takes inherit_view_paths from the superclass when first read, and prepends the current controller_path
    def inherit_view_paths
      instance_variable_get('@inherit_view_paths') || instance_variable_set('@inherit_view_paths', [controller_path] + (superclass.inherit_view_paths rescue []))
    end

    # Set the inherit view paths, in order of self to ancestor.
    # The controller_path for self is always prepended to the front, no matter what the arguments.
    def inherit_view_paths=(new_paths)
      new_paths -= [controller_path]
      old_paths = inherit_view_paths - [controller_path] - new_paths
      instance_variable_set('@inherit_view_paths', [controller_path] + new_paths + old_paths)
    end
  end

  # just like a normal path set, but can have an optional array of inherit_view_paths
  # which will be used to look for a matching template if the original template is missing
  class PathSet < ::ActionView::PathSet

    attr_accessor :inherit_view_paths

    alias_method :orig_find_template, :find_template

    # look for a parent template if a standard one can't be found
    def find_template(template_path, format = nil, html_fallback = true)
      super
    rescue ::ActionView::MissingTemplate
      find_parent_template(template_path, format)
    end

    # given a template_path and format, returns a parent template, or raise ActionView::MissingTemplate
    def find_parent_template(template_path, format = nil, html_fallback = true)
      # first, we grab the inherit view paths that are 'above' the given template_path
      if inherit_view_paths.present? && (starting_path = inherit_view_paths.detect {|path| template_path.starts_with?("#{path}/")})
        parent_paths = inherit_view_paths.slice(inherit_view_paths.index(starting_path)+1..-1)
        # then, search through each path, substituting the inherit view path, returning the first found
        parent_paths.each do |path|
          begin
            return orig_find_template(template_path.sub(/^#{starting_path}/, path), format, html_fallback)
          rescue ::ActionView::MissingTemplate
            next
          end
        end
      end
      raise ::ActionView::MissingTemplate.new(self, template_path, format)
    end
  end

  # Mixin for ActionView::Base to enable inherit views functionality.  There are two
  # enhancements
  #
  # * view_paths are set to an InheritViews::PathSet object, and any inherit_view_paths 
  #   are passed from the view's controller to the view_paths
  #
  # * render is extended to include support for render :parent, see render_with_parent
  module ActionView

    def self.included(base)
      base.class_eval do
        def self.process_view_paths(value)
          InheritViews::PathSet.new(Array(value))
        end

        alias_method_chain :view_paths=, :inherit_views
        alias_method_chain :render, :parent
      end
    end

    # set the view_paths, and afterwards pass it my controller's inherit_view_paths
    def view_paths_with_inherit_views=(value)
      data = self.view_paths_without_inherit_views=(value)
      @view_paths.inherit_view_paths = controller.inherit_view_paths if (controller.inherit_views? rescue false)
      return data
    end

    # Extension for render which enables the following (in partials as well as top-level tenplates)
    #
    #  <%= render :parent %>
    #  <%= render :parent, :locals => {:foo => @foo} %>
    #
    # These calls will render the template that is 'above' the current template according to the#
    # current controller's inherit_view_paths.
    def render_with_parent(*args, &block)
      if args.first == :parent
        args.shift
        args.first[:file] = view_paths.find_parent_template(template.to_s, template.format)
      end
      render_without_parent(*args, &block)
    end

  end

end

defined?(ActionController) && ActionController::Base.extend(InheritViews::ActMethod)
defined?(ActionMailer) && ActionMailer::Base.extend(InheritViews::ActMethod)
defined?(ActionView) && ActionView::Base.send(:include, InheritViews::ActionView)
