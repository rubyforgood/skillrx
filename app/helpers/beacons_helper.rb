module BeaconsHelper
  def status_string(beacon)
    beacon.revoked? ? "Revoked" : "Active"
  end
end
