@IsTest
public class APInventorCtrlWrapperTest {
    @IsTest
    static void testWrapperInitialization() {
        APInventorCtrlWrapper wrapper = new APInventorCtrlWrapper();
        wrapper.Id = '0012x000003DxPQAA0';
        wrapper.PersonId = '0032x000004XyzABC';
        wrapper.Name = 'Test Name';
        wrapper.Email = 'test@example.com';
        wrapper.IsAdmin = true;
        wrapper.Rank = 'Manager';
        wrapper.EmploymentCategory = 'Full-Time';
        wrapper.Employmentstatus = 'Active';
        wrapper.Workday_cec_Id = 'WCECID123';
        wrapper.UserStatus = 'Enabled';
        wrapper.CityName = 'Hyderabad';
        wrapper.CountryName = 'India';
    }

    @IsTest
    static void testWrapperEmptyInitialization() {
        APInventorCtrlWrapper wrapper = new APInventorCtrlWrapper();
    }
}