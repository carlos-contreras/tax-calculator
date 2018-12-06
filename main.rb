require './colombian/salary_tax_calculator.rb'

salary = 8_600_000.0
obj = Colombian::SalaryTaxCalculator.new(
  monthly_salary: salary,
  fiscal_year: 2019,
  use_70_30_relation: true,
  voluntary_contributions: salary*0.1,
  med_prepagada: 463_757,
  other_monthly_deductions: 270_000
).calculate