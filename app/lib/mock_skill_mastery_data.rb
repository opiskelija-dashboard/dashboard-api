# This is only fake data for SkillMastery's calculations.
# This will be redundant when there is an end point for these on TMC server.
class MockSkillMasteryData
  def self.fake_data
    {
      'for' => ['12-01', '12-03', '08-01', '08-09', '08-08.3', '08-10', '08-12.1', '08-12.2', '08-12.5', '09-04.2', '11-06.1'],
      'while' => ['12-03', '12-05', '08-09', '08-10', '08-12.5', '11-08.7', '11-08.6', '11-08.5', '11-08.1'],
      'if' => ['12-04', '08-01', '08-09', '11-08.6', '11-08.2', '11-08.3', '10-01', '08-06.2']
    }
  end
end
