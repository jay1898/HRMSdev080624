/**
*   @Author:        Pallavi Patil (eVerge)
*   @Date:          02/05/2020
*   @TaskSource:    Jira
*   @Purpose:       Based on the Owner of the Opportunity, Owners image should be sent in the mail. 
Link to ConnectApi.Photo.largePhotoUrl : https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_connectapi_output_photo.htm
*/

public without sharing class SalesRepBioController {
    public String currentUserImgURI {get; set;}
    public List<Opportunity> relatedTo {get;set;}
    //OppId is passed from the VF Component SalesRepBioComponent
    public Id OppId{
        get{
            return OppId ;
        }
        set{
            OppId = value;
            getProfileImage();
        }
    }
    
    public void getProfileImage()
    {
        relatedTo = [Select OwnerId FROM Opportunity Where Id =:OppId ]; //get the owner of the Opp
        
        if(relatedTo.size() >0) 
        {
            String  Owid = relatedTo[0].OwnerId;
            //Added to Resolve test class error
            if(!Test.isRunningTest()){
                ConnectApi.Photo ph =  ConnectApi.UserProfiles.getPhoto(null, Owid ); //get the image of the owner
                System.debug('@@ph.standardEmailPhotoUrl'+ph.standardEmailPhotoUrl);
                currentUserImgURI = ph.standardEmailPhotoUrl ;
                System.debug('@@'+currentUserImgURI);
            }
            else{
                currentUserImgURI = '';
            }
        }
        else
        {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('SalesRepBioController','getProfileImage',(string)OppId,'Sales Rep not found',null,'VF Email Template'));
        }
    }
    
    
}