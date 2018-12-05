#
class MyCalculator
  UVT_2019 = 34_270
  UVT_2018 = 33_156

  TAX_RULES_2018 = [
    {
      lower_limit: 0.0,
      upper_limit: 1_090.0,
      rate: 0,
      base_tax: 0
    },
    {
      lower_limit: 1_090.0,
      upper_limit: 1_700.0,
      rate: 19,
      base_tax: 0
    },
    {
      lower_limit: 1_700.0,
      upper_limit: 4_100.0,
      rate: 28,
      base_tax: 116
    },
    {
      lower_limit: 4_100.0,
      upper_limit: false,
      rate: 33,
      base_tax: 788
    }
  ].freeze

  TAX_RULES_2019 = [
    {
      lower_limit: 0.0,
      upper_limit: 1_090.0,
      rate: 0,
      base_tax: 0
    },
    {
      lower_limit: 1_090.0,
      upper_limit: 1_700.0,
      rate: 19,
      base_tax: 0
    },
    {
      lower_limit: 1_700.0,
      upper_limit: 4_100.0,
      rate: 28,
      base_tax: 116
    },
    {
      lower_limit: 4_100.0,
      upper_limit: 7_600.0,
      rate: 33,
      base_tax: 788
    },
    {
      lower_limit: 7_600.0,
      upper_limit: 13_100.0,
      rate: 35,
      base_tax: 1943
    },
    {
      lower_limit: 13_100.0,
      upper_limit: false,
      rate: 37,
      base_tax: 3868
    }
  ].freeze

  attr_reader :income, :taxed_income, :deduction_porcentage, :fiscal_year, :rule

  # param [Number] income
  # param [Number] taxed_income
  # param [Number] deduction_porcentage
  # param [Number] year
  def initialize(income: 0, taxed_income: 0, deduction_porcentage: 25, fiscal_year: 2019)
    @income = (income || 0).to_i
    @taxed_income = (taxed_income || 0).to_i
    @deduction_porcentage = (deduction_porcentage || 25).to_f
    @deduction_porcentage = deduction_porcentage > 40.0 ? 40.0 : deduction_porcentage
    @fiscal_year = fiscal_year
  end

  def calculate
    return 0 if taxed_income.zero? && income.zero?

    {
      liquid_income: liquid_income,
      deduction: deduction,
      uvt: uvt,
      rule: rule,
      liquid_income_in_uvt: liquid_income_in_uvt,
      effective_tax: effective_tax_amount,
      monthly_ammount: effective_tax_amount / 12.0
    }
  end

  private

  def deduction
    @deduction ||= (income * (deduction_porcentage / 100.0))
  end

  def liquid_income
    @liquid_income ||= income - deduction
  end

  def uvt
    @uvt ||= MyCalculator.const_get("UVT_#{fiscal_year}")
  end

  def liquid_income_in_uvt
    @liquid_income_in_uvt ||= liquid_income / uvt
  end

  def effective_tax_amount
    MyCalculator.const_get("TAX_RULES_#{fiscal_year}").each do |rule|
      next if rule[:upper_limit] != false && liquid_income_in_uvt > rule[:upper_limit]

      @rule = rule
      baseline = rule[:lower_limit] * uvt
      effective_rate = rule[:rate] / 100.0
      min_tax = rule[:base_tax] * uvt
      return ((liquid_income - baseline) * effective_rate) + min_tax
    end
  end
end

# require('./calculator.rb')

# obj = MyCalculator.new(
#   income: 92_400_000,
#   deduction_porcentage: 40,
#   fiscal_year: 2019
# )

# obj.calculate
