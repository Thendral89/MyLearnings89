public without sharing class  cmpAPiManageTrgUtilCtrl {

    @AuraEnabled
    public static void UpdateParentFolder(List<string> PatentId) {
        Map<string,string> Mapfolders = new Map<string,string>();
        List<iManage_Folders__c> ObjProject = new List<iManage_Folders__c>();
        List<iManage_Folders__c> acctList = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
                                             From iManage_Folders__c 
                                             Where recordId__c IN :PatentId
                                             AND IsConfigured__c=false
                                             Order by CreatedDate ASC LIMIT 100];
       if(acctList.size()>0) {
        	for(iManage_Folders__c folders: acctList){
                Mapfolders.put(folders.id__c,folders.Id);
        	}
       }
        
    List<iManage_Folders__c> ParentFolder = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
                                             From iManage_Folders__c 
                                             Where recordId__c IN :PatentId
                                             AND IsConfigured__c=false];
     if(ParentFolder.size()>0){
       for(iManage_Folders__c folder: ParentFolder){
            string parent_id=Mapfolders.get(folder.parent_id__c);
            if(parent_id!=null && parent_id!='' && parent_id!=folder.Id) {
                iManage_Folders__c Project = new iManage_Folders__c();
                Project.Id=folder.Id;
                Project.ParentId__c=parent_id;
                ObjProject.add(Project);
           }
      	 }
      }          
      
        if(ObjProject.size()>0)
            update ObjProject;
        
    }
    
    public static string getParentId(string FolderIds) {
        string ParentId='';
        List<iManage_Folders__c> ObjFolder = [Select Id,parent_id__c,ParentId__c From iManage_Folders__c  Where id__c =: FolderIds];
        if(ObjFolder.size()>0)
            ParentId=ObjFolder[0].Id;
        
        return ParentId;
    }
    
    public static void CreateFileExplorerFile(List<string> FolderIds) {
        List<FileExplorerFile__c> ObjReview = new List<FileExplorerFile__c>();
        List<FileExplorerFile__c> ObjFileExplorerFolder = new List<FileExplorerFile__c>();
        List<string> ExplorerFolderIds = new List<string>();
        Map<String,FileExplorerFolder__c> MapFolders=new Map<String,FileExplorerFolder__c>();
        List<string> iManageFolderIds = new List<string>();
        
        List<iManage_Documents__c> Previewers = [Select Id,ContentVersionId__c,size__c,extension__c,type__c,
                                                         name__c,iManage_Folders__r.recordId__c,iManage_Folders__c
                                                         From iManage_Documents__c  
                                                         Where Id IN : FolderIds];
                 if ( Previewers.size() > 0 ) {
                     for(iManage_Documents__c reviewer : Previewers) {
                         FileExplorerFile__c Project = new FileExplorerFile__c();
                         Project.ContentDocumentId__c=reviewer.ContentVersionId__c;
                         Project.ContentSize__c=integer.valueof(reviewer.size__c);
                         Project.FileExtension__c=reviewer.extension__c;
                         Project.FileType__c=reviewer.type__c;
                         Project.Label__c=reviewer.name__c;
                         Project.LinkedEntityId__c=reviewer.iManage_Folders__r.recordId__c;
                         Project.iManage_Documents__c=reviewer.Id;
                         iManageFolderIds.add(reviewer.iManage_Folders__c);
                         
                         if(!ExplorerFolderIds.contains(reviewer.Id)) 
                             ObjReview.add(Project); 
                         ExplorerFolderIds.add(reviewer.Id);
                     }
                 }
        
        if(ObjReview.size()>0)
            insert ObjReview;
        
    }
    
     @future
    public static void CreateiManageDocumentsfuture(List<string> FolderIds) {
        cmpAPiManageTrgUtilCtrl.CreateiManageDocuments(FolderIds);
    }
    
    
    public static void CreateiManageDocuments(List<string> FolderIds) {
        		List<FileExplorerFile__c> ObjReview = new List<FileExplorerFile__c>();
        		List<FileExplorerFile__c> ObjFileExplorerFolder = new List<FileExplorerFile__c>();
        		List<string> ExplorerFolderIds = new List<string>();
        		Map<String,FileExplorerFolder__c> MapFolders=new Map<String,FileExplorerFolder__c>();
        		List<string> iManageFolderIds = new List<string>();
        
        		List<FileExplorerFile__c> ObjPreviewers = [Select Id,iManage_Documents__c,iManage_Documents__r.iManage_Folders__c
                                                       From FileExplorerFile__c  
                                                       Where iManage_Documents__c IN : FolderIds];
                 if (ObjPreviewers.size() > 0 ) {
                     for(FileExplorerFile__c Freviewer : ObjPreviewers) {
                       ExplorerFolderIds.add(Freviewer.iManage_Documents__c); 
                       iManageFolderIds.add(Freviewer.iManage_Documents__r.iManage_Folders__c);
                     }
                 }
        
        		List<iManage_Documents__c> Previewers = [Select Id,ContentVersionId__c,size__c,extension__c,type__c,
                                                         name__c,iManage_Folders__r.recordId__c,iManage_Folders__c
                                                         From iManage_Documents__c  
                                                         Where Id IN : FolderIds];
                 if ( Previewers.size() > 0 ) {
                     for(iManage_Documents__c reviewer : Previewers) {
                         FileExplorerFile__c Project = new FileExplorerFile__c();
                         Project.ContentDocumentId__c=reviewer.ContentVersionId__c;
                         Project.ContentSize__c=integer.valueof(reviewer.size__c);
                         Project.FileExtension__c=reviewer.extension__c;
                         Project.FileType__c=reviewer.type__c;
                         Project.Label__c=reviewer.name__c;
                         Project.LinkedEntityId__c=reviewer.iManage_Folders__r.recordId__c;
                         Project.iManage_Documents__c=reviewer.Id;
                         iManageFolderIds.add(reviewer.iManage_Folders__c);
                         
                         if(!ExplorerFolderIds.contains(reviewer.Id)) 
                             ObjReview.add(Project); 
                         ExplorerFolderIds.add(reviewer.Id);
                     }
                 }
        
        if(ObjReview.size()>0)
            insert ObjReview;
        
       			 List<FileExplorerFolder__c	> ObjExplorerFolder = [Select Id,iManage_Folders__c
                                                                  From FileExplorerFolder__c  
                                                                  Where iManage_Folders__c IN : iManageFolderIds];
                 if (ObjExplorerFolder.size() > 0 ) {
                     for(FileExplorerFolder__c ObFolders : ObjExplorerFolder) {
                             MapFolders.put(ObFolders.iManage_Folders__c,ObFolders);
                     }
                 }
        
         		List<FileExplorerFile__c> ObjExpFolders = [Select Id,iManage_Documents__c,iManage_Documents__r.iManage_Folders__c
                                                             From FileExplorerFile__c  
                                                             Where iManage_Documents__c IN : FolderIds];
                 if ( ObjExpFolders.size() > 0 ) {
                     for(FileExplorerFile__c folderdata : ObjExpFolders) {
                         FileExplorerFile__c FileFolder = new FileExplorerFile__c();
                         if (MapFolders.containsKey(folderdata.iManage_Documents__r.iManage_Folders__c)){
                         FileFolder.Id=folderdata.Id;
                         FileFolder.Folder__c=MapFolders.get(folderdata.iManage_Documents__r.iManage_Folders__c).Id; 
                         ObjFileExplorerFolder.add(FileFolder);
                         }   
                     }
                 }
        
       if(ObjFileExplorerFolder.size()>0)
           update ObjFileExplorerFolder;
        
    }
    
    @future
    public static void CreateiManageFolderfuture(List<string> FolderIds) {
        cmpAPiManageTrgUtilCtrl.CreateiManageFolder(FolderIds);
    }
    
    public static void CreateiManageFolder(List<string> FolderIds) {
        		List<FileExplorerFolder__c> ObjReview = new List<FileExplorerFolder__c>();
        		List<FileExplorerFolder__c> ObjFileExplorerFolder = new List<FileExplorerFolder__c>();
        		List<Id> ExplorerFolderIds = new List<Id>();
        		Map<String,FileExplorerFolder__c> MapFolders=new Map<String,FileExplorerFolder__c>();
        		List<Id> iManageFolderIds = new List<Id>();
        
        		List<FileExplorerFolder__c> ObjPreviewers = [Select Id,iManage_Folders__c,LinkedEntityId__c	
                                                       From FileExplorerFolder__c  
                                                       Where iManage_Folders__c IN : FolderIds];
                 if ( ObjPreviewers.size() > 0 ) {
                     for(FileExplorerFolder__c Freviewer : ObjPreviewers) {
                       ExplorerFolderIds.add(Freviewer.iManage_Folders__c);  
                       iManageFolderIds.add(Freviewer.LinkedEntityId__c);
                     }
                 }
        
        		List<iManage_Folders__c> Previewers = [Select Id,has_subfolders__c,id__c,name__c,parent_id__c,recordId__c
                                                       From iManage_Folders__c  
                                                       Where Id IN : FolderIds];
                 if ( Previewers.size() > 0 ) {
                     for(iManage_Folders__c reviewer : Previewers) {
                         FileExplorerFolder__c Project = new FileExplorerFolder__c();
                         Project.Label__c=reviewer.name__c;
                         Project.LinkedEntityId__c=reviewer.recordId__c;
                         Project.iManage_Folders__c=reviewer.Id;
                         if(!ExplorerFolderIds.contains(reviewer.Id)) 
                             ObjReview.add(Project); 
                         ExplorerFolderIds.add(reviewer.Id);
                     }
                 }
        
        if(ObjReview.size()>0)
            insert ObjReview;
        
       			 List<FileExplorerFolder__c> ObjExplorerFolder = [Select Id,iManage_Folders__c,
                                                                  iManage_Folders__r.id__c,
                                                                  iManage_Folders__r.parent_id__c
                                                                  From FileExplorerFolder__c  
                                                                  Where LinkedEntityId__c IN : iManageFolderIds];
                 if ( ObjExplorerFolder.size() > 0 ) {
                     for(FileExplorerFolder__c ObFolders : ObjExplorerFolder) {
                         if(ObFolders.iManage_Folders__r.id__c!= ObFolders.iManage_Folders__r.parent_id__c)
                             MapFolders.put(ObFolders.Id,ObFolders);
                     }
                 }
        
         		List<FileExplorerFolder__c> ObjExpFolders = [Select Id,iManage_Folders__c,
                                                             iManage_Folders__r.id__c,
                                                             iManage_Folders__r.parent_id__c
                                                             From FileExplorerFolder__c  
                                                             Where LinkedEntityId__c IN : iManageFolderIds];
                 if ( ObjExpFolders.size() > 0 ) {
                     for(FileExplorerFolder__c folderdata : ObjExpFolders) {
                         FileExplorerFolder__c FileFolder = new FileExplorerFolder__c();
                         if (MapFolders.containsKey(folderdata.iManage_Folders__c)){
                         FileFolder.Id=MapFolders.get(folderdata.Id).Id; 
                         ObjFileExplorerFolder.add(FileFolder);
                         }   
                     }
                 }
        
       if(ObjFileExplorerFolder.size()>0)
           update ObjFileExplorerFolder;
        
    }
    
}