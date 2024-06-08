public class ServiceAppointmentPhotosListWrapper {
    @AuraEnabled
    public ServiceAppointment saRecord {get; set;}
    @AuraEnabled
    public List<ContentVersion> photos {get; set;}
    @AuraEnabled
    public integer photosCount {get; set;}
}