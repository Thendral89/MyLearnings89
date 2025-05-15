public class cmpAPiMngGetTrashedDocFutureCtrl  implements Schedulable {
    	
		//System.schedule('cmpAPiMngGetTrashedDocFutureCtrl Every 0th min', '0 0 * * * ?', new cmpAPiMngGetTrashedDocFutureCtrl());
		//System.schedule('cmpAPiMngGetTrashedDocFutureCtrl Every 15th min', '0 15 * * * ?', new cmpAPiMngGetTrashedDocFutureCtrl());
		//System.schedule('cmpAPiMngGetTrashedDocFutureCtrl Every 30th min', '0 30 * * * ?', new cmpAPiMngGetTrashedDocFutureCtrl());
		//System.schedule('cmpAPiMngGetTrashedDocFutureCtrl Every 45th min', '0 45 * * * ?', new cmpAPiMngGetTrashedDocFutureCtrl());
		
    public void execute(SchedulableContext sc){
        system.debug('*******Going to call future method ');
        cmpAPiMngGetTrashedDocCtrl.iMngGetDoc('');
    }
}