require_relative './liquid_income_tax_calculator.rb'

module Colombian
  # Calculates the rent tax for colombian employees
  class SalaryTaxCalculator
    MIN_SALARY_2018 = 781_242.0
    MIN_SALARY_2019 = MIN_SALARY_2018 * 1.07

    DEFAULTS = {
      monthly_salary: 0,
      fiscal_year: 2019,
      use_70_30_relation: false,
      voluntary_contributions: 0,
      med_prepagada: 0,
      other_monthly_deductions: 0
    }.freeze

    attr_reader :monthly_salary, :fiscal_year, :use_70_30_relation, :med_prepagada,
                :voluntary_contributions, :other_monthly_deductions

    def initialize(attrs)
      @monthly_salary = attrs.fetch(:monthly_salary) { DEFAULTS[:monthly_salary] }
      @fiscal_year = attrs.fetch(:fiscal_year) { DEFAULTS[:fiscal_year] }
      @use_70_30_relation = attrs.fetch(:use_70_30_relation) { DEFAULTS[:use_70_30_relation] }
      @voluntary_contributions = attrs.fetch(:voluntary_contributions) { DEFAULTS[:voluntary_contributions] }
      @med_prepagada = attrs.fetch(:med_prepagada) { DEFAULTS[:med_prepagada] }
      @other_monthly_deductions = attrs.fetch(:other_monthly_deductions) { DEFAULTS[:other_monthly_deductions] }
    end

    def calculate
      result = {
        monthly_salary: monthly_salary,
        base_salary: base_salary,
        social_security: social_security,
        monthly_deductions: monthly_deductions,
        liquid_monthly_income: liquid_monthly_income
      }
      puts result.inspect

      Colombian::LiquidIncomeTaxCalculator.new(liquid_income: liquid_monthly_income*12, fiscal_year: fiscal_year)
                                          .calculate
    end

    private

    def liquid_monthly_income
      @liquid_monthly_income ||= begin
        _liquid_monthly_income = monthly_salary - monthly_deductions
        _liquid_monthly_income -= (_liquid_monthly_income*0.25)
        _liquid_monthly_income < monthly_salary * 0.4 ? monthly_salary * 0.4 : _liquid_monthly_income
      end
    end

    def base_salary
      @salary ||= use_70_30_relation ? monthly_salary * 0.7 : monthly_salary.to_f
    end

    # Si el trabajador gana mas de 4 salarios minimos entonces se le descuenta 1%
    # para el fondo de solidaridad pensional, de lo contrario es 4% para salud y 4% para pension
    # sobre el salario base
    def social_security
      @social_security ||= base_salary > (min_salary * 4) ? base_salary * 0.09 : base_salary * 0.08
    end

    def min_salary
      @min_salary ||= SalaryTaxCalculator.const_get("MIN_SALARY_#{fiscal_year}")
    end

    def monthly_deductions
      @deductions ||= begin
        _deductions = med_prepagada +
                      social_security +
                      other_monthly_deductions +
                      voluntary_contributions
        _deductions > monthly_salary * 0.4 ? monthly_salary * 0.4 : _deductions
      end
    end
  end
end
