trigger trgInventorDesignerTrigger on SymphonyLF__Inventor_Designer_Author__c ( after insert) {
    mvSObjectDomain.triggerHandler( InventorDesignerTriggerHandler.class );
}