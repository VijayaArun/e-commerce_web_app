module Spree
  module Admin
    NavigationHelper.class_eval do

      def admin_breadcrumbs
        @admin_breadcrumbs ||= []
      end

      # Add items to current page breadcrumb heirarchy
      def admin_breadcrumb(*ancestors, &block)
        admin_breadcrumbs.concat(ancestors) if ancestors.present?
        admin_breadcrumbs.push(capture(&block)) if block_given?
      end

    	  def tab(*args, &block)
        options = {:label => args.first.to_s}

        if args.last.is_a?(Hash)
          options = options.merge(args.pop)
        end
        options[:route] ||=  "admin_#{args.first}"
        
        if options[:label] == "products" && options[:icon] == "th-large"
          options[:route] = "admin_taxonomies"
          destination_url = options[:url] || spree.send("#{options[:route]}_path")
        else
          destination_url = options[:url] || spree.send("#{options[:route]}_path")
        end
        titleized_label = Spree.t(options[:label], :default => options[:label], :scope => [:admin, :tab]).titleize

        css_classes = []
        if options[:icon]
          link = link_to_with_icon(options[:icon], titleized_label, destination_url)
          css_classes << 'tab-with-icon'
        else
          selected_sub_menu = if options[:label] == "add_products"
            request.fullpath.starts_with?("#{options[:url]}") 
          elsif options[:match_path]
            request.fullpath.starts_with?("#{admin_path}#{options[:match_path]}")
          end
          link = link_to(titleized_label, destination_url)
          css_classes << 'selected' if selected_sub_menu
        end
        
        selected = if controller.controller_name == 'vendor' 
          request.fullpath.starts_with?(vendor_path+options[:match_path])	#Check for vendor tabs
        elsif options[:match_path].is_a? Regexp
          request.fullpath =~ options[:match_path]
        elsif options[:match_path]
          request.fullpath.starts_with?("#{admin_path}#{options[:match_path]}")
        else
          args.include?(controller.controller_name.to_sym)
        end
        css_classes << 'selected' if selected

        if options[:css_class]
          css_classes << options[:css_class]
        end
        content_tag('li', link + (yield if block_given?), class: css_classes.join(' ') )
      end


      end
     end
   end