class ParkingRecord < Struct.new(:license_plate, :start_time, :end_time, :amount, :total_time)
  def gross_fee
    amount || 0.0
  end
end
