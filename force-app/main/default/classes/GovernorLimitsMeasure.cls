public with sharing class GovernorLimitsMeasure {
    public GovernorLimitsMeasure() {

    }

    private static Double relativeLimitPercentage = 100;

    public Integer soqlsToConsume = 0;
    public Integer dmlsToConsume = 0;
    public Integer dmlRecordsToConsume = 0;

    private Integer soqlsToBeLeftOverAfterServiceRuns;
    private Integer dmlsToBeLeftOverAfterServiceRuns;
    private Integer dmlRecordsToBeLeftOverAfterServiceRuns;

    private void soqlsToBeLeftAfterServiceRuns(){
        Integer maxSoqlStatements = Limits.getLimitQueries();
        Integer soqlsAlreadyIssued = Limits.getQueries();
        Integer soqlsToBeIssued = dmlsToConsume;
        
        System.debug('soqlsAlreadyIssued '+ soqlsAlreadyIssued);
        System.debug('soqlsToBeLeftOverAfterServiceRuns '+ soqlsToBeLeftOverAfterServiceRuns);
        soqlsToBeLeftOverAfterServiceRuns = Integer.valueOf( (relativeLimitPercentage / 100 ) * maxSoqlStatements ) - soqlsAlreadyIssued - soqlsToBeIssued;
    }

    private void dmlsToBeLeftAfterServiceRuns(){
        Integer maxDmlStatements = Limits.getLimitDMLStatements();
        Integer dmlsAlreadyIssued = Limits.getDMLStatements();
        Integer dmlsToBeIssued = dmlsToConsume;
        
        System.debug('dmlsAlreadyIssued '+ dmlsAlreadyIssued);
        System.debug('dmlsToBeLeftOverAfterServiceRuns '+ dmlsToBeLeftOverAfterServiceRuns);
        dmlsToBeLeftOverAfterServiceRuns = Integer.valueOf( (relativeLimitPercentage / 100 ) * maxDmlStatements ) - dmlsAlreadyIssued - dmlsToBeIssued;
    }

    private void dmlRecordsToBeLeftAfterServiceRuns(){
        Integer maxDmlRecordsStatements = Limits.getLimitDMLRows();
        Integer dmlRecordsAlreadyIssued = Limits.getDMLRows();
        Integer dmlsRecordsToBeIssued = dmlRecordsToConsume;
        
        System.debug('dmlRecordsAlreadyIssued '+ dmlRecordsAlreadyIssued);
        System.debug('dmlRecordsToBeLeftOverAfterServiceRuns '+ dmlRecordsToBeLeftOverAfterServiceRuns);
        dmlRecordsToBeLeftOverAfterServiceRuns = Integer.valueOf( (relativeLimitPercentage / 100 ) * maxDmlRecordsStatements ) - dmlRecordsAlreadyIssued - dmlsRecordsToBeIssued;
    }

    public void setRelativeLimitPercentage(Integer relativeLimitPercentageParameter){
        relativeLimitPercentage = relativeLimitPercentageParameter;
    }

    public static void setRelativeLimitPercentageInExecutionContext(Integer relativeLimitPercentageParameter){
        relativeLimitPercentage = relativeLimitPercentageParameter;
    }

    public Boolean canCrossBandGap(){
        soqlsToBeLeftAfterServiceRuns();
        dmlsToBeLeftAfterServiceRuns();
        dmlRecordsToBeLeftAfterServiceRuns();

        if(
            soqlsToBeLeftOverAfterServiceRuns <= 1 ||
            dmlsToBeLeftOverAfterServiceRuns <= 1 ||
            dmlRecordsToBeLeftOverAfterServiceRuns <= 1
        ){
            System.debug('>>>>>>>>>>>>>');
            return true;
        }
        else{
            System.debug('ooooooooooooooooo');
            return false;
        }
    }

    public void clear(){
        this.soqlsToConsume = 0;
        this.dmlRecordsToConsume = 0;
        this.dmlsToConsume = 0;
    }

    public Boolean willCrossQueableBandGap(){
        Integer maxQueueableStatements = Limits.getLimitQueueableJobs();
        Integer queablesAlreadyIssued = Limits.getQueueableJobs();

        Integer leftToIssue = maxQueueableStatements - queablesAlreadyIssued - GovernorLimitsReduceConstants.QUEABLE_BANDGAP;
        if(leftToIssue <= 1){
            return true;
        }
        else{
            return false;
        }
    }
}