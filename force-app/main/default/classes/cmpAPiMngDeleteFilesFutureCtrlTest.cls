@isTest
public class cmpAPiMngDeleteFilesFutureCtrlTest {
    
  
    
    @isTest
    static void testJobScheduling() {
        Test.startTest();
        cmpAPiMngDeleteFilesFutureCtrl job = new cmpAPiMngDeleteFilesFutureCtrl();
        String cronExpression = '0 0 * * * ?';
        System.schedule('cmpAPiMngDeleteFilesFutureCtrl Test', cronExpression, job);
        
        Test.stopTest();
    }
   
    
}