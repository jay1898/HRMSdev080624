global class UploadPDFAsAttachment implements Messaging.InboundEmailHandler {
     global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
         Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
         try{
             String subject = String.valueOf(email.subject)!= null? String.valueOf(email.subject): '';
			 system.debug(subject.substringBetween('[',']'));
             String woId = subject.substringBetween('[',']') ;
             if(woId != null){
                 if(email.binaryAttachments != null){
                     System.debug('UploadPDFAsAttachment : binary');
                     List<ContentVersion>cvList = new List<ContentVersion>();
           			 List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                     for (Messaging.InboundEmail.BinaryAttachment binAttach : email.binaryAttachments) {
                        ContentVersion fContentInsert = new ContentVersion();
                        fContentInsert.Title = binAttach.fileName;
                        fContentInsert.VersionData = binAttach.body;
                        fContentInsert.PathOnClient = '/' + binAttach.fileName ;
                        cvList.add(fContentInsert);

          			}
                     insert cvList;
                     system.debug('UploadPDFAsAttachment ' + cvList[0]);
                     cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];
                     for (ContentVersion cv : cvList) {
                          ContentDocumentLink cl = new ContentDocumentLink();
                          cl.ContentDocumentId = cv.ContentDocumentId;
                          cl.LinkedEntityId = woId; //Shared with record ID
                          cl.ShareType = 'V';
                          cl.Visibility = 'AllUsers';
                          cdlList.add(cl);
          			}
           			insert cdlList;
                 }
                 if(email.textAttachments != null){
                    System.debug('text');         
                    List<ContentVersion>cvList = new List<ContentVersion>();
                    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                    for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                      ContentVersion fContentInsert = new ContentVersion();
                      fContentInsert.Title = tAttachment.fileName;
                      fContentInsert.VersionData = Blob.valueOf(tAttachment.body);
                      fContentInsert.PathOnClient = '/' + tAttachment.fileName ;
                      cvList.add(fContentInsert);
                    }
					insert cvList;
          			cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];
          			for (ContentVersion cv : cvList) {
                      ContentDocumentLink cl = new ContentDocumentLink();
                      cl.ContentDocumentId = cv.ContentDocumentId;
                      cl.LinkedEntityId = woId; //Shared with record ID
                      cl.ShareType = 'V';
                      cl.Visibility = 'AllUsers';
                      cdlList.add(cl);
          			}
           			insert cdlList;
           		}
             }
         }
         catch (QueryException e) {
       		System.debug('PDF Attachment Issue: ' + e);
         }
         result.success = true;
    	 return result;
     }

}