india = Spree::Zone.find_by_name!("India")
clothing = Spree::TaxCategory.find_by_name!("Default")
tax_rate = Spree::TaxRate.create(
  name: "India",
  zone: india,
  amount: 0.00,
  tax_category: clothing)
tax_rate.calculator = Spree::Calculator::DefaultTax.create!
tax_rate.save!
