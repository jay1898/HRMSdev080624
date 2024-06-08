public class ContentDocumentLinkTriggerHandler {
    
/**
*   @Method:        shareWorkOrderfile
*   @Purpose:       To set the shareType as I, so that all the users who have access to Work Order 
					can view the files attached to it.
*   @Author:        Pallavi (eVerge)
*   @Date:          03/05/2022
*   @TaskSource:    

*   @Updates:       
*/  
    Public static Boolean RUN_TRIGGER = TRUE ;
    public static void shareWorkOrderfile(list<ContentDocumentLink> cdlList) {
      List<ContentDocumentLink>  listCDL = new List<ContentDocumentLink>();
        for(ContentDocumentLink cld : cdlList){
           String sWOId = String.valueOf(cld.linkedentityid);
            system.debug('sWOId : ' + sWOId);  
            if(sWOId.startsWith('0WO') || sWOId.startsWith('1WL')) {
                ContentDocumentLink cdlink = new ContentDocumentLink(Id=cld.Id);
              	system.debug('ContentDocumentId : ' + cdlink.ContentDocumentId);
               	cdlink.ShareType = 'I' ;
                cdlink.Visibility = 'AllUsers';
               	listCDL.add(cdlink);
            }
        }
        if(listCDL.size() >0){
          	UPDATE listCDL ;
        }
    }


}