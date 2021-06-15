
class Spree::CustomImporterController < ApplicationController

   

  def import_prices (sheet_number, product_prices)
    p "Sheet number : " + sheet_number.to_s
    #xls = Roo::Excel.new("/home/mayank/Documents/ADI PRICE LIST 01-05-16.xls")
    $xls.default_sheet = $xls.sheets[sheet_number]
    if $xls.default_sheet == "DH" && sheet_number == 1 || $xls.default_sheet == "NET" && sheet_number == 0
    all_rows = []
    array_of_folder_index = []
    arr_of_saree_index = []
    (1..$xls.last_row).each do |i|
    row = $xls.row(i).compact
    all_rows << row
    all_rows = all_rows.delete_if { |elem| elem.flatten.empty? }
    end

    all_rows.each do |row|
    saree_with_index = []
    row.each_with_index do |value, index|
      if value == "SAREE"
        saree_with_index << (index + 1)
      end
    end

    saree_with_index.each do |product_index|
      taxon = self.process_folder_name row[product_index].to_s
      product_found = product_prices.select { |item|
        item[:taxon].to_s == taxon
      }
      if (product_found.count > 0)
        if sheet_number == 0
          product_found[0][:net_rate] = row[product_index + 1]
        else
          product_found[0][:due_rate] = row[product_index + 1]
        end
      else
        if sheet_number == 0
          product_data = {
            taxon: taxon,
            net_rate: row[product_index + 1]
          }
        else
          product_data = {
            taxon: taxon,
            due_rate: row[product_index + 1]
          }
        end
        product_prices << product_data
      end
    end
    end
    product_prices
    else
    p "Wrong sheet.."
    end
  end

  def prices
    product_prices = []
    product_prices = import_prices(0, product_prices)
    product_prices = import_prices(1, product_prices)
    product_prices
  end

  #Gives folder name for prices
  def get_taxons
    unique_folder_names = []
    folder_names = []
    Dir.glob("**/").each do |folder|
      folder_names += folder.split '/'
    end
    folder_names.uniq!.compact!
    if folder_names != nil
    folder_names.each do |folder_name|
      unique_folder_names << {
        raw_folder_name: folder_name,
        folder_name: self.process_folder_name(folder_name),
        folder_heirarchy: Dir.glob('**/'+folder_name)[0].split("/")
      }
    end
  end
    unique_folder_names
  end
  # Removes '-BP' from folder name 
  def process_folder_name (name)
    if name.end_with? ".0"
      processed_name =  name.to_i.to_s
    else
      processed_name = name.gsub(/[^0-9A-Za-z]/, '').gsub(/[^\d]/, '')
      processed_name
    end
  end

  #List product image names
  def get_product_names
    products = []
    Dir['**/*.{jpg,png}'].each do |file|
      absolute_path = File.absolute_path(file)
      fname = File.basename(file.to_s , '.*').split(/\W+/)
      taxons = file.split "/"
      taxons.pop.upcase
      name = fname.last
      fname = fname.last.scan( /(.*?)(\d+)$/ ).flatten
      if fname.any?
        file_name = fname[1]
       else
        file_name = name
      end
      products << {
        name: file_name,
        image: file,
        taxons: taxons,
        path: "/import images/" + $images_folder_name +"/" + file
      }
    end
    products
  end

  def actual_taxon(product)
    product[:values][:taxons].split(',').last
  end

  def get_dulicate_names(names)
    duplicates = names.select do |name|
      names.count(name) > 1
    end
    duplicates.uniq
  end

  def get_products
    products = self.get_product_names
    @uniq_folders = self.get_taxons
    product_prices = self.prices
    id = 1
    products.each_with_index do |product, product_index|
      taxons = product[:taxons]

      taxons.each_with_index do |taxon, taxon_index|
        price_index = product_prices.find_index { |product_price|
          product_price[:taxon] == self.process_folder_name(taxon)
        }

        unless price_index.nil?
          product[:net_rate] = product_prices[price_index][:net_rate]
          product[:due_rate] = product_prices[price_index][:due_rate]
        end
      end
      
      product[:taxons] = product[:taxons].join(", ").upcase
      product[:flag] = true
      product[:set_size] = 4
      product[:available_on] = Time.now.strftime("%d/%m/%Y")
      products[product_index] = {
        id: id,
        values: product
      }
      id = id + 1
    end
    grouped_products = products.group_by do |product|
      actual_taxon(product)
    end

    duplicate_mapping_hash = Hash.new([])

    grouped_products.each do |taxon, taxon_products|
      product_names = taxon_products.map { |p| p[:values][:name] }
      duplicate_product_names = get_dulicate_names(product_names)
      duplicate_mapping_hash[taxon] = duplicate_product_names
    end

    products.each do |product|
      product_taxon = actual_taxon(product)
      product_name = product[:values][:name]

      if duplicate_mapping_hash.fetch(product_taxon, []).include?(product_name)
        product[:values][:flag] = false
        product[:values][:className] = "duplicate"
      end
      if product[:values][:net_rate].nil? || product[:values][:due_rate].nil?
        product[:values][:flag] = false
        product[:values][:className] = "mandatory"
      end
    end
    products
  end

