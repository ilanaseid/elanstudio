class FraudNotifier < SimpleDelegator

  DESCRIPTIONS = {
    failed_multiple: 'has 3+ failed payments',
    valued_over_500: 'is valued over $500',
    valued_over_800: 'is valued over $800',
    strange_address: 'has 3 digits in address2 (like a box # or apartment #)',
    mismatched_address: 'has mismatching billing and shipping addresses',
    unverified_address: 'raised an AVS code flag I, L or P',
    guest: 'used guest checkout'
  }

  PATTERNS = [
    %w(failed_multiple),
    %w(signed_in valued_over_500 strange_address),
    %w(signed_in valued_over_500 mismatched_address),
    %w(guest valued_over_800),
    %w(guest valued_over_500 strange_address),
    %w(guest valued_over_500 mismatched_address),
    %w(unverified_address)
  ]

  delegate :staff?, to: :user, allow_nil: true

  def failed_multiple?
    payments.count {|p| p.state == 'failed' } > 2
  end

  def valued_over_500?
    total > 500
  end

  def valued_over_800?
    total > 800
  end

  def strange_address?
    return unless ship_address
    ship_address.address2.scan(/\d/).size > 3
  end

  def mismatched_address?
    return unless ship_address && bill_address
    ship_address.address1 != bill_address.address1
  end

  def unverified_address?
    payments.pluck(:avs_response).any? { |r| r.to_s.match(/I|L|P/) }
  end

  def subject
    "ALERT/URGENT: Fraud flag raised for #{'guest checkout ' if guest?}#{number}"
  end

  def matched_pattern
    @matched_pattern ||= PATTERNS.find {|p| p.all? {|m| send("#{m}?") } }
  end

  def messages
    return [] unless matched_pattern
    DESCRIPTIONS.select {|name,desc| matched_pattern.include?(name.to_s) }.values
  end

  def body
    return unless matched_pattern
    <<-EOT
     Spree order #{number} has met the following conditions indicating it could be fraudulent:
     #{messages.to_sentence.capitalize}
     Please take extra precautions to make sure it is not fraudulent.

    Shipping Address
    ------------------------------------------------------------
    #{ship_address.full_name}
    #{ship_address.address1}
    #{ship_address.address2}

    #{ship_address.city }
    #{ship_address.state_text}
    #{ship_address.zipcode}
    #{ship_address.country.try(:name)}

    Billing Address
    ------------------------------------------------------------
    #{bill_address.full_name}
    #{bill_address.address1}
    #{bill_address.address2}

    #{bill_address.city }
    #{bill_address.state_text}
    #{bill_address.zipcode}
    #{bill_address.country.try(:name)}

    Link: https://www.elanstudio.com/admin/orders/#{number}/edit

    EOT
  end

  def deliver(email = Settings.contact_info.operations_email)
    return if staff? || !matched_pattern
    SystemMailer.general(email, subject, body).deliver
  end

end
