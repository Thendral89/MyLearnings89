public class cmpAPDocuSignTokenFutureCttrl  implements Schedulable {
    	//System.schedule('cmpAPDocuSignTokenFutureCttrl Every 0th min', '0 0 * * * ?', new cmpAPDocuSignTokenFutureCttrl());
		//System.schedule('cmpAPDocuSignTokenFutureCttrl Every 15th min', '0 15 * * * ?', new cmpAPDocuSignTokenFutureCttrl());
		//System.schedule('cmpAPDocuSignTokenFutureCttrl Every 30th min', '0 30 * * * ?', new cmpAPDocuSignTokenFutureCttrl());
		//System.schedule('cmpAPDocuSignTokenFutureCttrl Every 45th min', '0 45 * * * ?', new cmpAPDocuSignTokenFutureCttrl());
		
    public void execute(SchedulableContext sc){
        system.debug('*******Going to call future method ');
        cmpAPDocuSignTokenCtrl.DocuSignTokenFuture();
    }
}