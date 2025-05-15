public class cmpAPiMngDeleteFilesFutureCtrl  implements Schedulable {
    	
		//System.schedule('cmpAPiMngDeleteFilesFutureCtrl Every 0th min', '0 0 * * * ?', new cmpAPiMngDeleteFilesFutureCtrl());
		//System.schedule('cmpAPiMngDeleteFilesFutureCtrl Every 15th min', '0 15 * * * ?', new cmpAPiMngDeleteFilesFutureCtrl());
		//System.schedule('cmpAPiMngDeleteFilesFutureCtrl Every 30th min', '0 30 * * * ?', new cmpAPiMngDeleteFilesFutureCtrl());
		//System.schedule('cmpAPiMngDeleteFilesFutureCtrl Every 45th min', '0 45 * * * ?', new cmpAPiMngDeleteFilesFutureCtrl());
		
    public void execute(SchedulableContext sc){
        system.debug('*******Going to call future method ');
        cmpAPAPIHeaderCtrl.getDeleteContentDocuments('');
    }
}