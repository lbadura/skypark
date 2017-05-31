class LicenseRecord < Struct.new(:period_date, :license_plate, :added_on, :removed_on, :fee)
  TAX_RATE = 0.23

  def gross_fee
    fee * (1 + TAX_RATE)
  end
end
