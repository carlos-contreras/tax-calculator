module Colombian
  # Calculates the rent tax for colombian employees
  class LiquidIncomeTaxCalculator
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

    attr_reader :liquid_income, :fiscal_year, :rule

    # param [Number] liquid_income
    # param [Number] fiscal_year
    def initialize(liquid_income: 0, fiscal_year: 2019)
      @liquid_income = liquid_income.to_f
      @fiscal_year = fiscal_year
    end

    def calculate
      # return 0 if liquid_income.zero?
      result = {
        liquid_income: liquid_income,
        uvt: uvt,
        liquid_income_in_uvt: liquid_income_in_uvt,
        effective_tax: effective_tax_amount,
        monthly_ammount: effective_tax_amount / 12.0,
        applied_rule: rule
      }

      puts result.inspect
    end

    private

    def uvt
      @uvt ||= LiquidIncomeTaxCalculator.const_get("UVT_#{fiscal_year}")
    end

    def liquid_income_in_uvt
      @liquid_income_in_uvt ||= liquid_income / uvt
    end

    def effective_tax_amount
      @effective_tax_amount ||=
        LiquidIncomeTaxCalculator.const_get("TAX_RULES_#{fiscal_year}").each do |rule|
          next if rule[:upper_limit] != false && liquid_income_in_uvt > rule[:upper_limit]

          puts rule
          @rule = rule
          baseline = rule[:lower_limit] * uvt
          effective_rate = rule[:rate] / 100.0
          min_tax = rule[:base_tax] * uvt
          break ((liquid_income - baseline) * effective_rate) + min_tax
        end
    end
  end
end

# require('./calculator.rb')

# obj = Colombian::LiquidIncomeTaxCalculator.new(
#   income: 92_400_000,
#   fiscal_year: 2019
# )

# obj.calculate