#set a flag if one folder(taxon) have same product names inside it and mark it as red and unchecked,so that the name should be changed manually and checked.

  def import_products
    path = params[:path]
    excel_file = params[:prices]
    if path != nil
      $images_folder_name = path.split('/')[-1]
      project_images_folder_path = Rails.public_path + "import images/" + $images_folder_name
      Dir.chdir(path)
      $xls = Roo::Excel.new(excel_file)
      copy_path = Pathname.new(path).to_s
      remove_images_folder
      FileUtils::mkdir_p project_images_folder_path
      FileUtils.cp_r copy_path +   "/.",project_images_folder_path, verbose: true
      redirect_to :action => 'list_product_details'
    else
      p "Please specify path of the directory"
    end
  end

#Add taxons, taxonomies and products in database.
  def list_product_details
    if request.post?
      @uniq_folders = self.get_taxons
      edited_product_info = params[:product_info]
      new_data = JSON.parse edited_product_info
      id = 1;
      products = []
      new_data.each do |product|
        new_product_data = {
          name: product["columns"][1],
          image: product["columns"][5], 
          taxons: product["columns"][4], 
          net_rate: product["columns"][3], 
          due_rate: product["columns"][2], 
          flag: product["columns"][0],
          set_size: product["columns"][7],
          available_on: product["columns"][6]
        } 
        products << {
          id: id,
          values: new_product_data
        }
        id = id + 1
      end
      add_taxonomies
      @taxons = add_taxons
      add_products(products)
      remove_images_folder
    else
      @products = get_products
    end
  end

  def add_taxonomies
    @uniq_folders.each do |folder_info|
      folder_heirarchy = folder_info[:folder_heirarchy]
      if folder_heirarchy.length == 1
        taxonomy = Spree::Taxonomy.new(name: folder_heirarchy[0].upcase)
        taxonomy.save
        folder_info[:taxanomy_id] = taxonomy.id
        folder_info[:taxon_id] = taxonomy.taxons.first.id
      else
        p "not taxonomy"
      end
    end
  end

  def add_taxons
    products = get_product_names
    product_taxons = []
    products.each_with_index do |product,product_index|
      product_taxons << products[product_index][:taxons]
    end
    product_taxons.uniq!
    parent_id = nil
    @uniq_folders.each_with_index do |folder_info, folder_index|
      folder_heirarchy = folder_info[:folder_heirarchy]
      length = folder_heirarchy.length
      if length > 1
        taxon_name = folder_heirarchy[length - 1].upcase
        p taxon_name
        p folder_index
        taxonomy_id = Spree::Taxonomy.where(:name => folder_heirarchy[0]).last.id
        unless taxonomy_id.nil?
          if length == 2
            parent_id = Spree::Taxon.find_by(:taxonomy_id => taxonomy_id, :parent_id => nil).id
          else
            parent_id = Spree::Taxon.find_by(:name => folder_heirarchy[length - 2], :taxonomy_id => taxonomy_id).id
          end
          if product_taxons.include?(folder_heirarchy)
            taxon = Spree::Taxon.new(name: taxon_name, position: 0, parent_id: parent_id, taxonomy_id: taxonomy_id)
            taxon.save
            folder_info[:taxon_id] = taxon.id
          end
        end
      else
        p "not taxon"
      end  
    end
  end

  def add_products (products)
    taxon_prices = self.prices
    products_taxons = @taxons
    taxon_prices.each_with_index do |taxon_price,taxon_price_index|
      products_taxons.each do |product_taxon|
        product_taxon = product_taxon[:raw_folder_name]
        if product_taxon.include?(taxon_prices[taxon_price_index][:taxon])
          taxon = Spree::Taxon.find_by name: product_taxon
          net_rate = taxon_prices[taxon_price_index][:net_rate]
          due_rate = taxon_prices[taxon_price_index][:due_rate]
          if taxon != nil
            taxon_price_net_rate = Spree::TaxonPrice.new(taxon_id: taxon.id, amount: net_rate, currency: "INR")
            taxon_price_due_rate = Spree::TaxonPrice.new(taxon_id: taxon.id, amount: due_rate, currency: "INR2")
            taxon_price_net_rate.save
            taxon_price_due_rate.save
          end
        end
      end
    end
    products.each_with_index do |product,product_index|
      if (product[:values][:flag])
        image = product[:values][:image]
        set_size = product[:values][:set_size]
        available_on = product[:values][:available_on]
        product_name = product[:values][:name]
        taxons = product[:values][:taxons]
        sku = taxons + " " + product_name
        sku = sku.gsub(/\,/,"").squish.gsub(/[^\w]/, '-').upcase
        master_price = product[:values][:net_rate]
        due_rate = product[:values][:due_rate]

        products_taxons = @taxons
        taxon_ids = []
        products_taxons.each do |taxon|
          product_taxon = taxon[:raw_folder_name]
          product_taxon_id = taxon[:taxon_id]
          if image.include?(product_taxon) && product_taxon_id != nil
            taxon_ids = product_taxon_id
          end
        end
        taxon_price_net_rate = Spree::TaxonPrice.where(taxon_id: taxon_ids,currency: "INR").first.amount
        taxon_price_due_rate = Spree::TaxonPrice.where(taxon_id: taxon_ids,currency: "INR2").first.amount
        product = Spree::Product.new(name: product_name, shipping_category_id: 1, tax_category_id: 1, price: master_price, taxon_ids: taxon_ids, sku: sku,slug: sku, available_on: available_on)
        if product.save
          variants = Spree::Variant.find_by(product_id: product.id)
          price = Spree::Price.new(amount: taxon_price_net_rate, variant_id: variants.id)
          price = Spree::Price.new(variant_id: variants.id ,amount: taxon_price_due_rate ,currency: "INR2")
          
          image = image.split(File::SEPARATOR).drop(3)
          image = File.join(image)
          images = Spree::Image.new(viewable_id: variants.id, viewable_type: "Spree::Variant")
          images.attachment = File.open(image)
          images.save
          set_size = ProductDetail.new(set_size: set_size ,product_id: product.id)
          set_size.save     
        else
          Rails.logger.info(product.errors.inspect) 
        end
      end
    end
  end
  
  def remove_images_folder
    path = Rails.public_path + "import images"
    if File.directory? path
      FileUtils.remove_dir Rails.public_path + "import images"
    end
  end

end
