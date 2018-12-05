module Colombian
  # Calculates the rent tax for colombian employees
  class SalaryTaxCalculator
    MINIMUN_SALARY = 781_242

    DEFAULTS = {
      monthly_salary: 0,
      fiscal_year: 2019,
      use_70_30_relation: false,
      afc_and_voluntary_pention_deduction: 0,
      other_monthly_deductions: 0
    }.freeze

    attr_reader :monthly_salary, :fiscal_year, :use_70_30_relation,
                :voluntary_contributions, :other_monthly_deductions

    def initialize(attrs)
      @monthly_salary = attrs.fetch(:monthly_salary) { DEFAULTS[:monthly_salary] }
      @fiscal_year = attrs.fetch(:fiscal_year) { DEFAULTS[:fiscal_year] }
      @use_70_30_relation = attrs.fetch(:use_70_30_relation) { DEFAULTS[:use_70_30_relation] }
      @voluntary_contributions = attrs.fetch(:voluntary_contributions) { DEFAULTS[:voluntary_contributions] }
    end
  end
end
