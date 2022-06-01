require "test/unit"
require "date"
require_relative './contract'
require_relative './claim'
require_relative './terms_and_conditions'

class ContractTest < Test::Unit::TestCase

  def test_contract_is_setup_correctly
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    terms_and_conditions = TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90)

    contract = Contract.new(100.0, product, terms_and_conditions)

    assert_equal 100.0, contract.purchase_price
    assert_equal "PENDING", contract.status

    assert_equal Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0"), contract.covered_product
    assert_equal TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90), contract.terms_and_conditions
  end

  def test_contract_is_in_effect_based_on_status_and_dates
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    terms_and_conditions = TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90)
    contract = Contract.new(100.0, product, terms_and_conditions)

    # PENDING
    assert_false  contract.in_effect_for?(Date.new(2010, 5, 9))
    # ACTIVE
    contract.status = "ACTIVE"
    assert_false  contract.in_effect_for?(Date.new(2010, 5, 7))
    assert_true   contract.in_effect_for?(Date.new(2010, 5, 8))
    assert_true   contract.in_effect_for?(Date.new(2013, 5, 8))
    assert_false  contract.in_effect_for?(Date.new(2013, 5, 9))
  end

  def test_limit_of_liability_no_claims
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    terms_and_conditions = TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90)

    contract = Contract.new(100.0, product, terms_and_conditions)
    
    assert_equal 80.0, contract.limit_of_liability
  end

  def test_claims_total
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    terms_and_conditions = TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90)

    contract = Contract.new(100.0, product, terms_and_conditions)
    contract.claims << Claim.new(10.0, Date.new(2010, 10, 1))

    assert_equal 10.0, contract.claim_total()
  end

  def test_claims_total_is_sum_of_claim_amounts
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    terms_and_conditions = TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90)

    contract = Contract.new(100.0, product, terms_and_conditions)
    contract.claims << Claim.new(20.0, Date.new(2010, 10, 1))
    contract.claims << Claim.new(23.0, Date.new(2010, 10, 1))

    assert_equal 43.0, contract.claim_total()
  end

  def test_limit_of_liability_one_claim
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    terms_and_conditions = TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90)

    contract = Contract.new(100.0, product, terms_and_conditions)
    contract.claims << Claim.new(10.0, Date.new(2010, 10, 1))

    assert_equal 70.0, contract.limit_of_liability
    assert_true  contract.within_limit_of_liability?(10.0)
    assert_true  contract.within_limit_of_liability?(69.0)
    assert_false contract.within_limit_of_liability?(70.0)
    assert_false contract.within_limit_of_liability?(80.0)
  end

  def test_limit_of_liability_multiple_claims
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    terms_and_conditions = TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90)

    contract = Contract.new(100.0, product, terms_and_conditions)
    contract.claims << Claim.new(10.0, Date.new(2010, 10, 1))
    contract.claims << Claim.new(20.0, Date.new(2010, 10, 1))

    assert_equal 50.0, contract.limit_of_liability
    assert_true  contract.within_limit_of_liability?(10.0)
    assert_true  contract.within_limit_of_liability?(49.0)
    assert_false contract.within_limit_of_liability?(50.0)
    assert_false contract.within_limit_of_liability?(80.0)
  end

  def test_extend_annual_subscription
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    terms_and_conditions = TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90)

    contract = Contract.new(100.0, product, terms_and_conditions)

    contract.extend_annual_subscription

    assert_equal TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2014, 5, 8), 90), contract.terms_and_conditions
  end

  # entities compare by unique IDs, not properties
  def test_contract_equality
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    terms_and_conditions = TermsAndConditions.new(Date.new(2010, 5, 8), Date.new(2010, 5, 8), Date.new(2013, 5, 8), 90)
    contract = Contract.new(100.0, product, terms_and_conditions)

    contract_same_id         = contract.clone
    contract_same_id.status  = "ACTIVE"

    assert_equal     contract, contract_same_id

    contract_different_id = Contract.new(100.0, product, terms_and_conditions)
    assert_not_equal contract, contract_different_id
  end
end
